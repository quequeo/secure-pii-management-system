class DeleteConfirmationModalComponent < ViewComponent::Base
  def initialize(title: "Delete Record", message: "Are you sure you want to delete this record?")
    @title = title
    @message = message
  end
end

