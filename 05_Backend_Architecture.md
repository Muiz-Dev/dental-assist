Absolutely. Now we’re going inside the backend. This document is where the architecture turns into an actual Spring Boot project structure. We’ll be deliberately specific so that later, when we start coding, we’re not improvising where everything belongs.

05_Backend_Architecture.md

# 05_Backend_Architecture.md
# DentAssist Backend Architecture
Version: 1.0
Status: Draft
Dependencies:
- 00_Vision.md
- 01_Product_Requirements.md
- 02_User_Personas.md
- 03_User_Journeys.md
- 04_System_Architecture.md
---
# Table of Contents
1. Introduction
2. Backend Technology Stack
3. Backend Responsibilities
4. Architectural Style
5. Project Structure
6. Module Architecture
7. Common Module
8. Authentication Module
9. User Module
10. Conversation Module
11. AI Module
12. Symptom Module
13. Clinic Module
14. Feedback Module
15. Notification Module
16. Controller Layer
17. Service Layer
18. Repository Layer
19. Entity Layer
20. DTO Layer
21. Mapper Layer
22. Validation
23. Exception Handling
24. API Response Standards
25. Security Architecture
26. Configuration Architecture
27. Environment Variables
28. AI Provider Abstraction
29. Clinic Provider Abstraction
30. Transaction Management
31. Logging
32. Request Correlation
33. Rate Limiting
34. Caching
35. Database Migrations
36. Scheduled Jobs
37. Testing Architecture
38. Dependency Management
39. Development Profiles
40. Production Profiles
41. Package Naming
42. Coding Standards
43. Backend Request Lifecycle
44. Backend Failure Strategy
45. Future Evolution
46. Summary
---
# 1. Introduction
This document defines the internal architecture of the DentAssist Spring Boot backend.
The goal is to create a backend that is:
- Easy to understand.
- Easy to test.
- Easy to maintain.
- Secure.
- Modular.
- Provider-independent.
- Suitable for future scaling.
The backend will initially be implemented as a modular monolith.
---
# 2. Backend Technology Stack
Initial stack:
| Component | Technology |
|---|---|
| Language | Java |
| Framework | Spring Boot |
| API | REST |
| Database | PostgreSQL |
| ORM | Spring Data JPA / Hibernate |
| Cache | Redis |
| Authentication | Spring Security |
| Token | JWT or secure session strategy |
| Migration | Flyway |
| Build | Maven |
| Containerization | Docker |
| Testing | JUnit + Mockito |
| API Documentation | OpenAPI / Swagger |
| Serialization | Jackson |
The exact library versions should be pinned when implementation begins.
---
# 3. Backend Responsibilities
The backend is responsible for:
- Authentication.
- Authorization.
- User management.
- Conversation management.
- AI orchestration.
- Conversation memory.
- Usage limits.
- Symptom assessment.
- Clinic discovery.
- Feedback.
- Data persistence.
- Rate limiting.
- Security.
- External API integration.
The backend is the central authority for application behavior.
---
# 4. Architectural Style
DentAssist uses:
> Modular Monolith + Layered Architecture
The application is one deployable backend but contains clearly separated modules.
Conceptually:
```text
DentAssist Backend
│
├── Auth
├── User
├── Conversation
├── AI
├── Symptom
├── Clinic
├── Feedback
├── Notification
└── Common

Each module follows:

Controller
     ↓
Service
     ↓
Repository
     ↓
Database

External integrations are accessed through interfaces.

⸻

5. Project Structure

Recommended structure:

dentassist-backend/
├── pom.xml
├── Dockerfile
├── docker-compose.yml
├── README.md
│
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── dentassist/
│   │   │
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       └── db/
│   │           └── migration/
│   │
│   └── test/
│       └── java/
│           └── com/
│               └── dentassist/

⸻

6. Module Architecture

The primary modules are:

auth
user
conversation
ai
symptom
clinic
feedback
notification
common

⸻

Module Dependencies

flowchart TD
    Auth --> User
    Conversation --> User
    Conversation --> AI
    Symptom --> User
    Clinic --> User
    Feedback --> User
    Feedback --> Conversation
    Notification --> User
    Common --> Auth
    Common --> User
    Common --> Conversation
    Common --> AI
    Common --> Symptom
    Common --> Clinic
    Common --> Feedback
    Common --> Notification

The Common module contains shared infrastructure and utilities.

Business logic should not be placed there merely because it is convenient.

⸻

7. Common Module

The common module contains shared technical infrastructure.

Possible structure:

common/
├── config/
├── exception/
├── security/
├── response/
├── validation/
├── logging/
├── util/
└── constants/

⸻

Common Configuration

Examples:

* Database configuration.
* Redis configuration.
* Jackson configuration.
* OpenAPI configuration.
* Security configuration.

⸻

Common Exceptions

Examples:

ResourceNotFoundException
UnauthorizedException
ForbiddenException
RateLimitExceededException
ExternalServiceException
AiProviderException
ClinicProviderException

⸻

8. Authentication Module

The authentication module manages identity verification.

Structure:

auth/
├── controller/
├── service/
├── repository/
├── entity/
├── dto/
├── security/
└── mapper/

⸻

Authentication Responsibilities

* Registration.
* Login.
* Logout.
* Token refresh.
* Password hashing.
* Credential validation.
* Session management.
* Authentication events.

⸻

Registration Flow

POST /api/v1/auth/register
        ↓
Validate input
        ↓
Check existing email
        ↓
Hash password
        ↓
Create user
        ↓
Create preferences
        ↓
Issue authentication credentials
        ↓
Return response

⸻

Password Storage

Passwords must be hashed using a modern adaptive password hashing algorithm.

Example:

Argon2id

or another approved password-hashing mechanism supported by the implementation stack.

Never use:

MD5
SHA-1
Plain SHA-256
Plaintext

for password storage.

⸻

9. User Module

Responsible for:

* User profile.
* Preferences.
* Account settings.
* Account deletion.
* User state.

Structure:

user/
├── controller/
├── service/
├── repository/
├── entity/
├── dto/
└── mapper/

⸻

User Information

Initial account data should remain minimal.

Example:

id
email
password_hash
status
created_at
updated_at

Optional profile information:

display_name
preferred_language
timezone

Do not collect sensitive health information unnecessarily.

⸻

10. Conversation Module

This is one of the most important backend modules.

Responsibilities:

* Create conversations.
* Retrieve conversations.
* Send messages.
* Store messages.
* Load context.
* Delete conversations.
* Manage guest conversations.

Structure:

conversation/
├── controller/
├── service/
├── repository/
├── entity/
├── dto/
├── mapper/
└── context/

⸻

Conversation Service

Conceptual interface:

public interface ConversationService {
    Conversation createConversation(
        UserId userId
    );
    Conversation getConversation(
        ConversationId id
    );
    ChatResponse sendMessage(
        ConversationId conversationId,
        String message
    );
    void deleteConversation(
        ConversationId conversationId
    );
}

⸻

Message Processing

The Conversation Service coordinates:

Authentication
      ↓
Usage Check
      ↓
Conversation Lookup
      ↓
Context Retrieval
      ↓
Safety Processing
      ↓
AI Service
      ↓
Persistence
      ↓
Context Update
      ↓
Response

⸻

11. AI Module

The AI module should contain all AI-specific logic.

Structure:

ai/
├── service/
├── provider/
├── model/
├── prompt/
├── safety/
├── context/
└── dto/

⸻

AI Service

The Conversation module should not know how Gemini or another provider works.

It should call:

aiService.generateResponse(request);

⸻

AI Service Interface

public interface AiService {
    AiResponse generateResponse(
        AiRequest request
    );
}

⸻

AI Provider Interface

public interface AiProvider {
    AiResponse generate(
        AiRequest request
    );
    String providerName();
    boolean isAvailable();
}

⸻

Provider Implementations

ai/provider/
├── GeminiProvider
├── GroqProvider
└── OpenRouterProvider

Providers can be enabled or disabled using configuration.

⸻

Provider Selection

A provider manager determines which provider handles the request.

Conceptually:

AiProviderManager
       ↓
Primary Provider
       ↓
Success?
   │
   ├── Yes → Return
   │
   └── No
        ↓
   Fallback Provider
        ↓
      Return

⸻

12. Symptom Module

The symptom module handles structured assessment.

Structure:

symptom/
├── controller/
├── service/
├── rules/
├── entity/
├── repository/
├── dto/
└── mapper/

⸻

Symptom Service

Responsibilities:

* Start assessment.
* Store answers.
* Validate answers.
* Evaluate rules.
* Return urgency category.
* Generate educational explanation.

⸻

Rules Engine

The initial rules engine should be deterministic.

Example:

if (difficultyBreathing) {
    return EMERGENCY;
}

Another:

if (uncontrolledBleeding) {
    return EMERGENCY;
}

The final production rules must be reviewed carefully by qualified dental/medical professionals.

⸻

Urgency Categories

LOW
MODERATE
HIGH
EMERGENCY

These categories are guidance categories, not diagnoses.

⸻

13. Clinic Module

Responsibilities:

* Nearby clinic search.
* Clinic details.
* Clinic caching.
* Provider abstraction.
* Clinic normalization.

Structure:

clinic/
├── controller/
├── service/
├── provider/
├── cache/
├── model/
├── dto/
└── mapper/

⸻

Clinic Provider

public interface ClinicProvider {
    List<Clinic> findNearby(
        Coordinates coordinates,
        double radius
    );
    Optional<Clinic> findById(
        String providerId
    );
}

⸻

Provider Implementations

Potential providers:

OpenStreetMapProvider
GeoapifyProvider
GooglePlacesProvider

The application should normalize different provider responses into one internal model.

⸻

14. Feedback Module

Responsibilities:

* AI feedback.
* User feedback.
* Feedback categorization.
* Feedback analytics.

Structure:

feedback/
├── controller/
├── service/
├── repository/
├── entity/
└── dto/

⸻

Example Feedback

message_id
user_id
rating
category
comment
created_at

Possible categories:

INCORRECT
CONFUSING
IRRELEVANT
TOO_LONG
UNSAFE
OTHER

⸻

15. Notification Module

Initially optional.

Future responsibilities:

* Dental reminders.
* Appointment reminders.
* Oral care reminders.

Structure:

notification/
├── controller/
├── service/
├── provider/
├── entity/
└── repository/

Potential future providers:

* Firebase Cloud Messaging.
* Email.
* SMS.

⸻

16. Controller Layer

Controllers expose HTTP endpoints.

Controllers should be thin.

Bad:

@PostMapping
public ResponseEntity<?> chat(...) {
    // 200 lines of business logic
}

Good:

@PostMapping
public ChatResponse sendMessage(
    @Valid @RequestBody SendMessageRequest request
) {
    return conversationService.sendMessage(request);
}

Business logic belongs in services.

⸻

17. Service Layer

Services contain business rules.

Example:

ConversationController
        ↓
ConversationService
        ↓
AiService
        ↓
AiProviderManager
        ↓
GeminiProvider

Services should coordinate operations without becoming enormous classes.

If a service becomes too large, split responsibilities into dedicated components.

⸻

18. Repository Layer

Repositories communicate with the database.

Example:

public interface ConversationRepository
        extends JpaRepository<Conversation, UUID> {
    List<Conversation> findByUserIdOrderByUpdatedAtDesc(
        UUID userId
    );
}

Repositories should not contain complex business rules.

⸻

19. Entity Layer

Entities represent persistent data.

Example:

@Entity
@Table(name = "conversations")
public class Conversation {
    @Id
    private UUID id;
    private UUID userId;
    private String title;
    private Instant createdAt;
    private Instant updatedAt;
}

Entities should avoid exposing internal persistence details directly through API responses.

⸻

20. DTO Layer

DTOs define API contracts.

Example:

public record SendMessageRequest(
    @NotBlank
    @Size(max = 4000)
    String message
) {}

Response:

public record ChatResponse(
    UUID conversationId,
    UUID messageId,
    String content,
    Instant createdAt
) {}

⸻

Why DTOs?

Never expose JPA entities directly through the public API.

DTOs provide:

* Security.
* Versioning.
* Validation.
* API stability.

⸻

21. Mapper Layer

Mappers convert:

Entity → DTO
DTO → Domain Model
Provider Response → Domain Model

Example:

ConversationResponse toResponse(
    Conversation conversation
);

⸻

22. Validation

All incoming requests must be validated.

Example:

@NotBlank
@Size(max = 4000)
String message;

Validation should occur before business logic.

⸻

Validation Examples

Reject:

* Empty messages.
* Excessively large messages.
* Invalid coordinates.
* Negative search radius.
* Invalid UUIDs.
* Invalid email addresses.

⸻

23. Exception Handling

Use centralized exception handling.

Example:

@RestControllerAdvice
public class GlobalExceptionHandler {
}

The handler maps exceptions to consistent API errors.

⸻

Example

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data.",
    "requestId": "req_123"
  }
}

⸻

24. API Response Standards

Successful responses should be predictable.

Example:

{
  "data": {
    "id": "123"
  }
}

Errors:

{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Conversation not found.",
    "requestId": "req_123"
  }
}

The exact envelope should be standardized before implementation.

⸻

25. Security Architecture

Spring Security protects endpoints.

Public:

POST /api/v1/auth/register
POST /api/v1/auth/login
GET  /api/v1/clinics/nearby

Protected:

GET    /api/v1/users/me
GET    /api/v1/conversations
POST   /api/v1/conversations
POST   /api/v1/conversations/{id}/messages
DELETE /api/v1/conversations/{id}

The exact public/protected classification can evolve.

⸻

Authorization

Authentication answers:

“Who are you?”

Authorization answers:

“Are you allowed to access this resource?”

Example:

User A must not access:

User B's conversation

Every conversation request must verify ownership.

⸻

26. Configuration Architecture

Configuration should come from:

* application.yml
* environment variables
* deployment secrets

Example:

spring:
  datasource:
    url: ${DATABASE_URL}

⸻

27. Environment Variables

Example:

DATABASE_URL
DATABASE_USERNAME
DATABASE_PASSWORD
REDIS_HOST
REDIS_PORT
REDIS_PASSWORD
AI_PRIMARY_API_KEY
AI_SECONDARY_API_KEY
CLINIC_PROVIDER_API_KEY
JWT_SECRET

Secrets must never be committed.

⸻

28. AI Provider Abstraction

The backend should never contain code like:

conversationService -> Gemini SDK

Instead:

ConversationService
        ↓
AiService
        ↓
AiProviderManager
        ↓
AiProvider

This abstraction allows providers to change.

⸻

AI Request Model

Conceptually:

public record AiRequest(
    String systemPrompt,
    List<AiMessage> messages,
    AiConfiguration configuration
) {}

⸻

AI Response Model

public record AiResponse(
    String content,
    String provider,
    String model,
    Integer inputTokens,
    Integer outputTokens
) {}

Token information may be unavailable for some providers.

The model must therefore allow nullable metadata.

⸻

29. Clinic Provider Abstraction

Same principle.

The application should not depend directly on one map provider.

ClinicService
      ↓
ClinicProvider
      ↓
Provider Implementation

This makes provider migration possible.

⸻

30. Transaction Management

Database operations requiring consistency should use transactions.

Example:

Creating a user:

Create User
Create Preferences
Create Usage Record

These may occur within one transaction.

If one fails:

Everything rolls back.

⸻

Chat Transactions

Chat persistence requires careful handling.

The system should avoid:

User message saved
AI fails
Assistant message missing

unless the state explicitly records that generation failed.

Possible states:

PENDING
COMPLETED
FAILED

⸻

31. Logging

Use structured logging.

Example:

timestamp
level
requestId
userId
endpoint
latency
status

Never log:

* Passwords.
* API keys.
* Authentication tokens.
* Sensitive user information unnecessarily.
* Full private conversations by default.

⸻

32. Request Correlation

Every request should have a request ID.

Example:

X-Request-ID: req_01ABC

If the client does not provide one, the backend generates it.

The ID should appear in:

* Logs.
* Error responses.
* Traces.

⸻

33. Rate Limiting

Rate limiting protects:

* AI providers.
* Database.
* Redis.
* Backend.

Example:

Guest:

5 AI requests/day.

Authenticated:

Configurable limit.

IP-based protection:

Short-term request limit.

⸻

Redis-Based Rate Limiting

Conceptually:

rate:guest:{identifier}

The key contains a counter.

TTL:

24 hours.

⸻

34. Caching

Caching should be applied selectively.

Good candidates:

* Nearby clinic searches.
* Static educational data.
* Recent conversation context.

Bad candidates:

* Passwords.
* Highly sensitive information.
* Data that must always be real-time.

⸻

35. Database Migrations

Use Flyway.

Example:

V1__create_users.sql
V2__create_conversations.sql
V3__create_messages.sql
V4__create_symptom_assessments.sql
V5__create_feedback.sql

Never manually modify production database structure without a migration.

⸻

36. Scheduled Jobs

Potential jobs:

* Delete expired guest sessions.
* Clean temporary data.
* Refresh clinic cache.
* Send reminders.
* Aggregate analytics.

Scheduled jobs should be idempotent.

⸻

37. Testing Architecture

Testing levels:

Unit Tests
    ↓
Integration Tests
    ↓
API Tests
    ↓
End-to-End Tests

⸻

Unit Tests

Test:

* Services.
* Rules engine.
* Mappers.
* Validators.

⸻

Integration Tests

Test:

* PostgreSQL.
* Redis.
* Repositories.
* Spring context.

Testcontainers may be used to provide realistic infrastructure during tests.

⸻

API Tests

Test:

POST /auth/register
POST /auth/login
POST /conversations
POST /conversations/{id}/messages
GET /clinics/nearby

⸻

AI Testing

Do not depend entirely on live AI providers during automated tests.

Create mocked AI providers.

Example:

FakeAiProvider

This makes tests:

* Faster.
* Deterministic.
* Cheaper.

⸻

38. Dependency Management

Maven manages dependencies.

Dependencies should be:

* Explicit.
* Version-controlled.
* Regularly updated.
* Audited for vulnerabilities.

Avoid adding libraries merely because they are convenient.

⸻

39. Development Profiles

Use:

dev
test
prod

Example:

application.yml
application-dev.yml
application-test.yml
application-prod.yml

Development may use local PostgreSQL and Redis.

⸻

40. Production Profiles

Production configuration should:

* Disable debug output.
* Require secure secrets.
* Use HTTPS.
* Use production database credentials.
* Configure connection pools.
* Enable structured logging.

⸻

41. Package Naming

Base package:

com.dentassist

Examples:

com.dentassist.auth
com.dentassist.user
com.dentassist.conversation
com.dentassist.ai
com.dentassist.symptom
com.dentassist.clinic

⸻

42. Coding Standards

Use:

* Clear names.
* Small methods.
* Single responsibility.
* Immutable DTOs where practical.
* Constructor injection.
* No field injection.
* Explicit error handling.

Prefer:

private final AiService aiService;

over:

@Autowired
private AiService aiService;

⸻

43. Backend Request Lifecycle

Example:

HTTP Request
     ↓
Security Filter
     ↓
Controller
     ↓
Validation
     ↓
Service
     ↓
Repository / External Service
     ↓
Domain Processing
     ↓
Mapper
     ↓
HTTP Response

⸻

Chat Request

More specifically:

POST /conversations/{id}/messages
          ↓
Authentication
          ↓
Authorization
          ↓
Validation
          ↓
Rate Limit
          ↓
Conversation Service
          ↓
Context Service
          ↓
AI Service
          ↓
AI Provider
          ↓
Response Validation
          ↓
Persistence
          ↓
Redis Context Update
          ↓
Response

⸻

44. Backend Failure Strategy

Failures should be isolated.

⸻

AI Failure

Try fallback provider.

⸻

Redis Failure

Application may continue using PostgreSQL context, although performance may degrade.

⸻

Clinic Provider Failure

Return:

“Nearby clinic information is temporarily unavailable.”

The AI remains usable.

⸻

Database Failure

Return a controlled error.

Do not expose database internals.

⸻

45. Future Evolution

The modular monolith allows future extraction.

For example:

Current:
Spring Boot
├── AI
├── Clinic
├── User
└── Conversation

Future:

API Gateway
├── Chat Service
├── Clinic Service
├── User Service
└── Notification Service

Only extract a module when there is a measurable reason.

⸻

46. Summary

The DentAssist backend will initially be:

                    Spring Boot
                         │
        ┌────────────────┼────────────────┐
        │                │                │
       Auth           Conversation      User
        │                │
        │                ▼
        │              AI Service
        │                │
        │          ┌─────┼─────┐
        │          ▼     ▼     ▼
        │       Gemini  Groq  Other
        │
        ├──────── Symptom
        │
        ├──────── Clinic
        │
        ├──────── Feedback
        │
        └──────── Notification
                         │
                 ┌───────┴────────┐
                 ▼                ▼
             PostgreSQL         Redis

The backend’s central principles are:

1. Keep controllers thin.
2. Put business logic in services.
3. Keep persistence behind repositories.
4. Use DTOs for API contracts.
5. Abstract external providers.
6. Keep AI provider logic isolated.
7. Keep symptom rules deterministic.
8. Treat PostgreSQL as permanent storage.
9. Treat Redis as an optimization.
10. Validate every request.
11. Verify resource ownership.
12. Never expose secrets to Flutter.
13. Use migrations for database changes.
14. Test business rules independently.
15. Start as a modular monolith.
16. Extract services only when necessary.

The result should be a backend that is simple enough for a single developer to build but structured enough to evolve into a larger production platform.

## One particularly important decision
At this point, I want to lock in one thing for the eventual implementation:
**We should not make the AI module a giant "send prompt to API" class.**
It should eventually look more like:
```text
AI Module
│
├── AiService
│
├── AiProviderManager
│
├── providers/
│   ├── GeminiProvider
│   ├── GroqProvider
│   └── OpenRouterProvider
│
├── context/
│   ├── ContextBuilder
│   ├── ConversationMemory
│   └── ContextSummarizer
│
├── prompt/
│   ├── SystemPrompt
│   ├── DentalPrompt
│   ├── SafetyPrompt
│   └── PromptBuilder
│
└── safety/
    ├── InputSafetyChecker
    ├── OutputSafetyChecker
    └── SafetyPolicy

That separation will become very important once we get into the AI architecture, because your concern about memory, context, hallucinations, and consistency is actually four different engineering problems—not one.

And we can solve them separately.

Next: 06_Database_Design.md — we’ll design the actual PostgreSQL schema: users, conversations, messages, symptom assessments, usage tracking, clinic bookmarks, feedback, refresh tokens, indexes, constraints, relationships, UUID strategy, timestamps, soft deletion, and how the schema should evolve through migrations.