class ButtonComponent < ViewComponent::Base
  VARIANTS = {
    primary: "bg-blue-600 hover:bg-blue-700 text-white",
    secondary: "bg-gray-200 hover:bg-gray-300 text-gray-800",
    danger: "bg-red-600 hover:bg-red-700 text-white"
  }.freeze

  def initialize(text:, href: nil, variant: :primary, **html_options)
    @text = text
    @href = href
    @variant = variant
    @html_options = html_options
  end

  def call
    classes = "font-semibold py-2 px-6 rounded-lg shadow transition duration-150 ease-in-out #{variant_classes}"
    classes = "#{classes} #{@html_options[:class]}" if @html_options[:class]

    if @href
      link_to @text, @href, **@html_options.merge(class: classes)
    else
      content_tag(:button, @text, **@html_options.merge(class: classes))
    end
  end

  private

  def variant_classes
    VARIANTS[@variant] || VARIANTS[:primary]
  end
end
