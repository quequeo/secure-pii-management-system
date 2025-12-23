class FormFieldComponent < ViewComponent::Base
  def initialize(form:, field:, label:, type: :text_field, required: false, hint: nil, **options)
    @form = form
    @field = field
    @label = label
    @type = type
    @required = required
    @hint = hint
    @options = options
  end

  private

  attr_reader :form, :field, :label, :type, :required, :hint, :options

  def field_classes
    "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border"
  end

  def has_errors?
    form.object.errors[field].any?
  end

  def error_messages
    form.object.errors[field].join(", ")
  end
end

