module Auditable
  extend ActiveSupport::Concern

  private

  def log_view(record)
    AuditLog.log_action(
      action: 'view',
      record: record,
      user_identifier: current_user_identifier,
      request: request
    )
  end

  def log_create(record)
    AuditLog.log_action(
      action: 'create',
      record: record,
      user_identifier: current_user_identifier,
      request: request
    )
  end

  def log_update(record)
    AuditLog.log_action(
      action: 'update',
      record: record,
      user_identifier: current_user_identifier,
      request: request
    )
  end

  def log_destroy(record)
    AuditLog.log_action(
      action: 'destroy',
      record: record,
      user_identifier: current_user_identifier,
      request: request
    )
  end

  def current_user_identifier
    request.remote_ip
  end
end

