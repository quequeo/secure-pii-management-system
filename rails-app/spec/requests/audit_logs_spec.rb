require 'rails_helper'

RSpec.describe "AuditLogs", type: :request do
  before do
    stub_request(:post, "http://localhost:8080/api/v1/ssn/validate")
      .to_return(status: 200, body: { valid: true }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe "GET /audit_logs" do
    before do
      create_list(:audit_log, 3)
    end

    it "returns http success" do
      get audit_logs_path
      expect(response).to have_http_status(:success)
    end

    it "displays page title" do
      get audit_logs_path
      expect(response.body).to include('Audit Logs')
    end

    it "displays statistics section" do
      get audit_logs_path
      expect(response.body).to include('Today')
    end

    it "displays this week stat" do
      get audit_logs_path
      expect(response.body).to include('This Week')
    end

    it "displays views stat" do
      get audit_logs_path
      expect(response.body).to include('Views')
    end

    it "displays creates stat" do
      get audit_logs_path
      expect(response.body).to include('Creates')
    end

    it "displays updates stat" do
      get audit_logs_path
      expect(response.body).to include('Updates')
    end

    it "displays deletes stat" do
      get audit_logs_path
      expect(response.body).to include('Deletes')
    end

    it "displays audit log action" do
      log = create(:audit_log, action: 'view')
      get audit_logs_path
      expect(response.body).to include('View')
    end

    it "displays audit log details" do
      log = create(:audit_log, details: 'Test audit log entry')
      get audit_logs_path
      expect(response.body).to include('Test audit log entry')
    end

    it "shows last 100 entries message" do
      get audit_logs_path
      expect(response.body).to include('last 100 audit log entries')
    end

    it "displays empty state when no logs" do
      AuditLog.delete_all
      get audit_logs_path
      expect(response.body).to include('No Audit Logs')
    end
  end

  describe "GET /audit_logs/:id" do
    let(:person) { create(:person) }
    let!(:person_log) { create(:audit_log, auditable: person, details: 'Specific person log') }
    let!(:other_log) { create(:audit_log, details: 'Other person log') }

    it "returns http success" do
      get audit_log_path(person)
      expect(response).to have_http_status(:success)
    end

    it "displays logs for the specific person" do
      get audit_log_path(person)
      expect(response.body).to include('Specific person log')
    end

    it "does not display logs from other records" do
      get audit_log_path(person)
      expect(response.body).not_to include('Other person log')
    end

    it "displays person information" do
      get audit_log_path(person)
      expect(response.body).to include(person.first_name)
    end

    it "displays person last name" do
      get audit_log_path(person)
      expect(response.body).to include(person.last_name)
    end
  end
end

