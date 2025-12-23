require 'rails_helper'

RSpec.describe PersonPresenter, type: :presenter do
  let(:person) { build(:person, first_name: "John", middle_name: "Michael", last_name: "Doe", ssn: "123-45-6789") }
  let(:presenter) { described_class.new(person) }

  describe "#masked_ssn" do
    it "masks SSN showing only last 4 digits" do
      expect(presenter.masked_ssn).to eq("***-**-6789")
    end

    it "returns all asterisks when SSN is blank" do
      person.ssn = nil
      expect(presenter.masked_ssn).to eq("***-**-****")
    end
  end

  describe "#full_name" do
    it "returns full name with middle name" do
      expect(presenter.full_name).to eq("John Michael Doe")
    end

    it "returns full name without middle name" do
      person.middle_name = nil
      expect(presenter.full_name).to eq("John Doe")
    end

    it "returns full name with blank middle name" do
      person.middle_name = ""
      expect(presenter.full_name).to eq("John Doe")
    end
  end

  describe "#full_address" do
    it "returns complete formatted address without street address 2" do
      person.street_address_2 = nil
      expected = "#{person.street_address_1}, #{person.city}, #{person.state} #{person.zip_code}"
      expect(presenter.full_address).to eq(expected)
    end

    it "includes street address 2 when present" do
      person.street_address_2 = "Apt 4B"
      expected = "#{person.street_address_1}, Apt 4B, #{person.city}, #{person.state} #{person.zip_code}"
      expect(presenter.full_address).to eq(expected)
    end
  end

  describe "#display_name" do
    it "returns name with masked SSN" do
      expect(presenter.display_name).to eq("John Michael Doe (***-**-6789)")
    end
  end

  describe "#initials" do
    it "returns initials from all name parts" do
      expect(presenter.initials).to eq("JMD")
    end

    it "returns initials without middle name" do
      person.middle_name = nil
      expect(presenter.initials).to eq("JD")
    end

    it "returns uppercase initials" do
      person.first_name = "john"
      person.middle_name = "michael"
      person.last_name = "doe"
      expect(presenter.initials).to eq("JMD")
    end
  end

  describe "#formatted_created_at" do
    it "returns formatted date" do
      person.created_at = Time.zone.parse("2024-01-15 14:30:00")
      expect(presenter.formatted_created_at).to eq("January 15, 2024 at 02:30 PM")
    end
  end

  describe "#has_middle_name?" do
    it "returns true when middle name is present" do
      expect(presenter.has_middle_name?).to be true
    end

    it "returns false when middle name is blank" do
      person.middle_name = ""
      expect(presenter.has_middle_name?).to be false
    end

    it "returns false when middle name is nil" do
      person.middle_name = nil
      expect(presenter.has_middle_name?).to be false
    end
  end

  describe "#address_lines" do
    it "returns array of address lines without street address 2" do
      person.street_address_2 = nil
      lines = presenter.address_lines
      expect(lines).to eq([
        person.street_address_1,
        "#{person.city}, #{person.state} #{person.zip_code}"
      ])
    end

    it "returns array of address lines with street address 2" do
      person.street_address_2 = "Apt 4B"
      lines = presenter.address_lines
      expect(lines).to eq([
        person.street_address_1,
        "Apt 4B",
        "#{person.city}, #{person.state} #{person.zip_code}"
      ])
    end
  end

  describe "delegation" do
    it "delegates attributes to the model" do
      expect(presenter.first_name).to eq(person.first_name)
    end

    it "delegates id to the model" do
      person.id = 123
      expect(presenter.id).to eq(123)
    end
  end
end

