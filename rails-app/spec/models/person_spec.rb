require 'rails_helper'

RSpec.describe Person, type: :model do
  before do
    allow_any_instance_of(SsnValidationService).to receive(:validate)
      .and_return({ valid: true })
  end

  describe "validations" do
    subject { build(:person) }

    context "first_name" do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
      it { is_expected.to validate_length_of(:first_name).is_at_least(1) }
    end

    context "middle_name" do
      it { is_expected.to validate_length_of(:middle_name).is_at_most(50) }
      
      it "allows blank middle name" do
        person = build(:person, middle_name: nil)
        expect(person).to be_valid
      end
    end

    context "last_name" do
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
      it { is_expected.to validate_length_of(:last_name).is_at_least(1) }
    end

    context "ssn" do
      it { is_expected.to validate_presence_of(:ssn) }

      it "accepts valid SSN format XXX-XX-XXXX" do
        person = build(:person, ssn: "123-45-6789")
        expect(person).to be_valid
      end

      it "rejects SSN without dashes" do
        person = build(:person, ssn: "123456789")
        expect(person).not_to be_valid
      end

      it "shows error message for SSN without dashes" do
        person = build(:person, ssn: "123456789")
        person.valid?
        expect(person.errors[:ssn]).to include("must be in XXX-XX-XXXX format")
      end

      it "rejects SSN with incorrect format" do
        person = build(:person, ssn: "12-345-6789")
        expect(person).not_to be_valid
      end

      it "rejects SSN with letters" do
        person = build(:person, ssn: "ABC-DE-FGHI")
        expect(person).not_to be_valid
      end
    end

    context "street_address_1" do
      it { is_expected.to validate_presence_of(:street_address_1) }
    end

    context "street_address_2" do
      it "allows blank street_address_2" do
        person = build(:person, street_address_2: nil)
        expect(person).to be_valid
      end
    end

    context "city" do
      it { is_expected.to validate_presence_of(:city) }
    end

    context "state" do
      it { is_expected.to validate_presence_of(:state) }

      it "accepts valid 2-letter state abbreviation" do
        person = build(:person, state: "CA")
        expect(person).to be_valid
      end

      it "rejects state with more than 2 letters" do
        person = build(:person, state: "CAL")
        expect(person).not_to be_valid
      end

      it "shows error message for state with more than 2 letters" do
        person = build(:person, state: "CAL")
        person.valid?
        expect(person.errors[:state]).to include("must be a 2-letter state abbreviation")
      end

      it "rejects state with less than 2 letters" do
        person = build(:person, state: "C")
        expect(person).not_to be_valid
      end

      it "rejects state with numbers" do
        person = build(:person, state: "C1")
        expect(person).not_to be_valid
      end

      it "normalizes state to uppercase" do
        person = create(:person, state: "ca")
        expect(person.state).to eq("CA")
      end
    end

    context "zip_code" do
      it { is_expected.to validate_presence_of(:zip_code) }

      it "accepts valid 5-digit ZIP code" do
        person = build(:person, zip_code: "12345")
        expect(person).to be_valid
      end

      it "rejects ZIP code with less than 5 digits" do
        person = build(:person, zip_code: "1234")
        expect(person).not_to be_valid
      end

      it "shows error message for ZIP code with less than 5 digits" do
        person = build(:person, zip_code: "1234")
        person.valid?
        expect(person.errors[:zip_code]).to include("must be a 5-digit ZIP code")
      end

      it "rejects ZIP code with more than 5 digits" do
        person = build(:person, zip_code: "123456")
        expect(person).not_to be_valid
      end

      it "rejects ZIP code with letters" do
        person = build(:person, zip_code: "1234A")
        expect(person).not_to be_valid
      end
    end
  end

  describe "encryption" do
    it "encrypts SSN when saved to database" do
      person = create(:person, ssn: "123-45-6789")
      
      raw_ssn = ActiveRecord::Base.connection.execute(
        "SELECT ssn FROM people WHERE id = #{person.id}"
      ).first["ssn"]
      
      expect(raw_ssn).not_to eq("123-45-6789")
    end

    it "decrypts SSN when reading from database" do
      person = create(:person, ssn: "123-45-6789")
      reloaded_person = Person.find(person.id)
      
      expect(reloaded_person.ssn).to eq("123-45-6789")
    end
  end

  describe "#masked_ssn" do
    it "returns masked SSN showing only last 4 digits" do
      person = build(:person, ssn: "123-45-6789")
      expect(person.masked_ssn).to eq("***-**-6789")
    end

    it "returns nil if SSN is blank" do
      person = build(:person, ssn: nil)
      expect(person.masked_ssn).to be_nil
    end
  end

  describe "#full_name" do
    it "returns full name with first, middle, and last name" do
      person = build(:person, first_name: "John", middle_name: "Paul", last_name: "Doe")
      expect(person.full_name).to eq("John Paul Doe")
    end

    it "returns full name without middle name" do
      person = build(:person, first_name: "John", middle_name: nil, last_name: "Doe")
      expect(person.full_name).to eq("John Doe")
    end

    it "returns full name with blank middle name" do
      person = build(:person, first_name: "John", middle_name: "", last_name: "Doe")
      expect(person.full_name).to eq("John Doe")
    end
  end

  describe "SSN validation with Java service" do
    let(:person) { build(:person, ssn: "123-45-6789") }
    let(:validation_service) { instance_double(SsnValidationService) }

    before do
      allow(SsnValidationService).to receive(:new).and_return(validation_service)
    end

    context "when Java service returns valid" do
      it "saves the person successfully" do
        allow(validation_service).to receive(:validate).and_return({ valid: true })
        
        expect(person.valid?).to be true
      end
    end

    context "when Java service returns invalid" do
      it "adds error to SSN field" do
        allow(validation_service).to receive(:validate)
          .and_return({ valid: false, error: "Area number cannot be 000" })
        
        person.valid?
        expect(person.errors[:ssn]).to include("Area number cannot be 000")
      end
    end

    context "when Java service is unavailable" do
      it "adds error to base" do
        allow(validation_service).to receive(:validate)
          .and_raise(SsnValidationService::ServiceUnavailableError, "Service unavailable")
        
        person.valid?
        expect(person.errors[:base]).to include(/temporarily unavailable/)
      end
    end

    context "when SSN format is invalid" do
      it "does not call Java service" do
        person.ssn = "invalid"
        
        expect(validation_service).not_to receive(:validate)
        person.valid?
      end
    end
  end
end
