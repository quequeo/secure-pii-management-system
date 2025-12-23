class SsnValidationService
  class ValidationError < StandardError; end
  class ServiceUnavailableError < StandardError; end

  DEFAULT_JAVA_SERVICE_URL = "http://localhost:8080".freeze

  def initialize(java_service_url: nil)
    @java_service_url = java_service_url || ENV["JAVA_SERVICE_URL"] || DEFAULT_JAVA_SERVICE_URL
  end

  def validate(ssn)
    response = make_request(ssn)
    handle_response(response)
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
    raise ServiceUnavailableError, "SSN validation service is unavailable: #{e.message}"
  rescue Timeout::Error
    raise ServiceUnavailableError, "SSN validation service timed out"
  end

  private

  def make_request(ssn)
    uri = URI("#{@java_service_url}/api/v1/ssn/validate")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 5
    
    request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
    request.body = { ssn: ssn }.to_json
    
    http.request(request)
  end

  def handle_response(response)
    case response.code.to_i
    when 200
      parse_success_response(response)
    when 400
      parse_error_response(response)
    else
      raise ServiceUnavailableError, "Unexpected response code: #{response.code}"
    end
  end

  def parse_success_response(response)
    data = JSON.parse(response.body)
    
    if data["valid"]
      { valid: true }
    else
      { valid: false, error: data["errorMessage"] || "Invalid SSN" }
    end
  rescue JSON::ParserError => e
    raise ServiceUnavailableError, "Invalid JSON response: #{e.message}"
  end

  def parse_error_response(response)
    data = JSON.parse(response.body)
    { valid: false, error: data["errorMessage"] || "Invalid SSN format" }
  rescue JSON::ParserError
    { valid: false, error: "Invalid SSN format" }
  end
end

