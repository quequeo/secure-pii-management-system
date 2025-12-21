# Copilot Review Instructions

## Project Context

This is a take-home challenge for a job application. The project is a **Secure PII Management System** consisting of:

- **Rails application**: Web interface for collecting and displaying PII data
- **Java microservice**: SSN validation service per SSA standards

## Key Requirements

### SSN Validation Rules (Java Service)
- Format: XXX-XX-XXXX (9 digits with dashes)
- Area number (first 3 digits) cannot be 000 or 666
- Area number 900-999 is VALID (used for ITINs)
- Group number (middle 2 digits) cannot be 00
- Serial number (last 4 digits) cannot be 0000
- Must reject known invalid SSNs (078-05-1120, 219-09-9999, 457-55-5462)

### Security
- SSN is encrypted at rest in PostgreSQL (Rails handles this)
- SSN masking (***-**-1234) happens in the Rails presentation layer, NOT in the Java service
- The Java service is an internal service-to-service API, not exposed to end users

### Architecture
- Monorepo with `/rails-app` and `/java-service` folders
- Services communicate via HTTP REST
- Docker Compose orchestrates all services

## Review Guidelines

- This is a learning project with small, incremental PRs
- Each PR should have a single, focused purpose
- Each PR should include tests for the code being added
- Rails uses RSpec for testing
- Java uses JUnit 5 for testing