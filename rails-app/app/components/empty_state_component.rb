class EmptyStateComponent < ViewComponent::Base
  def initialize(title:, description:, action_text: nil, action_path: nil)
    @title = title
    @description = description
    @action_text = action_text
    @action_path = action_path
  end

  private

  attr_reader :title, :description, :action_text, :action_path
end

