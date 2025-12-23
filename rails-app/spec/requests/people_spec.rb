require 'rails_helper'

RSpec.describe "People", type: :request do
  before do
    allow_any_instance_of(SsnValidationService).to receive(:validate)
      .and_return({ valid: true })
  end

  describe "GET /people" do
    it "returns http success" do
      get people_path
      expect(response).to have_http_status(:success)
    end

    it "displays the people index page" do
      get people_path
      expect(response.body).to include("PII Records")
    end

    it "shows empty state when no people exist" do
      get people_path
      expect(response.body).to include("No PII records")
    end

    it "lists all people when they exist" do
      create(:person, :without_middle_name, first_name: "John", last_name: "Doe")
      get people_path
      expect(response.body).to include("John Doe")
    end

    it "displays masked SSN in the list" do
      create(:person, ssn: "123-45-6789")
      get people_path
      expect(response.body).to include("***-**-6789")
    end
  end

  describe "GET /people/new" do
    it "returns http success" do
      get new_person_path
      expect(response).to have_http_status(:success)
    end

    it "displays the new person form" do
      get new_person_path
      expect(response.body).to include("New PII Record")
    end

    it "includes first name field" do
      get new_person_path
      expect(response.body).to include('name="person[first_name]"')
    end

    it "includes middle name field" do
      get new_person_path
      expect(response.body).to include('name="person[middle_name]"')
    end

    it "includes last name field" do
      get new_person_path
      expect(response.body).to include('name="person[last_name]"')
    end

    it "includes SSN field" do
      get new_person_path
      expect(response.body).to include('name="person[ssn]"')
    end

    it "includes street address 1 field" do
      get new_person_path
      expect(response.body).to include('name="person[street_address_1]"')
    end

    it "includes city field" do
      get new_person_path
      expect(response.body).to include('name="person[city]"')
    end

    it "includes state field" do
      get new_person_path
      expect(response.body).to include('name="person[state]"')
    end

    it "includes zip code field" do
      get new_person_path
      expect(response.body).to include('name="person[zip_code]"')
    end
  end

  describe "POST /people" do
    let(:valid_attributes) do
      {
        first_name: "John",
        middle_name: "Paul",
        last_name: "Doe",
        ssn: "123-45-6789",
        street_address_1: "123 Main St",
        street_address_2: "Apt 4B",
        city: "San Francisco",
        state: "CA",
        zip_code: "94102"
      }
    end

    let(:invalid_attributes) do
      {
        first_name: "",
        last_name: "",
        ssn: "invalid"
      }
    end

    context "with valid parameters" do
      it "creates a new Person" do
        expect {
          post people_path, params: { person: valid_attributes }
        }.to change(Person, :count).by(1)
      end

      it "redirects to the created person" do
        post people_path, params: { person: valid_attributes }
        expect(response).to redirect_to(person_path(Person.last))
      end

      it "saves the person with correct first name" do
        post people_path, params: { person: valid_attributes }
        expect(Person.last.first_name).to eq("John")
      end

      it "saves the person with correct last name" do
        post people_path, params: { person: valid_attributes }
        expect(Person.last.last_name).to eq("Doe")
      end

      it "encrypts the SSN" do
        post people_path, params: { person: valid_attributes }
        raw_ssn = ActiveRecord::Base.connection.execute(
          "SELECT ssn FROM people WHERE id = #{Person.last.id}"
        ).first["ssn"]
        expect(raw_ssn).not_to eq("123-45-6789")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Person" do
        expect {
          post people_path, params: { person: invalid_attributes }
        }.not_to change(Person, :count)
      end

      it "returns unprocessable content status" do
        post people_path, params: { person: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders the new template" do
        post people_path, params: { person: invalid_attributes }
        expect(response.body).to include("New PII Record")
      end

      it "displays error messages" do
        post people_path, params: { person: invalid_attributes }
        expect(response.body).to include("error")
      end
    end
  end

  describe "GET /people/:id" do
    let(:person) { create(:person, :without_middle_name, first_name: "Jane", last_name: "Smith", ssn: "987-65-4321") }

    it "returns http success" do
      get person_path(person)
      expect(response).to have_http_status(:success)
    end

    it "displays the person's full name" do
      get person_path(person)
      expect(response.body).to include("Jane Smith")
    end

    it "displays the masked SSN" do
      get person_path(person)
      expect(response.body).to include("***-**-4321")
    end

    it "displays the person's address" do
      get person_path(person)
      expect(response.body).to include(person.city)
    end

    it "displays the person's state" do
      get person_path(person)
      expect(response.body).to include(person.state)
    end

    it "redirects to index when person not found" do
      get person_path(id: 99999)
      expect(response).to redirect_to(people_path)
    end

    it "sets alert flash when person not found" do
      get person_path(id: 99999)
      expect(flash[:alert]).to eq("Person not found.")
    end
  end

  describe "GET /people/:id/edit" do
    let(:person) { create(:person) }

    it "returns http success" do
      get edit_person_path(person)
      expect(response).to have_http_status(:success)
    end

    it "displays the edit person form" do
      get edit_person_path(person)
      expect(response.body).to include("Edit PII Record")
    end

    it "includes first name field with current value" do
      get edit_person_path(person)
      expect(response.body).to include(person.first_name)
    end

    it "displays masked SSN" do
      person_with_ssn = create(:person, ssn: "123-45-6789")
      get edit_person_path(person_with_ssn)
      expect(response.body).to include("***-**-6789")
    end

    it "shows back to details link" do
      get edit_person_path(person)
      expect(response.body).to include("Back to Details")
    end

    it "redirects when person not found" do
      get edit_person_path(id: 99999)
      expect(response).to redirect_to(people_path)
    end
  end

  describe "PATCH /people/:id" do
    let(:person) { create(:person, first_name: "John", last_name: "Doe") }

    context "with valid parameters" do
      let(:valid_params) do
        {
          person: {
            first_name: "Jane",
            middle_name: "Marie",
            last_name: "Smith",
            street_address_1: "456 New St",
            street_address_2: "",
            city: "San Francisco",
            state: "CA",
            zip_code: "94102"
          }
        }
      end

      it "updates the person" do
        patch person_path(person), params: valid_params
        person.reload
        expect(person.first_name).to eq("Jane")
      end

      it "redirects to the person show page" do
        patch person_path(person), params: valid_params
        expect(response).to redirect_to(person_path(person))
      end

      it "sets a success notice" do
        patch person_path(person), params: valid_params
        expect(flash[:notice]).to eq("Person was successfully updated.")
      end

      it "updates last name" do
        patch person_path(person), params: valid_params
        person.reload
        expect(person.last_name).to eq("Smith")
      end

      it "updates city" do
        patch person_path(person), params: valid_params
        person.reload
        expect(person.city).to eq("San Francisco")
      end
    end

    context "with blank SSN" do
      let(:params_with_blank_ssn) do
        {
          person: {
            first_name: "Jane",
            middle_name: "Marie",
            last_name: "Smith",
            ssn: "",
            street_address_1: "456 New St",
            city: "San Francisco",
            state: "CA",
            zip_code: "94102"
          }
        }
      end

      it "keeps the original SSN" do
        original_ssn = person.ssn
        patch person_path(person), params: params_with_blank_ssn
        person.reload
        expect(person.ssn).to eq(original_ssn)
      end

      it "updates other fields" do
        patch person_path(person), params: params_with_blank_ssn
        person.reload
        expect(person.first_name).to eq("Jane")
      end
    end

    context "with new SSN" do
      let(:params_with_new_ssn) do
        {
          person: {
            first_name: person.first_name,
            middle_name: person.middle_name,
            last_name: person.last_name,
            ssn: "987-65-4321",
            street_address_1: person.street_address_1,
            city: person.city,
            state: person.state,
            zip_code: person.zip_code
          }
        }
      end

      it "updates the SSN" do
        patch person_path(person), params: params_with_new_ssn
        person.reload
        expect(person.ssn).to eq("987-65-4321")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          person: {
            first_name: "",
            last_name: ""
          }
        }
      end

      it "does not update the person" do
        patch person_path(person), params: invalid_params
        person.reload
        expect(person.first_name).to eq("John")
      end

      it "renders the edit template" do
        patch person_path(person), params: invalid_params
        expect(response.body).to include("Edit PII Record")
      end

      it "returns unprocessable content status" do
        patch person_path(person), params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "displays error messages" do
        patch person_path(person), params: invalid_params
        expect(response.body).to include("error")
      end
    end

    context "when person not found" do
      it "redirects to index" do
        patch person_path(id: 99999), params: { person: { first_name: "Test" } }
        expect(response).to redirect_to(people_path)
      end

      it "sets alert flash" do
        patch person_path(id: 99999), params: { person: { first_name: "Test" } }
        expect(flash[:alert]).to eq("Person not found.")
      end
    end
  end

  describe "DELETE /people/:id" do
    let!(:person) { create(:person, first_name: "John", last_name: "Doe") }

    it "deletes the person" do
      expect {
        delete person_path(person)
      }.to change(Person, :count).by(-1)
    end

    it "redirects to index" do
      delete person_path(person)
      expect(response).to redirect_to(people_path)
    end

    it "sets a success notice" do
      delete person_path(person)
      expect(flash[:notice]).to eq("Person was successfully deleted.")
    end

    it "returns see_other status" do
      delete person_path(person)
      expect(response).to have_http_status(:see_other)
    end

    context "when person not found" do
      it "redirects to index" do
        delete person_path(id: 99999)
        expect(response).to redirect_to(people_path)
      end

      it "sets alert flash" do
        delete person_path(id: 99999)
        expect(flash[:alert]).to eq("Person not found.")
      end
    end
  end
end
