class PersonPresenter < BasePresenter
  def masked_ssn
    return "***-**-****" if model.ssn.blank?
    
    digits = model.ssn.to_s.gsub(/\D/, "")
    last_four = digits[-4, 4]
    
    return "***-**-****" if last_four.nil? || last_four.length != 4
    
    "***-**-#{last_four}"
  end

  def full_name
    [model.first_name, model.middle_name, model.last_name].reject(&:blank?).join(" ")
  end

  def full_address
    street = [model.street_address_1, model.street_address_2].reject(&:blank?).join(", ")
    "#{street}, #{model.city}, #{model.state} #{model.zip_code}"
  end

  def display_name
    "#{full_name} (#{masked_ssn})"
  end

  def initials
    [model.first_name, model.middle_name, model.last_name]
      .reject(&:blank?)
      .map { |name| name[0].upcase }
      .join
  end

  def formatted_created_at
    model.created_at.strftime("%B %d, %Y at %I:%M %p")
  end

  def has_middle_name?
    model.middle_name.present?
  end

  def address_lines
    lines = [model.street_address_1]
    lines << model.street_address_2 if model.street_address_2.present?
    lines << "#{model.city}, #{model.state} #{model.zip_code}"
    lines
  end
end

