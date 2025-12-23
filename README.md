# Secure PII Management System

[![Rails Tests](https://github.com/quequeo/secure-pii-management-system/actions/workflows/rails-tests.yml/badge.svg)](https://github.com/quequeo/secure-pii-management-system/actions/workflows/rails-tests.yml)
[![Java Tests](https://github.com/quequeo/secure-pii-management-system/actions/workflows/java-tests.yml/badge.svg)](https://github.com/quequeo/secure-pii-management-system/actions/workflows/java-tests.yml)
[![CI](https://github.com/quequeo/secure-pii-management-system/actions/workflows/ci.yml/badge.svg)](https://github.com/quequeo/secure-pii-management-system/actions/workflows/ci.yml)

A Rails application with Java microservice for secure collection, storage, and display of Personal Identifiable Information (PII).

> 📋 **Challenge Instructions**: See [CHALLENGE.md](CHALLENGE.md) for the original take-home challenge requirements.

---

## 🎯 Project Overview

This project demonstrates secure handling of sensitive PII data through:

- **Rails 8 Application**: Web interface for collecting and displaying PII with encrypted storage
- **Java Microservice**: SSN validation service implementing Social Security Administration (SSA) standards
- **Security First**: Encryption at rest, masking in display, secure service-to-service communication

---

## 🏗️ Architecture

```
┌─────────────────┐         HTTP REST        ┌──────────────────┐
│                 │ ◄──────────────────────► │                  │
│  Rails App      │                          │  Java Service    │
│  (Port 3000)    │   SSN Validation         │  (Port 8080)     │
│                 │                          │                  │
└────────┬────────┘                          └──────────────────┘
         │
         │ ActiveRecord
         │ (Encrypted SSN)
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   (Port 5432)   │
└─────────────────┘
```

**Components**:
- **Rails App** (`/rails-app`): Form submission, data storage, display with masking
- **Java Service** (`/java-service`): SSN validation per SSA rules
- **PostgreSQL**: Encrypted PII storage

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed design decisions, security implementation, and system architecture.

---

## 🚀 Quick Start

### Prerequisites

- **Docker & Docker Compose** (recommended)
- **OR** for local development:
  - Ruby 3.2+ and Rails 8
  - Java 17+ and Maven
  - PostgreSQL 14+
  - Node.js (for Tailwind CSS)

### Running with Docker Compose ✅

1. **Copy environment variables**:
```bash
cp .env.example .env
# Edit .env if needed (defaults should work)
```

2. **Start all services**:
```bash
docker-compose up --build
```

This will start:
- PostgreSQL (port 5432)
- Java SSN Validation Service (port 8080)
- Rails Application (port 3000)

3. **Access the application**:
```bash
open http://localhost:3000
```

4. **Stop services**:
```bash
docker-compose down
```

**Docker Compose Features**:
- ✅ Health checks for all services
- ✅ Automatic database setup (`db:prepare`)
- ✅ Service dependencies (Rails waits for Java + PostgreSQL)
- ✅ Persistent volumes for database data
- ✅ Hot-reload for Rails development

### Local Development Setup

#### 1. Java Microservice

```bash
cd java-service

# Build and run tests
mvn clean test

# Run the service
mvn spring-boot:run

# Service will be available at http://localhost:8080
```

**Endpoints**:
- `POST /api/v1/ssn/validate` - Validate SSN
- `GET /health` - Health check

#### 2. Rails Application

```bash
cd rails-app

# Install dependencies
bundle install

# Setup database (when configured)
rails db:create db:migrate

# Run tests
bundle exec rspec

# Start server
rails server

# Application will be available at http://localhost:3000
```

---

## 🧪 Running Tests

### Java Service Tests

```bash
cd java-service
mvn test

# With coverage report
mvn clean test jacoco:report
# View coverage: target/site/jacoco/index.html
```

**Current Coverage**: >70% ✅

### Rails Tests

```bash
cd rails-app

# Run all tests (coverage report auto-generated)
bundle exec rspec

# With detailed output
bundle exec rspec --format documentation

# View coverage report
open coverage/index.html
```

**Test Coverage**: 💯 **100.0%** (83/83 lines covered)  
**Test Suite**: 81 examples, 0 failures  
**Requirement**: >70% coverage ✅ (exceeds by 30%)

**Note**: SimpleCov is configured to automatically generate coverage reports on every test run.

Coverage breakdown:
- Models: 100%
- Controllers: 100%
- Services: 100%
- Views: N/A (tested via request specs)

---

## 🔒 Security Features

### Encryption at Rest
- SSN encrypted in PostgreSQL using Rails encrypted attributes
- Master key managed via Rails credentials

### Data Masking
- SSN displayed as `***-**-1234` (only last 4 digits visible)
- Masking happens in presentation layer, not in backend service

### SSN Validation (Java Service)
Per SSA standards:
- Format: `XXX-XX-XXXX`
- Area number (first 3 digits):
  - Cannot be `000` or `666`
  - `900-999` IS VALID (ITINs)
- Group number (middle 2 digits): Cannot be `00`
- Serial number (last 4 digits): Cannot be `0000`
- Rejects known invalid test SSNs

### Transport Security
- HTTPS/TLS for production (documented, not required for local dev)
- Service-to-service communication via internal network

---

## 📂 Project Structure

```
secure-pii-management-system/
├── java-service/              # Spring Boot microservice
│   ├── src/main/java/
│   │   └── com/pii/validation/
│   │       ├── controller/    # REST endpoints
│   │       ├── dto/           # Request/Response objects
│   │       └── service/       # SSN validation logic
│   ├── src/test/java/         # JUnit tests
│   ├── Dockerfile
│   └── pom.xml
│
├── rails-app/                 # Rails 8 application
│   ├── app/
│   │   ├── controllers/       # Request handling
│   │   ├── models/            # Data models (with encryption)
│   │   ├── views/             # ERB templates
│   │   └── helpers/           # View helpers (SSN masking)
│   ├── spec/                  # RSpec tests
│   ├── Dockerfile
│   └── Gemfile
│
├── .cursorrules               # AI assistant context
├── .github/
│   └── copilot-instructions.md  # PR review guidelines
├── CHALLENGE.md               # Original challenge requirements
├── README.md                  # This file
└── docker-compose.yml         # (coming soon)
```

---

## ✅ Implementation Status

### Core Features ✅ (100% Complete)
- [x] Java microservice with SSN validation (100% functional)
- [x] Unit tests for Java service (>70% coverage)
- [x] Health check endpoints
- [x] Rails 8 application setup
- [x] PostgreSQL with encryption at rest
- [x] PII data model with ActiveRecord::Encryption
- [x] PII collection form (Rails views + Tailwind CSS)
- [x] Rails ↔ Java service integration (HTTP REST)
- [x] Display page with SSN masking (`***-**-1234`)
- [x] SSN validation per SSA standards
- [x] Input validation (multi-layer: HTML5, Rails, Java)

### Infrastructure & DevOps ✅
- [x] Docker Compose orchestration (3 services)
- [x] Health checks for all services
- [x] Hot-reload development environment
- [x] CI/CD pipeline (GitHub Actions)
- [x] Automated testing on every PR

### Testing & Quality ✅
- [x] RSpec test suite (81 examples, 0 failures)
- [x] 💯 **100% code coverage** for Rails
- [x] Integration tests (Rails ↔ Java)
- [x] SimpleCov reporting
- [x] Request specs for all endpoints

### Documentation ✅
- [x] README.md with setup instructions
- [x] ARCHITECTURE.md (595 lines, technical design)
- [x] CHALLENGE.md (original requirements)
- [x] .cursorrules (AI coding guidelines)
- [x] Inline code documentation

### Bonus Features (Optional)
- [ ] Edit/Delete functionality
- [ ] Audit logging for PII access
- [ ] Rate limiting on Java service
- [ ] Hotwire/Turbo for dynamic UI

See [.cursorrules](.cursorrules) for detailed checklist.

---

## 📊 Development Approach

This project follows a **small PR methodology**:
- Each PR implements ONE focused feature
- Every PR includes tests
- PRs are reviewed for quality and security
- ~11 PRs completed so far

### PR History
1. Initial repository setup
2. Java Spring Boot structure
3. SSN validation DTOs
4. SSN validation service
5. Copilot review instructions
6. SSN validation tests
7. SSN controller & API
8. Health check endpoint
9. Java Dockerfile
10. Rails 8 setup with RSpec
11. Challenge documentation

---

## 🤖 AI Assistance

This project was developed with AI assistance (Cursor + Claude Sonnet 4.5):
- **Code Generation**: Boilerplate, tests, validation logic
- **Test Coverage**: Comprehensive test cases for SSN validation
- **Documentation**: README, comments, architectural decisions
- **Code Review**: Best practices and security considerations

Context for AI is maintained in `.cursorrules` for consistency across development sessions.

---

## 📋 Assumptions & Trade-offs

### 1. Development Environment
- Docker Compose for production-like setup, but local dev works fine
- PostgreSQL running locally for development and testing

### 2. Ruby/Rails Version: Rails 8 instead of Rails 5.0.x

**Decision**: Using **Rails 8.0.2** (latest) instead of Rails 5.0.x mentioned in challenge.

**Rationale**:
- **Security**: Rails 5.0.x reached End-of-Life (EOL) in 2020, no longer receives security patches
- **Built-in Encryption**: Rails 7+ provides `ActiveRecord::Encryption` out-of-the-box for SSN encryption
  - No need for additional gems like `attr_encrypted`
  - More secure with key rotation support
  - Simpler implementation and maintenance
- **Modern Tooling**: 
  - Better test framework support (RSpec 7.x)
  - Integrated Tailwind CSS support
  - Improved developer experience
- **Production Readiness**: Current stack is more maintainable long-term

**Trade-off**: Acknowledges the challenge mentioned Rails 5.0.x preference, but prioritizes security and modern best practices. Demonstrates ability to make informed technical decisions.

### 3. SSN Validation as Microservice
- Implemented as separate Java Spring Boot service per requirements
- Validates SSN per SSA standards before Rails saves to database
- Loose coupling allows independent scaling and updates

### 4. Encryption Strategy
- **At Rest**: Rails `encrypts :ssn` for database encryption
- **In Transit**: Documented HTTPS/TLS (not required for local dev)
- **Display**: Masking in presentation layer (`***-**-1234`)
- Encryption keys managed via Rails credentials/initializers

### 5. Testing Approach
- Focus on backend quality with >70% coverage
- RSpec for Rails, JUnit 5 for Java
- Integration tests for service-to-service communication
- Frontend tests optional (challenge stated this explicitly)

### 6. PR Workflow
- Small, focused PRs (~10-15 PRs total)
- Each PR implements one feature with tests
- Better code review, easier to track progress
- Demonstrates incremental development skills

---

## 🚀 CI/CD Pipeline

This project includes automated testing and quality checks via GitHub Actions.

### Workflows

**1. Rails Tests** (`rails-tests.yml`)
- Runs on every push/PR affecting Rails code
- PostgreSQL service for integration tests
- Executes full RSpec test suite
- Verifies 100% code coverage
- Uploads coverage artifacts

**2. Java Tests** (`java-tests.yml`)
- Runs on every push/PR affecting Java code
- Maven test execution with JUnit 5
- JaCoCo coverage reporting
- Enforces >70% coverage requirement
- Uploads coverage artifacts

**3. CI Checks** (`ci.yml`)
- Docker Compose build verification
- Security checks (no hardcoded secrets)
- Documentation completeness check
- .gitignore configuration validation

### Running Locally

Simulate CI environment:
```bash
# Run all checks
./scripts/ci-local.sh  # (optional script)

# Or manually:
cd rails-app && bundle exec rspec
cd java-service && mvn clean test
docker-compose build
```

### CI Status

All workflows must pass before merging PRs. Check status badges at the top of this README.

---

## 🛠️ Environment Variables

### For Docker Compose

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Variables (defaults work out of the box):
```bash
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=secure_pii_development

# Rails
RAILS_ENV=development

# Java Service
SPRING_PROFILES_ACTIVE=docker
```

### For Local Development

Create `rails-app/.env`:
```bash
# Java Service
JAVA_SERVICE_URL=http://localhost:8080

# Database (optional, uses defaults if not set)
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=rails_app_development
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres

# Rails
RAILS_ENV=development
```

---

## 🐛 Known Issues

- ARCHITECTURE.md documentation pending
- Code coverage metrics not yet tracked
- Production deployment configuration needed

---

## 📚 Additional Resources

- [CHALLENGE.md](CHALLENGE.md) - Original challenge requirements
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design *(coming soon)*
- [.cursorrules](.cursorrules) - Development context and checklist

---

## 📝 License

Private - For evaluation purposes only.

---

## 👤 Author

Built by Jaime as a take-home engineering challenge.
