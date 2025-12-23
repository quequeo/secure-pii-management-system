require 'rails_helper'

RSpec.describe PersonCardComponent, type: :component do
  let(:person) do
    build(:person, 
      first_name: "John", 
      middle_name: "Michael", 
      last_name: "Doe",
      created_at: Time.zone.parse("2024-01-15 14:30:00")
    )
  end
  let(:presenter) { PersonPresenter.new(person) }

  it "renders person card" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_text("John Michael Doe")
  end

  it "displays initials" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_text("JMD")
  end

  it "displays masked SSN" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_text(presenter.masked_ssn)
  end

  it "displays city and state" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_text("#{person.city}, #{person.state}")
  end

  it "displays View Details link" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_link("View Details")
  end
end

