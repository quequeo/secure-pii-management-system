require "rails_helper"

RSpec.describe DeleteConfirmationModalComponent, type: :component do
  it "renders modal with default title" do
    render_inline(described_class.new)

    expect(page).to have_content("Delete Record")
  end

  it "renders modal with custom title" do
    render_inline(described_class.new(title: "Custom Title"))

    expect(page).to have_content("Custom Title")
  end

  it "renders modal with default message" do
    render_inline(described_class.new)

    expect(page).to have_content("Are you sure you want to delete this record?")
  end

  it "renders modal with custom message" do
    render_inline(described_class.new(message: "Custom message"))

    expect(page).to have_content("Custom message")
  end

  it "renders Delete button" do
    render_inline(described_class.new)

    expect(page).to have_button("Delete")
  end

  it "renders Discard button" do
    render_inline(described_class.new)

    expect(page).to have_button("Discard")
  end

  it "has modal controller attached" do
    render_inline(described_class.new)

    expect(page).to have_css('[data-controller="modal"]')
  end

  it "renders warning icon" do
    render_inline(described_class.new)

    expect(page).to have_css('.ph-warning')
  end

  it "renders close button with X icon" do
    render_inline(described_class.new)

    expect(page).to have_css('.ph-x')
  end

  it "has hidden class by default" do
    render_inline(described_class.new)

    expect(page).to have_css('#delete-modal.hidden')
  end

  it "displays warning about irreversible action" do
    render_inline(described_class.new)

    expect(page).to have_content("This action cannot be undone")
  end
end

