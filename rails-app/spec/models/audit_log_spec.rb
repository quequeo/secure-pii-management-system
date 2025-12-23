require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  before do
    stub_request(:post, "http://localhost:8080/api/v1/ssn/validate")
      .to_return(status: 200, body: { valid: true }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'associations' do
    it 'belongs to auditable' do
      expect(described_class.reflect_on_association(:auditable).macro).to eq(:belongs_to)
    end

    it 'belongs to polymorphic auditable' do
      expect(described_class.reflect_on_association(:auditable).options[:polymorphic]).to be true
    end

    it 'has optional auditable association' do
      expect(described_class.reflect_on_association(:auditable).options[:optional]).to be true
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:action) }

    it { should validate_inclusion_of(:action).in_array(%w[view create update destroy]) }

    it { should validate_presence_of(:auditable_type) }

    it { should validate_presence_of(:auditable_id) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'orders by created_at descending' do
        AuditLog.delete_all
        old_log = create(:audit_log, created_at: 2.days.ago)
        recent_log = create(:audit_log, created_at: 1.hour.ago)
        expect(described_class.recent.first).to eq(recent_log)
      end

      it 'returns newest logs first' do
        AuditLog.delete_all
        old_log = create(:audit_log, created_at: 2.days.ago)
        recent_log = create(:audit_log, created_at: 1.hour.ago)
        expect(described_class.recent).to eq([recent_log, old_log])
      end
    end

    describe '.for_action' do
      it 'filters by action' do
        view_log = create(:audit_log, :view_action)
        create_log = create(:audit_log, :create_action)
        expect(described_class.for_action('view')).to include(view_log)
      end

      it 'excludes other actions' do
        view_log = create(:audit_log, :view_action)
        create_log = create(:audit_log, :create_action)
        expect(described_class.for_action('view')).not_to include(create_log)
      end
    end

    describe '.today' do
      it 'includes logs from today' do
        today_log = create(:audit_log, created_at: Time.current)
        yesterday_log = create(:audit_log, created_at: 1.day.ago)
        expect(described_class.today).to include(today_log)
      end

      it 'excludes logs from before today' do
        today_log = create(:audit_log, created_at: Time.current)
        yesterday_log = create(:audit_log, created_at: 1.day.ago)
        expect(described_class.today).not_to include(yesterday_log)
      end
    end

    describe '.this_week' do
      it 'includes logs from this week' do
        this_week_log = create(:audit_log, created_at: 1.day.ago)
        last_week_log = create(:audit_log, created_at: 8.days.ago)
        expect(described_class.this_week).to include(this_week_log)
      end

      it 'excludes logs from before this week' do
        this_week_log = create(:audit_log, created_at: 1.day.ago)
        last_week_log = create(:audit_log, created_at: 8.days.ago)
        expect(described_class.this_week).not_to include(last_week_log)
      end
    end

    describe '.for_record' do
      it 'filters by record type and id' do
        person1 = create(:person)
        person2 = create(:person)
        person1_log = create(:audit_log, auditable: person1)
        person2_log = create(:audit_log, auditable: person2)
        expect(described_class.for_record(person1)).to include(person1_log)
      end

      it 'excludes other records' do
        person1 = create(:person)
        person2 = create(:person)
        person1_log = create(:audit_log, auditable: person1)
        person2_log = create(:audit_log, auditable: person2)
        expect(described_class.for_record(person1)).not_to include(person2_log)
      end
    end
  end

  describe '.log_action' do
    let(:person) { create(:person) }
    let(:mock_request) { double('request', remote_ip: '127.0.0.1', user_agent: 'Test Browser') }

    it 'creates an audit log entry' do
      expect {
        described_class.log_action(
          action: 'view',
          record: person,
          user_identifier: 'test_user',
          request: mock_request
        )
      }.to change(described_class, :count).by(1)
    end

    it 'sets the correct action' do
      log = described_class.log_action(action: 'view', record: person, request: mock_request)
      expect(log.action).to eq('view')
    end

    it 'associates with the record' do
      log = described_class.log_action(action: 'view', record: person, request: mock_request)
      expect(log.auditable).to eq(person)
    end

    it 'captures IP address from request' do
      log = described_class.log_action(action: 'view', record: person, request: mock_request)
      expect(log.ip_address).to eq('127.0.0.1')
    end

    it 'captures user agent from request' do
      log = described_class.log_action(action: 'view', record: person, request: mock_request)
      expect(log.user_agent).to eq('Test Browser')
    end

    it 'uses anonymous when no user_identifier provided' do
      log = described_class.log_action(action: 'view', record: person, request: mock_request)
      expect(log.user_identifier).to eq('anonymous')
    end

    it 'uses provided user_identifier when given' do
      log = described_class.log_action(action: 'view', record: person, user_identifier: 'john_doe', request: mock_request)
      expect(log.user_identifier).to eq('john_doe')
    end

    it 'builds details using build_details method' do
      log = described_class.log_action(action: 'view', record: person, request: mock_request)
      expect(log.details).to eq("Viewed Person ##{person.id}")
    end
  end

  describe '.build_details' do
    let(:person) { create(:person) }

    it 'returns correct details for view action' do
      expect(described_class.build_details('view', person)).to eq("Viewed Person ##{person.id}")
    end

    it 'returns correct details for create action' do
      expect(described_class.build_details('create', person)).to eq("Created Person ##{person.id}")
    end

    it 'returns correct details for update action' do
      expect(described_class.build_details('update', person)).to eq("Updated Person ##{person.id}")
    end

    it 'returns correct details for destroy action' do
      expect(described_class.build_details('destroy', person)).to eq("Deleted Person ##{person.id}")
    end
  end

  describe '#formatted_created_at' do
    it 'formats the timestamp correctly' do
      log = create(:audit_log, created_at: Time.zone.parse('2024-01-15 14:30:00'))
      expect(log.formatted_created_at).to eq("January 15, 2024 at 02:30 PM")
    end
  end

  describe '#short_user_agent' do
    it 'returns N/A for blank user agent' do
      log = build(:audit_log, user_agent: nil)
      expect(log.short_user_agent).to eq('N/A')
    end

    it 'returns N/A for empty user agent' do
      log = build(:audit_log, user_agent: '')
      expect(log.short_user_agent).to eq('N/A')
    end

    it 'truncates long user agent to 50 characters' do
      long_agent = 'a' * 100
      log = build(:audit_log, user_agent: long_agent)
      expect(log.short_user_agent.length).to be <= 53
    end

    it 'returns short user agent as is' do
      short_agent = 'Short Browser'
      log = build(:audit_log, user_agent: short_agent)
      expect(log.short_user_agent).to eq(short_agent)
    end
  end
end
