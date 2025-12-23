require 'rails_helper'

RSpec.describe Auditable, type: :concern do
  let(:dummy_class) do
    Class.new do
      include Auditable
      
      attr_accessor :request

      def initialize(request)
        @request = request
      end
    end
  end

  let(:mock_request) { double('request', remote_ip: '192.168.1.100', user_agent: 'Test Agent') }
  let(:controller) { dummy_class.new(mock_request) }
  let(:person) { create(:person) }

  before do
    stub_request(:post, "http://localhost:8080/api/v1/ssn/validate")
      .to_return(status: 200, body: { valid: true }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#log_view' do
    it 'creates an audit log with view action' do
      expect {
        controller.send(:log_view, person)
      }.to change(AuditLog, :count).by(1)
    end

    it 'sets action to view' do
      controller.send(:log_view, person)
      expect(AuditLog.last.action).to eq('view')
    end

    it 'associates with the record' do
      controller.send(:log_view, person)
      expect(AuditLog.last.auditable).to eq(person)
    end
  end

  describe '#log_create' do
    it 'creates an audit log with create action' do
      expect {
        controller.send(:log_create, person)
      }.to change(AuditLog, :count).by(1)
    end

    it 'sets action to create' do
      controller.send(:log_create, person)
      expect(AuditLog.last.action).to eq('create')
    end

    it 'associates with the record' do
      controller.send(:log_create, person)
      expect(AuditLog.last.auditable).to eq(person)
    end
  end

  describe '#log_update' do
    it 'creates an audit log with update action' do
      expect {
        controller.send(:log_update, person)
      }.to change(AuditLog, :count).by(1)
    end

    it 'sets action to update' do
      controller.send(:log_update, person)
      expect(AuditLog.last.action).to eq('update')
    end

    it 'associates with the record' do
      controller.send(:log_update, person)
      expect(AuditLog.last.auditable).to eq(person)
    end
  end

  describe '#log_destroy' do
    it 'creates an audit log with destroy action' do
      expect {
        controller.send(:log_destroy, person)
      }.to change(AuditLog, :count).by(1)
    end

    it 'sets action to destroy' do
      controller.send(:log_destroy, person)
      expect(AuditLog.last.action).to eq('destroy')
    end

    it 'associates with the record' do
      controller.send(:log_destroy, person)
      expect(AuditLog.last.auditable).to eq(person)
    end
  end

  describe '#current_user_identifier' do
    it 'returns the request IP address' do
      expect(controller.send(:current_user_identifier)).to eq('192.168.1.100')
    end
  end
end

