# Engineering Take-Home Challenge: Secure PII Management System (Rails Edition)

## Overview
Build a Rails application with a Java microservice that securely collects, stores, and displays Personal Identifiable Information (PII). This challenge tests your ability to work with security best practices, microservices architecture, and modern Rails development.

---

## Technical Requirements

### Backend Services

You'll need to build **TWO** separate backend services:

#### 1. Ruby on Rails Application
- RESTful API for PII management
- Simple web interface using Rails views (ERB templates)
- PostgreSQL database with encrypted storage
- Integration with Java service for SSN validation
- Secure encryption for SSN at rest using Rails encrypted attributes or attr_encrypted gem
- Our current stack is Rails 5.0.x and Ruby 2.7.x. It is not required to use these versions, but welcomed should you choose the challenge.

#### 2. Java Microservice
- Lightweight service for SSN validation
- Exposes REST endpoints consumed by the Rails application
- Handles SSN format validation per SSA standards

### Frontend
- Rails views
- Tailwind CSS or Bootstrap for basic styling
- **No React** - Keep it simple with server-rendered views
- Functional design over beauty

### Database
- PostgreSQL
- Proper indexing and constraints
- Encrypted fields for sensitive data

---

## Functional Requirements

### 1. PII Data Collection Form
Create a Rails form that collects:
- **First Name** (required, 1-50 characters)
- **Middle Name** (required, 1-50 characters)
- **Middle Name Override** (checkbox for users without a middle name)
- **Last Name** (required, 1-50 characters)
- **Social Security Number** (required, format: XXX-XX-XXXX)
- **Current Address** (required)
  - Street Address 1
  - Street Address 2 (optional)
  - City
  - State (dropdown or text, 2-letter abbreviation)
  - ZIP Code (5 digits)

### 2. SSN Validation Requirements
**Java microservice** implements validation per SSA standards:
- Must be 9 digits in XXX-XX-XXXX format
- Area number (first 3 digits) cannot be 000 or 666
- Area number may allow 900-999
- Group number (middle 2 digits) cannot be 00
- Serial number (last 4 digits) cannot be 0000
- Must not be a known invalid test SSN (e.g., 078-05-1120)

**Rails application** calls Java service for validation before saving.

### 3. Security Requirements
- **In Transit**: Document HTTPS/TLS configuration (implementation not required locally)
- **At Rest**: Encrypt SSN in PostgreSQL using Rails encryption features
- **Display**: Show SSN as `***-**-1234` (only last 4 digits visible)
- **Encryption**: Handled by Rails (not Java service)

### 4. Display Page
Create a simple Rails view that shows:
- All submitted records in a table
- Full names displayed normally
- SSN obfuscated (show last 4 only)
- Full address displayed
- Basic CRUD operations: Create, Read (no Update/Delete required unless time permits)

---

## Testing Requirements

### Ruby on Rails Tests (RSpec recommended)
- Model validations
- Controller specs or request specs
- Integration tests for Java service communication
- Test encryption/decryption functionality
- **Minimum: >70% code coverage**

### Java Tests (JUnit)
- Unit tests for SSN validation logic
- API endpoint tests
- **Minimum: >70% code coverage**

### Frontend Tests
- **Optional** - Focus on backend quality
- If included, basic feature specs using Capybara are sufficient

---

## Deliverables

### 1. GitHub Repository Structure
```
/rails-app          # Rails application (views + API)
/java-service       # Java microservice
README.md           # Setup instructions
ARCHITECTURE.md     # Brief architecture overview
.env.example        # Environment variables template
docker-compose.yml  # REQUIRED - for easy setup
```

### 2. Documentation (README.md)
Include:
- Quick start guide using Docker Compose
- Setup instructions for both services
- Database setup and migration commands
- How to run the application
- How to run tests
- Any assumptions or trade-offs made
- Self-assessed time breakdown (Technical, Functional, Testing)
- We are fans of using AI as an assistant and force multiplier. You should feel free to use it as you see fit. **If you do, please document your use and experience.**

### 3. ARCHITECTURE.md
Brief overview including:
- System architecture diagram (text-based ASCII art is fine)
- How Rails communicates with Java service
- Security implementation details
- Database schema
- Key design decisions and rationale

---

## Submission

1. **Repository**: Push to a public GitHub repository
2. **Access**: Ensure repository is public and accessible
3. **Docker**: Verify `docker-compose up` starts everything
4. **Notification**: Send repository link when complete
5. **Demo**: Be prepared to walk through your code and run the application

---

## Questions?

This is an at-home challenge - part of the evaluation is your ability to make reasonable decisions independently. However:
- **Ambiguous requirements**: Document your assumptions in README.md
- **Technical blockers**: Note them in your documentation
- **Scope concerns**: Implement core features first, note future improvements

---

## Bonus Points (Optional - Only if time permits)

- Docker Compose with health checks and proper service dependencies
- Hotwire/Turbo for dynamic UI updates if using modern RoR versions
- Edit/Delete functionality for records
- Input sanitization and XSS prevention
- Audit logging for PII access
- API rate limiting on Java service
- CI/CD pipeline configuration (GitHub Actions)

---

**Remember: Working, well-tested code is better than feature-complete but broken code. We'd rather see excellent execution on core features than rushed implementation of everything. Good luck!**

