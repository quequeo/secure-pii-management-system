# Active Record Encryption Configuration
# For development and test environments only
# In production, use Rails credentials

if Rails.env.development? || Rails.env.test?
  Rails.application.config.active_record.encryption = {
    primary_key: "GzszYiIdzWQk2UFOqIwDHc062DXauklc",
    deterministic_key: "BDJkBpjs6pBcRMfkpKq4JUGySRlL4R9k",
    key_derivation_salt: "uiWwo41yLiMWRowoAdIud2Hwdp8NrRZR"
  }
end


