require 'rails_helper'

RSpec.describe SsnValidationService do
  let(:service) { described_class.new(java_service_url: "http://localhost:8080") }
  let(:ssn) { "123-45-6789" }
  let(:api_url) { "http://localhost:8080/api/v1/ssn/validate" }

  describe "#validate" do
    context "when SSN is valid" do
      it "returns valid true" do
        stub_request(:post, api_url)
          .with(body: { ssn: ssn }.to_json)
          .to_return(status: 200, body: { valid: true }.to_json)

        result = service.validate(ssn)
        expect(result[:valid]).to be true
      end
    end

    context "when SSN is invalid" do
      it "returns valid false with error message" do
        stub_request(:post, api_url)
          .with(body: { ssn: ssn }.to_json)
          .to_return(status: 200, body: { valid: false, errorMessage: "Area number cannot be 000" }.to_json)

        result = service.validate(ssn)
        expect(result[:valid]).to be false
      end

      it "includes the error message from Java service (legacy errorMessage)" do
        stub_request(:post, api_url)
          .with(body: { ssn: ssn }.to_json)
          .to_return(status: 200, body: { valid: false, errorMessage: "Area number cannot be 000" }.to_json)

        result = service.validate(ssn)
        expect(result[:error]).to eq("Area number cannot be 000")
      end

      it "includes error messages from Java service errors array (current format)" do
        stub_request(:post, api_url)
          .with(body: { ssn: ssn }.to_json)
          .to_return(status: 200, body: { valid: false, errors: ["Area number (first 3 digits) cannot be 000"] }.to_json)

        result = service.validate(ssn)
        expect(result[:error]).to eq("Area number (first 3 digits) cannot be 000")
      end

      it "joins multiple error messages with comma" do
        stub_request(:post, api_url)
          .with(body: { ssn: ssn }.to_json)
          .to_return(status: 200, body: { valid: false, errors: ["Error 1", "Error 2", "Error 3"] }.to_json)

        result = service.validate(ssn)
        expect(result[:error]).to eq("Error 1, Error 2, Error 3")
      end
    end

    context "when Java service returns 400 bad request" do
      it "returns valid false" do
        stub_request(:post, api_url)
          .to_return(status: 400, body: { errorMessage: "Invalid SSN format" }.to_json)

        result = service.validate(ssn)
        expect(result[:valid]).to be false
      end

      it "includes error message (legacy errorMessage)" do
        stub_request(:post, api_url)
          .to_return(status: 400, body: { errorMessage: "Invalid SSN format" }.to_json)

        result = service.validate(ssn)
        expect(result[:error]).to eq("Invalid SSN format")
      end

      it "includes error messages from errors array (current format)" do
        stub_request(:post, api_url)
          .to_return(status: 400, body: { errors: ["Invalid format"] }.to_json)

        result = service.validate(ssn)
        expect(result[:error]).to eq("Invalid format")
      end

      it "handles invalid JSON in 400 response" do
        stub_request(:post, api_url)
          .to_return(status: 400, body: "Not valid JSON")

        result = service.validate(ssn)
        expect(result[:error]).to eq("Invalid SSN format")
      end
    end

    context "when Java service is unavailable" do
      it "raises ServiceUnavailableError on connection refused" do
        stub_request(:post, api_url).to_raise(Errno::ECONNREFUSED)

        expect {
          service.validate(ssn)
        }.to raise_error(SsnValidationService::ServiceUnavailableError, /unavailable/)
      end

      it "raises ServiceUnavailableError on timeout" do
        stub_request(:post, api_url).to_timeout

        expect {
          service.validate(ssn)
        }.to raise_error(SsnValidationService::ServiceUnavailableError, /timed out/)
      end

      it "raises ServiceUnavailableError on host unreachable" do
        stub_request(:post, api_url).to_raise(Errno::EHOSTUNREACH)

        expect {
          service.validate(ssn)
        }.to raise_error(SsnValidationService::ServiceUnavailableError)
      end
    end

    context "when Java service returns unexpected response" do
      it "raises ServiceUnavailableError on 500 error" do
        stub_request(:post, api_url).to_return(status: 500)

        expect {
          service.validate(ssn)
        }.to raise_error(SsnValidationService::ServiceUnavailableError, /Unexpected response code/)
      end

      it "raises ServiceUnavailableError on invalid JSON" do
        stub_request(:post, api_url)
          .to_return(status: 200, body: "invalid json")

        expect {
          service.validate(ssn)
        }.to raise_error(SsnValidationService::ServiceUnavailableError, /Invalid JSON/)
      end
    end
  end
end

