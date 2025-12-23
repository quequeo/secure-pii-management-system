class Person < ApplicationRecord
  encrypts :ssn
  
  validates :first_name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :middle_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :ssn, presence: true, format: { 
    with: /\A\d{3}-\d{2}-\d{4}\z/, 
    message: "must be in XXX-XX-XXXX format" 
  }
  validates :street_address_1, presence: true
  validates :city, presence: true
  validates :state, presence: true, format: { 
    with: /\A[A-Z]{2}\z/, 
    message: "must be a 2-letter state abbreviation" 
  }
  validates :zip_code, presence: true, format: { 
    with: /\A\d{5}\z/, 
    message: "must be a 5-digit ZIP code" 
  }

  before_validation :normalize_state

  def masked_ssn
    return nil if ssn.blank?

    "***-**-#{ssn.last(4)}"
  end

  def full_name
    [first_name, middle_name, last_name].reject(&:blank?).join(" ")
  end

  private

  def normalize_state
    self.state = state&.upcase
  end
end
