module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_text_fields
  end

  private

  def sanitize_text_fields
    self.class.sanitizable_attributes.each do |attr|
      value = send(attr)
      next if value.nil?

      sanitized_value = sanitize_string(value)
      send("#{attr}=", sanitized_value)
    end
  end

  def sanitize_string(value)
    return value unless value.is_a?(String)

    sanitized = Rails::Html::FullSanitizer.new.sanitize(value)
    
    return value if sanitized.nil?
    
    sanitized = CGI.unescapeHTML(sanitized)
    
    sanitized = sanitized.gsub(/[<>]/, '')
    
    sanitized = sanitized.strip.squish
    
    sanitized.blank? ? '' : sanitized
  end

  class_methods do
    def sanitize_attributes(*attrs)
      @sanitizable_attributes = attrs
    end

    def sanitizable_attributes
      @sanitizable_attributes || []
    end
  end
end

