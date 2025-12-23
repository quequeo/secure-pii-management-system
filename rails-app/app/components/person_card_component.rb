class PersonCardComponent < ViewComponent::Base
  def initialize(person:)
    @person = person
  end

  private

  attr_reader :person
end

