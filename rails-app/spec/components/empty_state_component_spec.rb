require 'rails_helper'

RSpec.describe EmptyStateComponent, type: :component do
  it "renders title" do
    render_inline(described_class.new(title: "No Records", description: "Get started"))

    expect(page).to have_text("No Records")
  end

  it "renders description" do
    render_inline(described_class.new(title: "No Records", description: "Get started"))

    expect(page).to have_text("Get started")
  end

  it "renders action link when provided" do
    render_inline(described_class.new(
      title: "No Records",
      description: "Get started",
      action_text: "Create New",
      action_path: "/new"
    ))

    expect(page).to have_link("Create New", href: "/new")
  end

  it "does not render action link when not provided" do
    render_inline(described_class.new(title: "No Records", description: "Get started"))

    expect(page).not_to have_css("a")
  end
end

