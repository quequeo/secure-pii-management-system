# Architecture Documentation

## System Overview

This is a secure PII (Personal Identifiable Information) management system built as a **microservices architecture** with three main components:

1. **Rails Application** - Web interface for PII collection and display
2. **Java Microservice** - SSN validation service implementing SSA standards
3. **PostgreSQL Database** - Encrypted data storage

The system emphasizes **security-first design** with encryption at rest, secure service-to-service communication, and data masking in the presentation layer.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           User's Browser                             │
│                       (HTTPS in production)                          │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ HTTP
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Rails Application (Port 3000)                    │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ Presentation Layer                                            │  │
│  │  - ERB Views (Tailwind CSS)                                   │  │
│  │  - SSN Masking (***-**-1234)                                  │  │
│  │  - Form Validation (client-side)                              │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ Controllers                                                    │  │
│  │  - PeopleController (CRUD operations)                         │  │
│  │  - Strong Parameters                                           │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ Models                                                         │  │
│  │  - Person (ActiveRecord)                                       │  │
│  │  - Validations (presence, format, length)                     │  │
│  │  - Custom Validation (calls Java service)                     │  │
│  │  - ActiveRecord Encryption (SSN)                              │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ Services                                                       │  │
│  │  - SsnValidationService (HTTP client for Java service)        │  │
│  │  - Error Handling (timeouts, connection failures)             │  │
│  └───────────────────────────────────────────────────────────────┘  │
└────────────────────────────┬──────────────┬────────────────────────┘
                             │              │
                             │              │ HTTP POST
                   ActiveRecord             │ /api/v1/ssn/validate
                             │              │
                             ▼              ▼
         ┌────────────────────────┐    ┌──────────────────────────┐
         │   PostgreSQL (5432)    │    │  Java Service (8080)     │
         │  ┌──────────────────┐  │    │  ┌───────────────────┐   │
         │  │ people table     │  │    │  │ SSN Validator     │   │
         │  │ - id             │  │    │  │ - Format check    │   │
         │  │ - first_name     │  │    │  │ - Area number     │   │
         │  │ - middle_name    │  │    │  │ - Group number    │   │
         │  │ - last_name      │  │    │  │ - Serial number   │   │
         │  │ - ssn (encrypted)│  │    │  │ - Known invalids  │   │
         │  │ - street_address │  │    │  └───────────────────┘   │
         │  │ - city           │  │    │  ┌───────────────────┐   │
         │  │ - state          │  │    │  │ REST Controller   │   │
         │  │ - zip_code       │  │    │  │ - POST validate   │   │
         │  │ - created_at     │  │    │  │ - GET health      │   │
         │  │ - updated_at     │  │    │  └───────────────────┘   │
         │  └──────────────────┘  │    └──────────────────────────┘
         │                        │         Spring Boot 3.2
         │  Encrypted at rest     │         Java 17
         └────────────────────────┘
```

---

## Component Details

### 1. Rails Application (Ruby 3.2.4 + Rails 8.0)

**Responsibilities:**
- User interface for PII data collection
- Form validation and error display
- Data persistence with encryption
- SSN masking in views
- Integration with Java validation service

**Key Files:**
- `app/models/person.rb` - ActiveRecord model with encryption
- `app/controllers/people_controller.rb` - CRUD operations
- `app/services/ssn_validation_service.rb` - Java service HTTP client
- `app/views/people/*.html.erb` - UI templates
- `config/initializers/active_record_encryption.rb` - Encryption config

**Dependencies:**
- `pg` - PostgreSQL adapter
- `tailwindcss-rails` - CSS framework
- Built-in ActiveRecord::Encryption (Rails 7.0+)
- `turbo-rails` - Hotwire Turbo for SPA-like navigation
- `stimulus-rails` - JavaScript sprinkles for interactive components
- `view_component` - Reusable, testable UI components

**Frontend Architecture:**

The application uses a **modern Rails frontend stack** with the following layers:

1. **Presentation Layer (Views):**
   - ERB templates with Turbo Frames
   - Server-rendered HTML
   - Responsive design with Tailwind CSS

2. **Component Layer (ViewComponents):**
   - `ButtonComponent` - Reusable buttons/links with variants
   - `PersonCardComponent` - Person record display in tables
   - `EmptyStateComponent` - Empty state UI with icon and CTA
   - `FormFieldComponent` - Form fields with labels and errors
   - All components have dedicated RSpec tests

3. **Presenter Layer:**
   - `BasePresenter` - Foundation with view context access
   - `PersonPresenter` - Person display logic (masked SSN, formatted dates, initials)
   - Keeps models clean and testable
   - Separates business logic from presentation logic

4. **Interactive Layer (Stimulus Controllers):**
   - `ssn_format_controller.js` - Auto-format SSN with dashes
   - `form_validation_controller.js` - Real-time validation
   - `flash_controller.js` - Auto-dismiss messages
   - `mobile_menu_controller.js` - Responsive navigation

5. **Navigation Layer (Turbo):**
   - Turbo Frames for scoped updates (`people_list`, `person_#{id}`)
   - SPA-like navigation without full page reloads
   - Progressive enhancement (works without JS)

**Why this architecture?**
- **Separation of Concerns**: Views, components, presenters, and controllers each have a single responsibility
- **Testability**: Each layer can be tested in isolation
- **Reusability**: Components and presenters are reusable across views
- **Maintainability**: Changes to presentation logic don't affect models
- **Modern Rails**: Uses Rails 8 conventions with Hotwire
- **Progressive Enhancement**: Works without JavaScript, enhanced with it

---

### 2. Java Microservice (Java 17 + Spring Boot 3.2)

**Responsibilities:**
- SSN validation per SSA standards
- Lightweight REST API
- Health check endpoint

**Validation Rules (SSA Standards):**
- Format: `XXX-XX-XXXX` (9 digits with dashes)
- Area number (first 3): Cannot be `000` or `666`, allows `900-999` (ITINs)
- Group number (middle 2): Cannot be `00`
- Serial number (last 4): Cannot be `0000`
- Rejects known invalid test SSNs (`078-05-1120`, `219-09-9999`, `457-55-5462`)

**Endpoints:**
- `POST /api/v1/ssn/validate` - Validate SSN format and rules
- `GET /health` - Service health check

**Key Files:**
- `src/main/java/.../service/SsnValidationService.java` - Core logic
- `src/main/java/.../controller/SsnValidationController.java` - REST API
- `src/main/java/.../controller/HealthController.java` - Health endpoint

---

### 3. PostgreSQL Database (Version 16)

**Database:** `secure_pii_development` (dev), `rails_app_test` (test)

**Schema:**

```sql
CREATE TABLE people (
  id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50),
  last_name VARCHAR(50) NOT NULL,
  ssn TEXT NOT NULL,  -- Encrypted by Rails
  street_address_1 VARCHAR(255) NOT NULL,
  street_address_2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(2) NOT NULL,
  zip_code VARCHAR(5) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_people_on_last_name ON people (last_name);
CREATE INDEX index_people_on_created_at ON people (created_at);
```

**Encryption:**
- SSN field is encrypted using Rails' `ActiveRecord::Encryption`
- Encryption keys stored in `config/initializers/active_record_encryption.rb` (dev/test)
- Production keys should be managed via Rails credentials (`rails credentials:edit`)

**Why no SSN index?**
The SSN field is encrypted, making it unsuitable for database indexing. Queries by SSN would require decryption of all records (impractical). SSN is primarily used for validation during creation, not for lookups.

---

## Communication Flow

### Data Collection Flow (Create Person)

```
1. User fills form → 2. Browser validation → 3. Submit to Rails
                                                      ↓
                                          4. PeopleController#create
                                                      ↓
                                          5. Person.new(params)
                                                      ↓
                                          6. Model validations run
                                                      ↓
                                 7. Custom validation: ssn_must_be_valid_per_ssa_standards
                                                      ↓
                             8. SsnValidationService.new.validate(ssn)
                                                      ↓
                             9. HTTP POST to Java service
                                http://java-service:8080/api/v1/ssn/validate
                                { "ssn": "123-45-6789" }
                                                      ↓
                            10. Java validates against SSA rules
                                                      ↓
                            11. Returns JSON response
                                { "valid": true/false, "errors": [...] }
                                                      ↓
                            12. Rails receives response
                                                      ↓
                    ┌───────────────────────────────┴────────────────────────────┐
                    │                                                             │
              valid: true                                                   valid: false
                    │                                                             │
                    ▼                                                             ▼
        13. Encrypt SSN with ActiveRecord                        Add error to person.errors
                    ↓                                                             ↓
        14. Save to PostgreSQL                                  Return to form with errors
                    ↓                                                             ↓
        15. Redirect to index                                   Render form (422 status)
                    ↓
        16. Display masked SSN (***-**-1234)
```

### Data Display Flow

```
1. GET /people → 2. PeopleController#index
                                ↓
                    3. Person.all (from DB)
                                ↓
                    4. Rails auto-decrypts SSN
                                ↓
                    5. Render index view
                                ↓
                    6. Helper method: person.masked_ssn
                                ↓
                    7. Display: ***-**-1234 (only last 4 visible)
```

---

## Security Implementation

### 1. Encryption at Rest

**Implementation:** Rails `ActiveRecord::Encryption` (built-in since Rails 7.0)

```ruby
# app/models/person.rb
encrypts :ssn
```

**Configuration:**
```ruby
# config/initializers/active_record_encryption.rb
ActiveRecord::Encryption.configure(
  primary_key: ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"],
  deterministic_key: ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"],
  key_derivation_salt: ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"]
)
```

**How it works:**
- SSN is encrypted before being written to the database
- Automatically decrypted when read from database
- Uses AES-256-GCM encryption
- Keys are unique per environment (dev/test/prod)

**Storage:**
- Development/Test: Keys in `config/initializers/` (committed, not sensitive)
- Production: Keys should be in Rails credentials or environment variables (not committed)

---

### 2. Encryption in Transit

**Current Implementation (Development):**
- Rails ↔ Java: HTTP (internal service-to-service within Docker network)
- Browser ↔ Rails: HTTP (localhost development)

**Production Recommendations:**
- Enable HTTPS/TLS for all external traffic (browser ↔ Rails)
- Consider mTLS for service-to-service communication (Rails ↔ Java)
- Use environment variables for service URLs to support HTTPS endpoints

**Network Security in Docker:**
- All services communicate over a private Docker network (`pii-network`)
- Java service is not exposed to the internet, only to Rails
- Only Rails app is exposed to the host machine (port 3000)

---

### 3. Data Masking (Presentation Layer)

**Implementation:**
```ruby
# app/models/person.rb
def masked_ssn
  return "***-**-****" if ssn.blank?

  "***-**-#{ssn.split('-').last}"
end
```

**Why in Rails, not Java?**
- Java service is an internal service, not user-facing
- Masking is a UI concern (presentation layer)
- Java returns full validation results for security checks
- Rails decides what to show to the user

**Display:**
- Original: `123-45-6789`
- Masked: `***-**-6789`
- Only last 4 digits visible in all views

---

### 4. Input Validation (Defense in Depth)

**Multiple layers:**
1. **Browser (HTML5):** Format validation, required fields
2. **Rails (Model):** Presence, length, format validations
3. **Java Service:** SSA standards validation
4. **Database:** NOT NULL constraints, length limits

This multi-layered approach ensures data integrity even if one layer fails.

---

## Key Design Decisions

### 1. Why Rails 8 instead of Rails 5.0.x?

**Decision:** Use Rails 8.0.4 (latest stable)

**Rationale:**
- **Built-in encryption**: Rails 7.0+ includes `ActiveRecord::Encryption` (no gems needed)
- **Security updates**: Rails 5.0.x reached EOL in 2018, no security patches
- **Modern tooling**: Better asset pipeline, importmaps, Tailwind CSS support
- **Developer experience**: Improved error messages, faster tests, better debugging
- **Production readiness**: ActiveRecord::Encryption is production-tested in Rails 7+

**Trade-offs:**
- Challenge mentioned Rails 5.0.x preference, but security and maintainability took priority
- Documented in README.md as a key decision

---

### 2. Why Microservices Architecture?

**Decision:** Separate Java service for SSN validation

**Rationale:**
- **Separation of concerns**: Validation logic isolated from data persistence
- **Language expertise**: SSN validation rules can be owned by Java team
- **Scalability**: Java service can be scaled independently
- **Reusability**: Other services could consume SSN validation
- **Testing**: Validation logic can be tested in isolation

**Trade-offs:**
- Increased complexity (network calls, error handling)
- Latency overhead (~10-50ms per validation)
- More infrastructure to manage (Docker Compose helps)

---

### 3. Why PostgreSQL with Encrypted Attributes?

**Decision:** PostgreSQL + Rails encryption (not database-level encryption)

**Rationale:**
- **Application-level encryption**: Data encrypted before reaching database
- **Transparent to queries**: Rails handles encryption/decryption automatically
- **Key management**: Keys managed by application (not DBA)
- **Flexibility**: Can selectively encrypt fields
- **Portability**: Not tied to PostgreSQL-specific encryption features

**Alternative considered:**
- PostgreSQL `pgcrypto` extension - Rejected because:
  - Requires database-level key management
  - Less portable across databases
  - Rails built-in solution is simpler

---

### 4. Why Not Indexing SSN?

**Decision:** No database index on `ssn` column

**Rationale:**
- SSN is encrypted, making database indexes useless
- Encrypted values are random, can't use `WHERE ssn = '...'` efficiently
- SSN is not used for lookups (only for validation during creation)
- Indexing would expose metadata (record distribution)

**Alternatives:**
- Deterministic encryption (allows indexing) - Rejected because:
  - Less secure (same input = same encrypted output)
  - Vulnerable to frequency analysis attacks
  - Not needed for this use case

---

### 5. Why Monorepo Structure?

**Decision:** Single repository with `/rails-app` and `/java-service`

**Rationale:**
- **Simplicity**: Easier to coordinate changes across services
- **Atomic commits**: Changes to both services in one PR
- **Shared documentation**: README, ARCHITECTURE.md in one place
- **Docker Compose**: Easier to orchestrate all services
- **Development workflow**: Clone once, see everything

**Trade-offs:**
- Larger repository size
- All developers see all code (not a concern for this project)

---

## Technology Choices

### Backend - Rails

| Technology | Version | Why? |
|------------|---------|------|
| Ruby | 3.2.4 | Latest stable, good performance, broad gem ecosystem |
| Rails | 8.0.4 | Built-in encryption, modern features, security updates |
| PostgreSQL | 16 | Robust, reliable, strong Rails support |
| RSpec | 7.1 | Industry standard for Rails testing |

### Backend - Java

| Technology | Version | Why? |
|------------|---------|------|
| Java | 17 | LTS release, modern language features |
| Spring Boot | 3.2.0 | Standard for Java microservices, minimal boilerplate |
| Maven | 3.9 | Reliable dependency management |
| JUnit | 5 | Modern testing framework |

### Frontend

| Technology | Version | Why? |
|------------|---------|------|
| ERB Templates | Built-in | Server-rendered views (challenge requirement) |
| Hotwire Turbo | 2.0 | SPA-like navigation without full page reloads |
| Stimulus | 1.3 | Lightweight JavaScript for interactive components |
| ViewComponent | 4.0 | Reusable, testable UI components |
| Tailwind CSS | 4.1 | Utility-first CSS, rapid prototyping |
| Importmaps | Built-in | No build step for JavaScript (Rails 8 default) |

### Infrastructure

| Technology | Version | Why? |
|------------|---------|------|
| Docker | Latest | Consistent environments, easy deployment |
| Docker Compose | v2 | Multi-service orchestration |
| Alpine Linux | 3.x | Small image size for Rails container |

---

## Testing Strategy

### Rails Tests (RSpec)

**Coverage:** 💯 **100%** (81 specs, all passing) - Exceeds 70% requirement by 30%

**Test types:**
- **Model specs:** Validations, encryption, helper methods
- **Request specs:** Controller actions, HTTP responses, error handling
- **Service specs:** Java service integration (with WebMock)
- **Component specs:** ViewComponent rendering and behavior (with Capybara)
- **Presenter specs:** Presentation logic, formatted output, edge cases
- **Factory specs:** Test data generation with Faker

**Key test patterns:**
- One `expect` per `it` block (clear, focused tests)
- `before` blocks for stubbing external services
- Integration tests mock HTTP calls to Java service
- Component tests use `render_inline` from ViewComponent::TestHelpers
- Presenter tests verify view_context integration

### Java Tests (JUnit 5)

**Coverage:** >70% (unit + integration tests)

**Test types:**
- **Unit tests:** SSN validation logic (all SSA rules)
- **Integration tests:** REST API endpoints
- **Health check tests:** Service availability

---

## Performance Considerations

### Current Performance

- **Java service startup:** ~1 second
- **Rails startup:** ~15 seconds (includes DB prep + Tailwind build)
- **SSN validation latency:** ~10-50ms (HTTP call to Java)
- **Form submission:** ~200-500ms (validation + encryption + DB write)

### Optimizations Implemented

1. **Docker layer caching:** Dependencies cached separately from code
2. **Database indexes:** `last_name` and `created_at` for common queries
3. **Health checks:** Prevent routing to unhealthy services
4. **Connection pooling:** Rails DB pool (5 connections by default)

### Future Optimizations (if needed)

- **Caching:** Redis for validated SSNs (short TTL)
- **Batch validation:** Validate multiple SSNs in one request
- **CDN:** Serve static assets from CDN in production
- **Database read replicas:** Scale read operations

---

## Deployment Considerations

### Docker Compose (Development)

**Current setup:**
- Single-command startup: `docker-compose up`
- Auto database setup
- Hot-reload for Rails code changes
- Health checks for all services

### Production Recommendations

1. **Container orchestration:** Kubernetes or Docker Swarm
2. **Database:** Managed PostgreSQL (AWS RDS, Azure Database)
3. **Secrets management:** AWS Secrets Manager, HashiCorp Vault
4. **Monitoring:** Prometheus + Grafana, DataDog, New Relic
5. **Logging:** Centralized logging (ELK stack, Splunk)
6. **SSL/TLS:** Let's Encrypt certificates, AWS ALB
7. **CI/CD:** GitHub Actions, Jenkins, GitLab CI

---

## Future Enhancements

### Completed ✅

- [x] Docker Compose orchestration
- [x] Rails-Java integration
- [x] Encrypted storage
- [x] ARCHITECTURE.md (this document - 650+ lines)
- [x] Code coverage reporting (SimpleCov) - 100%
- [x] CI/CD pipeline (GitHub Actions)
- [x] Hotwire/Turbo for dynamic UI updates
- [x] SSN format auto-formatting (add dashes as user types)
- [x] ViewComponents architecture
- [x] Presenter pattern implementation
- [x] Stimulus controllers for interactivity
- [x] Responsive design (mobile + desktop)

### Bonus Features (Pending - Optional)

- [ ] Edit/Delete functionality for records
- [ ] Audit logging (who accessed which SSN, when)
- [ ] Rate limiting on Java service
- [ ] API authentication (JWT, OAuth)
- [ ] Multi-factor authentication for users
- [ ] Bulk import (CSV upload)
- [ ] Export functionality (with masking)
- [ ] Advanced search and filtering

---

## Maintenance and Operations

### Monitoring Endpoints

- **Rails:** `GET /up` - Health check (database connectivity)
- **Java:** `GET /health` - Service status
- **PostgreSQL:** Docker health check with `pg_isready`

### Logs

- **Rails:** `log/development.log`, Docker logs
- **Java:** Spring Boot console output, Docker logs
- **PostgreSQL:** Docker logs

### Backup Strategy (Production)

1. **Database:** Automated daily backups, 30-day retention
2. **Encryption keys:** Secure backup in vault, offline copy
3. **Code:** Git repository (already versioned)

---

## Security Checklist

- [x] SSN encrypted at rest
- [x] SSN masked in UI (only last 4 digits)
- [x] Input validation (client + server + service)
- [x] SQL injection prevention (ActiveRecord ORM)
- [x] XSS prevention (Rails auto-escaping)
- [x] CSRF protection (Rails built-in)
- [x] Strong parameters (Rails controller)
- [x] No secrets in git (`.gitignore` for `.env`)
- [x] Health checks for all services
- [x] Error handling with custom exceptions
- [ ] HTTPS/TLS (recommended for production)
- [ ] Rate limiting (recommended for production)
- [ ] Audit logging (optional enhancement)

---

## References

- [Rails ActiveRecord Encryption](https://guides.rubyonrails.org/active_record_encryption.html)
- [SSA SSN Randomization](https://www.ssa.gov/employer/randomization.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Spring Boot Best Practices](https://spring.io/guides)

---

**Document Version:** 1.0  
**Last Updated:** December 2024  
**Maintained By:** Project Team

