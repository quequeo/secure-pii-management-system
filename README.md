# Secure PII Management System

A secure Rails 8 + Java microservices application for managing Personal Identifiable Information (PII) with encryption, SSN validation, and audit logging.

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

- Docker & Docker Compose (recommended)
- OR for local development: Ruby 3.2+, Java 17+, PostgreSQL 16+, Maven

### Setup from Fresh Clone

**1. Clone the repository**
```bash
git clone <repository-url>
cd secure-pii-management-system
```

**2. Setup:**

#### Docker Compose

```bash
# Copy environment variables
cp .env.example .env

# Start all services (PostgreSQL + Java + Rails)
docker-compose up --build

# Access the app
open http://localhost:3000

# Stop services
docker-compose down
```

That's it! Docker will handle everything: database setup, dependencies, and running all services.

---

## 🧪 Testing

```bash
# Rails tests
cd rails-app && bundle exec rspec

# Java tests
cd java-service && mvn test
```

**Test Results**:
- Rails: **>70% coverage**
- Java: **>70% coverage**

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
│   └── src/test/java/        # JUnit tests
│
├── rails-app/                 # Rails 8 application
│   ├── app/
│   │   ├── models/           # Person (encrypted SSN), AuditLog
│   │   ├── controllers/      # PeopleController, AuditLogsController
│   │   ├── views/            # ERB templates + Turbo Frames
│   │   ├── components/       # ViewComponents
│   │   ├── presenters/       # PersonPresenter
│   │   └── javascript/       # Stimulus controllers
│   └── spec/                 # RSpec tests
│
├── ARCHITECTURE.md            # Detailed system design
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

## 📝 Assumptions & Trade-offs

### Rails 8 vs Rails 5.0.x

**Decision**: Used Rails 8.0.4 instead of Rails 5.0.x mentioned in challenge.

**Rationale**:
- Rails 5.0.x reached EOL in 2018, no longer receives security patches
- Rails 7+ includes built-in `ActiveRecord::Encryption` (no additional gems needed)
- Modern tooling: Hotwire, importmaps, better asset pipeline
- Security and maintainability prioritized over legacy compatibility

### Other Assumptions

- Docker Compose used for development (production-ready setup)
- SSN masking in presentation layer (Rails) vs service layer (Java)
- Monorepo structure for easier coordination between services
- Focus on security over performance (encryption overhead acceptable)

---

## ⏱️ Time Breakdown

**Total**: ~20-24 hours over 3 days

### Technical Setup & Infrastructure (~5 hours)
- Repository setup, monorepo structure
- Java microservice (Spring Boot, Maven, DTOs)
- Rails 8 setup (RSpec, PostgreSQL, encryption config)
- Docker Compose (Dockerfiles, health checks, networking)

### Core Functional Development (~6 hours)
- Database schema and Person model with encryption
- PII collection form (validations, styling, error handling)
- Display pages with SSN masking
- Rails ↔ Java integration (HTTP client, error handling)

### Testing & Quality Assurance (~4 hours)
- RSpec test suite (models, requests, services, components)
- Java tests (JUnit 5, SSN validation logic, API tests)
- Achieving 99.63% coverage in Rails, >70% in Java
- Edge case testing and debugging

### Bonus Features (~5 hours)
- CI/CD pipeline (GitHub Actions workflows)
- Frontend modernization (Hotwire, ViewComponents, Stimulus)
- Audit logging implementation
- Rate limiting (Java service)
- Responsive design

### Documentation (~3 hours)
- README.md (setup, testing, assumptions)
- ARCHITECTURE.md (system design, security details)
- .env.example files

### Refinement & Polish (~1-2 hours)
- Code review and refactoring
- Bug fixes (Docker issues, integration problems)
- UI/UX improvements

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