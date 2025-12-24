# Architecture Documentation

## System Overview

Microservices architecture for secure PII management:

- **Rails 8** - Web interface (collection + display)
- **Java Spring Boot** - SSN validation per SSA standards
- **PostgreSQL** - Encrypted data storage

---

## Architecture Diagram

```
┌──────────────────┐
│  User Browser    │
└────────┬─────────┘
         │ HTTP
         ▼
┌────────────────────────────────────┐
│   Rails App (Port 3000)            │
│  • ERB Views + Tailwind CSS        │
│  • Person Model (validations)      │
│  • ActiveRecord Encryption         │
└─────┬──────────────┬───────────────┘
      │              │
      │ ActiveRecord │ HTTP POST /api/v1/ssn/validate
      ▼              ▼
┌─────────────┐  ┌──────────────────┐
│ PostgreSQL  │  │  Java Service    │
│ (Port 5432) │  │  (Port 8080)     │
│             │  │                  │
│ • people    │  │ • SSN Validator  │
│   - ssn     │  │ • SSA Rules      │
│   (encrypted)  │                  │
└─────────────┘  └──────────────────┘
```

---

## Components

### 1. Rails Application

**Stack**: Ruby 3.2 + Rails 8.0 + PostgreSQL 16

**Responsibilities**:
- PII collection form with validations
- SSN encryption (ActiveRecord::Encryption)
- Integration with Java validation service
- SSN masking in UI (`***-**-1234`)

**Frontend**: ERB + Tailwind CSS + Hotwire Turbo + Stimulus + ViewComponents

---

### 2. Java Microservice

**Stack**: Java 17 + Spring Boot 3.2

**Responsibility**: SSN validation per SSA standards

**Endpoints**:
- `POST /api/v1/ssn/validate` - Validate SSN
- `GET /health` - Health check

---

### 3. Database Schema

```sql
CREATE TABLE people (
  id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50),
  last_name VARCHAR(50) NOT NULL,
  ssn TEXT NOT NULL,              -- Encrypted by Rails
  street_address_1 VARCHAR(255) NOT NULL,
  street_address_2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(2) NOT NULL,
  zip_code VARCHAR(5) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_people_on_last_name ON people (last_name);
```

**Note**: No index on `ssn` (encrypted values are random).

---

## Communication Flow: Rails ↔ Java

**SSN Validation Flow**:

1. User submits form → Rails `PeopleController#create`
2. Rails `Person` model validation triggers
3. `SsnValidationService` makes HTTP POST to Java:
   ```
   POST http://java-service:8080/api/v1/ssn/validate
   Body: { "ssn": "123-45-6789" }
   ```
4. Java validates against SSA rules
5. Java returns: `{ "valid": true/false, "errors": [...] }`
6. If valid: Rails encrypts SSN → saves to DB → displays masked
7. If invalid: Rails adds errors → re-renders form

---

## Security Implementation

### 1. Encryption at Rest

Rails `ActiveRecord::Encryption` (AES-256-GCM):

```ruby
# app/models/person.rb
encrypts :ssn
```

Keys managed via Rails credentials (production) or environment variables (development).

### 2. Data Masking

```ruby
def masked_ssn
  "***-**-#{ssn.split('-').last}"
end
```

Display: `***-**-6789` (only last 4 digits visible in all views)

### 3. Multi-layer Validation

1. **Browser**: HTML5 format validation
2. **Rails**: Presence, format, length validations
3. **Java**: SSA standards validation
4. **Database**: NOT NULL constraints

### 4. Transport Security

- **Development**: HTTP over internal Docker network (not exposed to internet)
- **Production**: HTTPS/TLS required for browser ↔ Rails

---

## Key Design Decisions

### Rails 8 vs Rails 5.0.x

**Decision**: Use Rails 8.0.4

**Rationale**: Rails 5 EOL (2018), no security patches. Rails 7+ has built-in `ActiveRecord::Encryption`.

### Microservices Architecture

**Rationale**: Separation of concerns, independent scaling, reusable validation logic across services.

**Trade-off**: Network latency (~10-50ms per validation).

### No SSN Index

**Rationale**: Encrypted SSN = random values, database indexes are useless. SSN only used for validation during creation, not for lookups.

### Monorepo Structure

**Rationale**: `/rails-app` + `/java-service` in one repo for atomic commits, shared documentation, easier orchestration.

---

## Technology Stack

**Backend**: Ruby 3.2 • Rails 8.0 • PostgreSQL 16 • Java 17 • Spring Boot 3.2  
**Frontend**: ERB • Tailwind CSS • Hotwire Turbo • Stimulus • ViewComponent  
**Infrastructure**: Docker + Docker Compose • GitHub Actions

---

## Testing

**Rails (RSpec)**: 100% coverage, 279 examples  
**Java (JUnit 5)**: >70% coverage
