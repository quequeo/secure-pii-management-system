class AuditLog < ApplicationRecord
  ACTIONS = %w[view create update destroy].freeze

  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :auditable_type, presence: true
  validates :auditable_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_record, ->(record) { where(auditable_type: record.class.name, auditable_id: record.id) }
  scope :for_action, ->(action) { where(action: action) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Time.current.beginning_of_week) }

  def self.log_action(action:, record:, user_identifier: nil, request: nil)
    create!(
      action: action,
      auditable: record,
      user_identifier: user_identifier || 'anonymous',
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent,
      details: build_details(action, record)
    )
  end

  def self.build_details(action, record)
    case action
    when 'view'
      "Viewed #{record.class.name} ##{record.id}"
    when 'create'
      "Created #{record.class.name} ##{record.id}"
    when 'update'
      "Updated #{record.class.name} ##{record.id}"
    when 'destroy'
      "Deleted #{record.class.name} ##{record.id}"
    end
  end

  def formatted_created_at
    created_at.strftime("%B %d, %Y at %I:%M %p")
  end

  def short_user_agent
    return 'N/A' if user_agent.blank?
    
    user_agent.truncate(50)
  end
end
