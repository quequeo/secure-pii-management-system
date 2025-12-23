# Secure PII Management System

[![Rails Tests](https://github.com/quequeo/secure-pii-management-system/actions/workflows/rails-tests.yml/badge.svg)](https://github.com/quequeo/secure-pii-management-system/actions/workflows/rails-tests.yml)
[![Java Tests](https://github.com/quequeo/secure-pii-management-system/actions/workflows/java-tests.yml/badge.svg)](https://github.com/quequeo/secure-pii-management-system/actions/workflows/java-tests.yml)
[![CI](https://github.com/quequeo/secure-pii-management-system/actions/workflows/ci.yml/badge.svg)](https://github.com/quequeo/secure-pii-management-system/actions/workflows/ci.yml)

A secure Rails 8 + Java microservices application for managing Personal Identifiable Information (PII) with encryption, SSN validation, and audit logging.

> 📋 **Challenge**: This is a take-home engineering challenge. See [CHALLENGE.md](CHALLENGE.md) for requirements.

---

## 🎯 Overview

**Architecture**: Rails 8 application + Java Spring Boot microservice + PostgreSQL

**Key Features**:
- ✅ SSN validation per SSA standards (Java microservice)
- ✅ Encryption at rest (ActiveRecord::Encryption)
- ✅ SSN masking in display (`***-**-1234`)
- ✅ Full CRUD with audit logging
- ✅ Responsive design with Hotwire/Turbo
- ✅ 99.63% test coverage

**Tech Stack**: Rails 8.0, Java 17, Spring Boot 3.2, PostgreSQL, Tailwind CSS, Stimulus, ViewComponents

📖 See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design.

---

## 🚀 Quick Start

### Prerequisites

Choose one option:
- **Option A**: Docker & Docker Compose (recommended)
- **Option B**: Ruby 3.2+, Java 17+, Maven, PostgreSQL 14+

### Setup from Fresh Clone

**1. Clone the repository**
```bash
git clone <repository-url>
cd secure-pii-management-system
```

**2. Choose your setup:**

#### Option A: Docker Compose (Recommended ✅)

```bash
# Copy environment variables (optional - defaults work)
cp .env.example .env

# Start all services (PostgreSQL + Java + Rails)
docker-compose up --build

# Access the app
open http://localhost:3000

# Stop services
docker-compose down
```

That's it! Docker will handle everything: database setup, dependencies, and running all services.

#### Option B: Local Development

**1. Setup Java Service (Port 8080)**
```bash
cd java-service
mvn clean install
mvn spring-boot:run
```

**2. Setup Rails App (Port 3000)**
```bash
cd rails-app

# Install dependencies
bundle install

# Configure environment
cp .env.example .env
# Edit .env and set: JAVA_SERVICE_URL=http://localhost:8080

# Setup database
rails db:create db:migrate

# Start server
rails server
```

**3. Access the app**
```bash
open http://localhost:3000
```

---

## 🧪 Testing

```bash
# Rails tests (99.63% coverage)
cd rails-app && bundle exec rspec

# Java tests (>70% coverage)
cd java-service && mvn test

# Coverage reports
open rails-app/coverage/index.html
open java-service/target/site/jacoco/index.html
```

**Test Results**:
- Rails: 279 examples, 0 failures, **99.63% coverage**
- Java: 27 tests, 0 failures, **>70% coverage**

---

## 📋 Core Features

### PII Form Fields
- First Name, Middle Name, Last Name (1-50 chars)
- Middle Name Override (checkbox for users without middle name)
- Social Security Number (XXX-XX-XXXX format, auto-formatted)
- Address (street 1, street 2, city, state, ZIP)

### SSN Validation (Java Service)
Per SSA standards:
- ✅ Format: XXX-XX-XXXX
- ✅ Area number: Not 000 or 666, allows 900-999 (ITINs)
- ✅ Group number: Not 00
- ✅ Serial number: Not 0000
- ✅ Rejects known invalid SSNs (078-05-1120, etc.)

### Security
- **Encryption**: SSN encrypted at rest using Rails ActiveRecord::Encryption
- **Masking**: SSN displayed as `***-**-1234`
- **Sanitization**: XSS prevention on all text inputs
- **Audit Logging**: All PII access tracked (view, create, update, delete)
- **Transport**: HTTPS/TLS documented for production

---

## 🏗️ Project Structure

```
.
├── java-service/              # Spring Boot microservice
│   ├── src/main/java/        # SSN validation service
│   └── src/test/java/        # JUnit tests (27 tests)
│
├── rails-app/                 # Rails 8 application
│   ├── app/
│   │   ├── models/           # Person (encrypted SSN), AuditLog
│   │   ├── controllers/      # PeopleController, AuditLogsController
│   │   ├── views/            # ERB templates + Turbo Frames
│   │   ├── components/       # ViewComponents (5 components)
│   │   ├── presenters/       # PersonPresenter (SSN masking)
│   │   └── javascript/       # Stimulus controllers (6 controllers)
│   └── spec/                 # RSpec tests (279 examples)
│
├── ARCHITECTURE.md            # Detailed system design (651 lines)
├── CHALLENGE.md               # Original requirements
└── docker-compose.yml         # Service orchestration
```

---

## ✅ Implementation Status

**Core Requirements**: 100% Complete
- [x] Rails application with PII form and display
- [x] Java microservice for SSN validation
- [x] PostgreSQL with encryption at rest
- [x] SSN masking in views
- [x] Docker Compose setup
- [x] Tests: Rails (99.63%), Java (>70%)
- [x] Documentation (README + ARCHITECTURE)

**Bonus Features**: All Implemented
- [x] Edit/Delete functionality (full CRUD)
- [x] Audit logging for PII access
- [x] Rate limiting on Java service
- [x] Hotwire/Turbo for SPA-like navigation
- [x] ViewComponents + Presenter pattern
- [x] Stimulus controllers for interactivity
- [x] Responsive design (mobile-first)
- [x] Input sanitization (XSS prevention)
- [x] CI/CD pipeline (GitHub Actions)

---

## 🛠️ Environment Variables

Both Docker and local setups come with `.env.example` files:

- **Root**: `.env.example` → For Docker Compose
- **Rails**: `rails-app/.env.example` → For local development

Default values work out of the box. Copy and customize if needed:
```bash
cp .env.example .env                    # Docker
cp rails-app/.env.example rails-app/.env  # Local dev
```

---

## 🤖 AI Assistance

**Tools Used**: Cursor IDE + Claude Sonnet 4.5

**Time Investment**: ~20-24 hours over 3 days (estimated 35-40 hours without AI)

**AI Contributions**:
- Code generation for boilerplate (controllers, models, tests)
- Test case suggestions and edge case identification
- Documentation structure and writing
- Debugging assistance (Docker, integration issues)
- Architecture pattern suggestions (ViewComponents, Presenters)

**Human Contributions**:
- System design and architecture decisions
- Business logic and SSN validation rules
- Integration strategy (Rails ↔ Java)
- Code review and quality assurance
- Final testing and verification

**Methodology**: Small, focused PRs with tests for each feature (23 PRs total).

---

## 📋 Key Decisions

### Rails 8 vs Rails 5.0.x
**Decision**: Used Rails 8.0.2 instead of Rails 5.0.x mentioned in challenge.

**Rationale**:
- Rails 5.0.x reached EOL in 2020 (no security patches)
- Rails 7+ has built-in `ActiveRecord::Encryption` (no need for attr_encrypted gem)
- Better security, modern tooling, improved developer experience
- Demonstrates ability to make informed technical decisions

---

## 📚 Additional Resources

- [CHALLENGE.md](CHALLENGE.md) - Original challenge requirements
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed system design (651 lines)
- [.cursorrules](.cursorrules) - Development guidelines and checklist

---

## 📝 License

Private - For evaluation purposes only.

---

## 👤 Author

Built by Jaime as a take-home engineering challenge demonstrating:
- Secure PII handling with encryption and masking
- Microservices architecture (Rails + Java)
- Test-driven development (99.63% coverage)
- Modern Rails patterns (Hotwire, ViewComponents, Presenters)
- Production-ready code quality

---

**Status**: ✅ Ready for submission and demo
