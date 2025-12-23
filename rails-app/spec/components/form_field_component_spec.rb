require 'rails_helper'

RSpec.describe FormFieldComponent, type: :component do
  let(:person) { Person.new }
  let(:form_builder) do
    ActionView::Helpers::FormBuilder.new(:person, person, vc_test_controller.view_context, {})
  end

  it "renders label" do
    render_inline(described_class.new(
      form: form_builder,
      field: :first_name,
      label: "First Name"
    ))

    expect(page).to have_css("label", text: "First Name")
  end

  it "renders text field" do
    render_inline(described_class.new(
      form: form_builder,
      field: :first_name,
      label: "First Name"
    ))

    expect(page).to have_field("First Name")
  end

  it "renders hint when provided" do
    render_inline(described_class.new(
      form: form_builder,
      field: :first_name,
      label: "First Name",
      hint: "Enter your first name"
    ))

    expect(page).to have_text("Enter your first name")
  end

  it "renders error messages when field has errors" do
    person.errors.add(:first_name, "can't be blank")
    
    render_inline(described_class.new(
      form: form_builder,
      field: :first_name,
      label: "First Name"
    ))

    expect(page).to have_text("can't be blank")
  end

  it "applies required attribute when specified" do
    render_inline(described_class.new(
      form: form_builder,
      field: :first_name,
      label: "First Name",
      required: true
    ))

    expect(page).to have_css("input[required]")
  end
end

