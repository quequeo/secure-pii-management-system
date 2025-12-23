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

## 🎨 Frontend Architecture

This project uses a **modern Rails frontend stack** with Hotwire for SPA-like interactions:

### Technologies
- **Hotwire Turbo**: SPA-like navigation without full page reloads
- **Turbo Frames**: Scoped updates for specific page sections
- **Stimulus**: Lightweight JavaScript controllers for interactivity
- **ViewComponents**: Reusable, testable UI components
- **Presenters**: Separation of presentation logic from models
- **Tailwind CSS**: Utility-first CSS framework
- **Importmaps**: No build step required for JavaScript

### Key Features
- **SSN Auto-formatting**: Automatically adds dashes as user types (`123456789` → `123-45-6789`)
- **Client-side Validation**: Real-time form validation with visual feedback
- **Auto-dismissing Flash Messages**: Success/error messages fade after 5 seconds
- **Mobile Menu**: Responsive navigation with hamburger menu
- **Turbo Frame Navigation**: Seamless transitions between list and detail views
- **Responsive Design**: Mobile-first with separate desktop/mobile layouts

### Components
- **ButtonComponent**: Reusable button/link with variants (primary, secondary, danger)
- **PersonCardComponent**: Display person record in table row
- **EmptyStateComponent**: Empty state with icon and action button
- **FormFieldComponent**: Form field with label, hint, and error messages

### Presenters
- **BasePresenter**: Foundation for all presenters with view context access
- **PersonPresenter**: Encapsulates Person presentation logic (masked SSN, formatted dates, initials, etc.)

### Stimulus Controllers
- **ssn_format_controller.js**: Auto-format SSN input with dashes
- **form_validation_controller.js**: Client-side form validation
- **flash_controller.js**: Auto-dismiss flash messages
- **mobile_menu_controller.js**: Toggle mobile navigation menu

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
│   │   ├── controllers/       # Request handling (PeopleController)
│   │   ├── models/            # Data models (Person with encryption)
│   │   ├── views/             # ERB templates with Turbo Frames
│   │   ├── components/        # ViewComponents (ButtonComponent, PersonCardComponent, etc.)
│   │   ├── presenters/        # Presentation logic (BasePresenter, PersonPresenter)
│   │   ├── services/          # Business logic (SsnValidationService)
│   │   └── javascript/
│   │       ├── controllers/   # Stimulus controllers (SSN format, form validation, etc.)
│   │       └── application.js # Hotwire initialization
│   ├── spec/                  # RSpec tests (100% coverage)
│   │   ├── models/
│   │   ├── requests/
│   │   ├── services/
│   │   ├── presenters/
│   │   └── components/        # ViewComponent tests
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

### Bonus Features
**Completed ✅:**
- [x] CI/CD Pipeline (GitHub Actions) - 3 workflows
- [x] Hotwire/Turbo - SPA-like navigation with Turbo Frames
- [x] ViewComponents - Reusable UI components
- [x] Presenter Pattern - Separation of presentation logic
- [x] Stimulus Controllers - Interactive UI features
- [x] Responsive Design - Mobile-first approach

**Pending (Optional):**
- [ ] Edit/Delete functionality
- [ ] Audit logging for PII access
- [ ] Rate limiting on Java service

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

## ⏱️ Time Breakdown

**Total Time**: ~20-24 hours (distributed over 3 days)  
**Development Period**: December 21-23, 2024  
**Commits**: 71 | **PRs**: 23 | **Lines of Code**: ~2,500 (Ruby + Java)

### 1. Technical Setup & Infrastructure (~5 hours)
- **Repository setup and project structure** (0.5 hours)
  - Initial monorepo setup, .gitignore, folder structure
- **Java microservice foundation** (1.5 hours)
  - Spring Boot 3.2 setup, Maven configuration
  - SSN validation service with SSA rules implementation
  - DTOs (SsnValidationRequest, SsnValidationResponse)
- **Rails 8 application setup** (1.5 hours)
  - Rails new, RSpec configuration, PostgreSQL setup
  - ActiveRecord::Encryption configuration
  - Environment variables with dotenv-rails
- **Docker & Docker Compose** (1.5 hours)
  - Dockerfiles for Rails and Java services
  - docker-compose.yml with health checks and service dependencies
  - Debugging Alpine vs bash, volume caching issues

### 2. Core Functional Development (~6 hours)
- **Database schema and Person model** (1.5 hours)
  - Migration with proper indexes and constraints
  - Model validations (presence, format, length)
  - Custom SSN validation calling Java service
  - Encryption setup for SSN field
- **PII collection form** (2 hours)
  - PeopleController with CRUD operations
  - Form view with all required fields
  - Middle Name Override checkbox logic
  - Tailwind CSS styling
  - Error handling and display
- **Display pages and SSN masking** (1.5 hours)
  - Index view with records table
  - Show view with detailed information
  - Masked SSN implementation (`***-**-1234`)
  - Responsive design (mobile + desktop)
- **Rails-Java integration** (1 hour)
  - SsnValidationService HTTP client
  - Error handling (timeouts, connection failures)
  - Integration in Person model validation

### 3. Testing & Quality Assurance (~4 hours)
- **RSpec test suite** (2.5 hours)
  - Model specs (validations, encryption, helper methods)
  - Request specs for all controller actions
  - Service specs with WebMock for Java integration
  - Factory setup with Faker
  - Achieving 100% code coverage
- **Java tests** (1 hour)
  - JUnit 5 tests for SSN validation logic
  - Controller integration tests
  - JaCoCo configuration for coverage reporting
- **Debugging and edge cases** (0.5 hours)
  - SSN format edge cases (with/without hyphens)
  - RecordNotFound error handling
  - Presenter defensive coding

### 4. Bonus Features (~5 hours)
- **CI/CD Pipeline** (1 hour)
  - GitHub Actions workflows (Rails, Java, CI checks)
  - Coverage enforcement, security checks
  - Docker build verification
- **Frontend Modernization** (3 hours)
  - Hotwire/Turbo integration for SPA-like navigation
  - ViewComponents (Button, PersonCard, EmptyState, FormField)
  - Presenter pattern (BasePresenter, PersonPresenter)
  - Stimulus controllers (SSN format, form validation, flash, mobile menu)
  - Turbo Frames for scoped updates
- **Test Coverage Reporting** (0.5 hours)
  - SimpleCov setup and configuration
  - Coverage groups for different layers
  - 100% coverage achievement
- **Responsive Design** (0.5 hours)
  - Mobile-first approach with Tailwind
  - Separate desktop/mobile layouts

### 5. Documentation (~3 hours)
- **README.md** (1 hour)
  - Quick start guide with Docker Compose
  - Setup instructions for local development
  - Testing instructions with coverage details
  - Environment variables documentation
  - Implementation status checklist
  - Assumptions and trade-offs (Rails 8 decision)
- **ARCHITECTURE.md** (1.5 hours)
  - System architecture diagram (ASCII art)
  - Component details with responsibilities
  - Communication flow diagrams
  - Security implementation details
  - Key design decisions and rationale
  - Technology choices justification
  - 650+ lines of technical documentation
- **Code comments and inline docs** (0.5 hours)
  - Controller comments for clarity
  - Model validation explanations
  - Complex logic documentation

### 6. Refinement & Polish (~1-2 hours)
- **Code review and refactoring** (1 hour)
  - Copilot review feedback implementation
  - Controller refactoring (before_action, rescue_from)
  - Removing console.log statements
  - Presenter defensive coding improvements
- **Bug fixes and iterations** (0.5-1 hour)
  - Turbo Frame navigation fix
  - Coverage drops investigation
  - Bundler gem issues in Docker
  - Small UI/UX improvements

---

### AI Assistance Impact

**Tools Used**: Cursor IDE + Claude Sonnet 4.5

**Time Savings**: ~40-50% (estimated 35-40 hours without AI)

**AI Contributions**:
- Code generation for boilerplate (controllers, models, tests)
- Test case suggestions and edge case identification
- Documentation writing and structuring
- Debugging assistance (Docker issues, test failures)
- Best practices and security recommendations
- Architecture pattern suggestions (ViewComponents, Presenters)

**Human Contributions**:
- System design and architecture decisions
- Business logic and validation rules
- Integration strategy (Rails ↔ Java)
- Code review and quality assurance
- Documentation review and refinement
- Final testing and verification

**Working Methodology**: Small, focused PRs (23 total) with tests for each feature, allowing for iterative development and easy code review.

---

## 🤖 AI Assistance (Continued)

**Context Management**: AI context is maintained in `.cursorrules` for consistency across development sessions, including:
- Project requirements and constraints
- Coding standards (one expect per test, no section comments)
- PR/branch workflow guidelines
- Detailed project checklist with completion status

**Effectiveness**: AI was most valuable for:
- ✅ Rapid prototyping and boilerplate reduction
- ✅ Comprehensive test coverage suggestions
- ✅ Documentation structure and clarity
- ✅ Debugging complex integration issues

**Limitations**: Human oversight required for:
- ⚠️ System architecture decisions
- ⚠️ Security implementation choices
- ⚠️ Trade-off evaluation (Rails 8 vs 5.0.x)
- ⚠️ Final code review and quality assurance

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
