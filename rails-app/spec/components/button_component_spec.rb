require 'rails_helper'

RSpec.describe ButtonComponent, type: :component do
  describe "rendering as link" do
    it "renders primary button link" do
      render_inline(described_class.new(text: "Click Me", href: "/path"))

      expect(page).to have_link("Click Me", href: "/path")
    end

    it "applies primary variant classes" do
      render_inline(described_class.new(text: "Click Me", href: "/path", variant: :primary))

      expect(page).to have_css("a.bg-blue-600")
    end

    it "applies secondary variant classes" do
      render_inline(described_class.new(text: "Click Me", href: "/path", variant: :secondary))

      expect(page).to have_css("a.bg-gray-200")
    end

    it "applies danger variant classes" do
      render_inline(described_class.new(text: "Click Me", href: "/path", variant: :danger))

      expect(page).to have_css("a.bg-red-600")
    end
  end

  describe "rendering as button" do
    it "renders button without href" do
      render_inline(described_class.new(text: "Submit"))

      expect(page).to have_button("Submit")
    end

    it "applies base classes" do
      render_inline(described_class.new(text: "Submit"))

      expect(page).to have_css("button.font-semibold")
    end
  end

  describe "custom classes" do
    it "merges custom classes with variant classes" do
      render_inline(described_class.new(text: "Custom", href: "/path", class: "my-custom-class"))

      expect(page).to have_css("a.my-custom-class.bg-blue-600")
    end
  end
end

