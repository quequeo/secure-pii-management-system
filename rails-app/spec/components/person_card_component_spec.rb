require 'rails_helper'

RSpec.describe PersonCardComponent, type: :component do
  before do
    allow_any_instance_of(SsnValidationService).to receive(:validate)
      .and_return({ valid: true })
  end

  let(:person) do
    create(:person, 
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

  it "displays View icon link" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_css('a[title="View details"] i.ph-eye')
  end

  it "displays Edit icon link" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_css('a[title="Edit"] i.ph-pencil-simple')
  end

  it "displays Delete icon link" do
    render_inline(described_class.new(person: presenter))

    expect(page).to have_css('a[title="Delete"] i.ph-trash')
  end
end

