class AuditLogsController < ApplicationController
  def index
    @audit_logs = AuditLog.recent.limit(100)
    @stats = {
      total_today: AuditLog.today.count,
      total_week: AuditLog.this_week.count,
      views: AuditLog.for_action('view').count,
      creates: AuditLog.for_action('create').count,
      updates: AuditLog.for_action('update').count,
      destroys: AuditLog.for_action('destroy').count
    }
  end

  def show
    person = Person.find(params[:id])
    @audit_logs = AuditLog.for_record(person).recent
    @person = PersonPresenter.new(person, view_context)
  end
end

