Now we’re getting to the real engineering blueprint. This document defines how all the pieces fit together before we start designing individual backend modules.

04_System_Architecture.md

# 04_System_Architecture.md
# DentAssist System Architecture
Version: 1.0
Status: Draft
Dependencies:
- 00_Vision.md
- 01_Product_Requirements.md
- 02_User_Personas.md
- 03_User_Journeys.md
---
# Table of Contents
1. Architecture Overview
2. Architectural Goals
3. Architecture Principles
4. High-Level Architecture
5. Client Layer
6. API Layer
7. Application Layer
8. Data Layer
9. AI Layer
10. Location Layer
11. Authentication Architecture
12. Conversation Architecture
13. Redis Architecture
14. PostgreSQL Architecture
15. External Service Architecture
16. Request Lifecycle
17. AI Request Lifecycle
18. Clinic Search Lifecycle
19. Symptom Assessment Lifecycle
20. Error Handling Architecture
21. Security Boundaries
22. Scalability
23. Availability
24. Observability
25. Development Environment
26. Production Environment
27. Docker Architecture
28. Future Architecture
29. Architectural Decisions
30. Summary
---
# 1. Architecture Overview
DentAssist will use a modular client-server architecture.
The initial architecture consists of:
- Flutter frontend.
- Spring Boot backend.
- PostgreSQL database.
- Redis cache.
- AI provider integration.
- Location provider integration.
The system should be designed so individual components can evolve independently.
---
# 2. Architectural Goals
The architecture must provide:
- Security.
- Maintainability.
- Scalability.
- Testability.
- Provider independence.
- Clear separation of responsibilities.
- Reliable conversation memory.
- Low operational cost.
Because the initial project has a zero-budget constraint, the architecture should avoid unnecessary infrastructure.
---
# 3. Architecture Principles
## Principle 1 — Backend Owns Business Logic
The frontend should not contain important business rules.
Bad:
Flutter determines whether a symptom is an emergency.
Good:
Flutter submits symptom information.
Backend evaluates the configured rules.
---
## Principle 2 — Never Trust the Client
Everything received from the frontend must be validated by the backend.
---
## Principle 3 — External Providers Are Replaceable
AI and location providers must not be tightly coupled to the application.
---
## Principle 4 — Database Is the Source of Truth
Redis is a cache.
It must never be the only permanent storage for important user data.
---
## Principle 5 — Start Monolithic, Design Modularly
The initial backend should be a modular monolith.
Do NOT start with microservices.
---
# 4. High-Level Architecture
```mermaid
flowchart TD
    A[Flutter Mobile App] --> B[Spring Boot API]
    B --> C[Authentication Module]
    B --> D[Chat Module]
    B --> E[Symptom Module]
    B --> F[Clinic Module]
    B --> G[User Module]
    B --> H[Feedback Module]
    C --> I[(PostgreSQL)]
    D --> I
    E --> I
    F --> I
    G --> I
    H --> I
    D --> J[(Redis)]
    D --> K[AI Provider]
    F --> L[Location Provider]
    K --> M[Gemini]
    K --> N[Groq]
    K --> O[OpenRouter]
    L --> P[OpenStreetMap]
    L --> Q[Geoapify]
    L --> R[Google Places]

⸻

5. Client Layer

The client application will initially be built using Flutter.

Flutter provides:

* Android support.
* iOS support.
* Web support.
* Shared UI code.

⸻

Client Responsibilities

The frontend is responsible for:

* Rendering screens.
* Collecting user input.
* Displaying responses.
* Managing navigation.
* Maintaining temporary UI state.
* Securely storing authentication tokens where appropriate.
* Requesting permissions.

The frontend is NOT responsible for:

* AI prompting.
* AI provider selection.
* Emergency classification.
* Database access.
* API keys.
* Secret configuration.

⸻

6. API Layer

Spring Boot exposes a REST API.

Example:

/api/v1/auth
/api/v1/users
/api/v1/conversations
/api/v1/symptoms
/api/v1/clinics
/api/v1/feedback

All APIs should use versioning.

Example:

/api/v1/...

Future breaking changes can use:

/api/v2/...

⸻

7. Application Layer

The backend will be organized as a modular monolith.

Suggested modules:

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

Backend Structure

dentassist-backend/
src/main/java/com/dentassist/
├── auth/
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── model/
│   └── dto/
│
├── user/
│
├── conversation/
│
├── ai/
│
├── symptom/
│
├── clinic/
│
├── feedback/
│
├── notification/
│
└── common/

Each module should own its business logic.

⸻

8. Data Layer

PostgreSQL is the primary database.

It stores:

* Users.
* Conversations.
* Messages.
* Symptom assessments.
* Feedback.
* Saved clinics.
* Preferences.
* Usage information.

⸻

Why PostgreSQL?

PostgreSQL provides:

* Strong relational integrity.
* Transactions.
* Excellent indexing.
* JSON support.
* Full-text search.
* Extensions.
* pgvector support in the future.

⸻

9. AI Layer

The AI layer is isolated behind an internal interface.

Example:

public interface AiProvider {
    AiResponse generate(AiRequest request);
}

Providers implement this interface.

Example:

AiProvider
    │
    ├── GeminiProvider
    ├── GroqProvider
    └── OpenRouterProvider

The application does not directly depend on a specific AI vendor.

⸻

AI Provider Selection

The backend can eventually implement:

Primary Provider
      ↓
Failure?
      ↓
Fallback Provider
      ↓
Failure?
      ↓
Second Fallback

Provider selection may depend on:

* Availability.
* Rate limits.
* Cost.
* Model capability.
* Request type.

⸻

10. Location Layer

The clinic system uses a provider abstraction.

Example:

public interface ClinicProvider {
    List<Clinic> findNearby(
        double latitude,
        double longitude,
        double radius
    );
}

Possible implementations:

OpenStreetMapProvider
GeoapifyProvider
GooglePlacesProvider

This prevents the rest of the application from depending on one mapping provider.

⸻

11. Authentication Architecture

Authentication will use token-based authentication.

Possible implementation:

Flutter
   ↓
POST /auth/login
   ↓
Spring Boot
   ↓
Validate credentials
   ↓
Issue access token
   ↓
Flutter

The access token is then attached to protected requests.

Example:

Authorization: Bearer <token>

⸻

Authentication Responsibilities

The authentication system must:

* Hash passwords.
* Validate credentials.
* Issue tokens.
* Expire sessions.
* Revoke sessions where necessary.
* Prevent brute-force attacks.
* Protect protected endpoints.

Passwords must never be stored directly.

⸻

12. Conversation Architecture

Conversation architecture is central to DentAssist.

A conversation contains:

Conversation
    │
    ├── Message
    ├── Message
    ├── Message
    └── Message

⸻

Conversation Entity

Conceptually:

Conversation
id
user_id
title
created_at
updated_at
status

⸻

Message Entity

Message
id
conversation_id
role
content
created_at
model
provider
token_usage

Roles:

USER
ASSISTANT
SYSTEM

⸻

13. Redis Architecture

Redis is used for temporary/high-speed information.

Potential uses:

* Rate limiting.
* Recent conversation context.
* Session data.
* Clinic search caching.
* AI response caching where appropriate.
* Temporary guest sessions.

⸻

Redis Key Naming

Use predictable namespaces.

Example:

chat:conversation:{id}:context
rate:user:{id}
rate:guest:{id}
clinic:nearby:{hash}
session:{id}

⸻

Redis TTL

Temporary data must have expiration.

Example:

Conversation context:
TTL = 30 minutes
Clinic cache:
TTL = 10 minutes
Rate-limit counter:
TTL = 24 hours

Exact values should be configurable.

⸻

14. PostgreSQL Architecture

PostgreSQL is the permanent storage layer.

Initial tables:

users
refresh_tokens
conversations
messages
symptom_assessments
symptom_answers
saved_clinics
feedback
usage_records
user_preferences

⸻

Database Ownership

Each module should own its database entities.

Example:

Conversation module:

conversations
messages

Symptom module:

symptom_assessments
symptom_answers

User module:

users
user_preferences

⸻

15. External Service Architecture

DentAssist depends on external services.

Potential external services:

AI:

* Gemini.
* Groq.
* OpenRouter.

Maps:

* OpenStreetMap.
* Geoapify.
* Google Places.

Infrastructure:

* Email provider.
* Error monitoring.
* Analytics.

External services must be accessed through internal interfaces.

⸻

16. Request Lifecycle

Example:

User sends:

“Why does my tooth hurt?”

⸻

Step 1

Flutter sends HTTP request.

POST /api/v1/conversations/{id}/messages

⸻

Step 2

Spring Security validates authentication.

⸻

Step 3

Controller validates request format.

⸻

Step 4

Service checks:

* User owns conversation.
* User has available usage.
* Message is valid.

⸻

Step 5

Recent context is retrieved.

⸻

Step 6

Safety processing occurs.

⸻

Step 7

AI request is constructed.

⸻

Step 8

AI provider receives request.

⸻

Step 9

AI responds.

⸻

Step 10

Backend validates response.

⸻

Step 11

Assistant message is persisted.

⸻

Step 12

Redis context is updated.

⸻

Step 13

Response is returned to Flutter.

⸻

17. AI Request Lifecycle

sequenceDiagram
    participant U as User
    participant F as Flutter
    participant B as Backend
    participant R as Redis
    participant DB as PostgreSQL
    participant AI as AI Provider
    U->>F: Send message
    F->>B: POST message
    B->>R: Get recent context
    R-->>B: Context
    B->>DB: Get conversation data
    DB-->>B: Conversation
    B->>AI: Prompt + Context
    AI-->>B: Response
    B->>DB: Save message
    B->>R: Update context
    B-->>F: AI response
    F-->>U: Display response

⸻

18. Clinic Search Lifecycle

sequenceDiagram
    participant U as User
    participant F as Flutter
    participant B as Backend
    participant R as Redis
    participant P as Clinic Provider
    U->>F: Find nearby dentist
    F->>B: Location
    B->>R: Check cache
    alt Cache Hit
        R-->>B: Cached clinics
    else Cache Miss
        B->>P: Search nearby dentists
        P-->>B: Clinic results
        B->>R: Cache results
    end
    B-->>F: Clinics
    F-->>U: Display clinics

⸻

19. Symptom Assessment Lifecycle

The symptom checker should be deterministic wherever possible.

Flow:

User
 ↓
Question
 ↓
Answer
 ↓
Backend
 ↓
Rules Engine
 ↓
Urgency Category
 ↓
Explanation

The LLM should NOT be responsible for the primary emergency classification.

⸻

Why?

LLMs are probabilistic.

Safety-critical rules should be deterministic.

For example:

difficulty_breathing = true

can trigger a predefined emergency response.

The AI can explain the result, but it should not be the only component determining it.

⸻

20. Error Handling Architecture

Errors should be standardized.

Example:

{
    "error": {
        "code": "CONVERSATION_NOT_FOUND",
        "message": "The conversation could not be found.",
        "requestId": "req_123"
    }
}

⸻

Error Categories

AUTHENTICATION_ERROR
AUTHORIZATION_ERROR
VALIDATION_ERROR
RESOURCE_NOT_FOUND
RATE_LIMITED
AI_PROVIDER_ERROR
LOCATION_PROVIDER_ERROR
DATABASE_ERROR
INTERNAL_ERROR

⸻

21. Security Boundaries

The architecture contains several security boundaries.

Internet
   │
   ▼
Flutter
   │
   ▼
HTTPS
   │
   ▼
Spring Boot
   │
   ├── Authentication
   ├── Authorization
   ├── Validation
   │
   ▼
Internal Services
   │
   ├── PostgreSQL
   ├── Redis
   └── External APIs

Secrets must never be included in Flutter.

Examples:

Bad:

GEMINI_API_KEY = "..."

inside Flutter.

Correct:

Flutter
   ↓
Backend
   ↓
AI Provider

⸻

22. Scalability

The first version does not need Kubernetes.

Start with:

1 Backend
1 PostgreSQL
1 Redis

As usage increases:

             Load Balancer
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
    Backend 1  Backend 2  Backend 3
        │          │          │
        └──────────┼──────────┘
                   │
             PostgreSQL
                   │
                Redis

The backend should remain stateless wherever practical.

⸻

23. Availability

External dependencies can fail.

Therefore:

AI provider:

Primary → Fallback

Location provider:

Primary → Fallback

Redis:

Temporary optimization, not critical permanent storage.

PostgreSQL:

Critical.

⸻

24. Observability

The backend should eventually provide:

* Structured logs.
* Metrics.
* Request IDs.
* Error tracking.
* AI latency metrics.
* Provider failure metrics.

Example log:

requestId=req_123
endpoint=/api/v1/chat
provider=gemini
latency=1840ms
status=200

⸻

25. Development Environment

Development should run locally using Docker.

Example:

Docker Compose
├── PostgreSQL
├── Redis
└── Backend

Flutter runs separately.

⸻

26. Production Environment

Initial production:

Internet
   │
   ▼
HTTPS
   │
   ▼
Backend
   │
   ├── PostgreSQL
   ├── Redis
   ├── AI
   └── Clinic Provider

The exact hosting provider will be selected later based on:

* Free-tier availability.
* Geographic availability.
* Reliability.
* Deployment simplicity.

⸻

27. Docker Architecture

Development:

services:
  postgres:
    image: postgres
  redis:
    image: redis
  backend:
    build: .
    depends_on:
      - postgres
      - redis

Environment variables:

DATABASE_URL
DATABASE_USERNAME
DATABASE_PASSWORD
REDIS_HOST
REDIS_PORT
AI_PRIMARY_API_KEY
AI_SECONDARY_API_KEY
CLINIC_PROVIDER_API_KEY

Secrets must be provided through environment configuration.

They should never be committed to Git.

⸻

28. Future Architecture

As DentAssist grows:

                   API Gateway
                       │
        ┌──────────────┼───────────────┐
        │              │               │
        ▼              ▼               ▼
   Chat Service   Clinic Service   User Service
        │              │               │
        ▼              ▼               ▼
      AI Layer      Maps Layer       PostgreSQL
        │
        ▼
   AI Providers

However, this architecture should only be introduced when the modular monolith becomes a genuine bottleneck.

⸻

29. Architectural Decisions

ADR-001

Decision:

Use Flutter.

Reason:

Cross-platform development.

⸻

ADR-002

Decision:

Use Spring Boot.

Reason:

Strong ecosystem, mature security, excellent database support, and good maintainability for a backend-heavy application.

⸻

ADR-003

Decision:

Use PostgreSQL.

Reason:

Reliable relational database with future pgvector support.

⸻

ADR-004

Decision:

Use Redis.

Reason:

Low-latency caching, rate limiting, and temporary conversation context.

⸻

ADR-005

Decision:

Use AI provider abstraction.

Reason:

Avoid vendor lock-in.

⸻

ADR-006

Decision:

Start with a modular monolith.

Reason:

The MVP does not justify microservice complexity.

⸻

ADR-007

Decision:

Symptom urgency rules should be deterministic.

Reason:

Safety-critical behavior should not rely entirely on probabilistic AI output.

⸻

30. Summary

DentAssist will initially use the following architecture:

                 Flutter
                    │
                    ▼
             Spring Boot API
                    │
       ┌────────────┼────────────┐
       │            │            │
       ▼            ▼            ▼
 PostgreSQL       Redis       External APIs
       │            │            │
       │            │       ┌────┴─────┐
       │            │       │          │
       │            ▼       ▼          ▼
       │         Context    AI       Clinics
       │
       ▼
 Permanent Data

The most important architectural principles are:

1. Backend owns business logic.
2. PostgreSQL is the source of truth.
3. Redis is temporary/cache storage.
4. AI providers are replaceable.
5. Location providers are replaceable.
6. Safety-critical symptom rules are deterministic.
7. Flutter never receives secret API keys.
8. Start with a modular monolith.
9. Design for future scaling without prematurely building microservices.
10. User safety takes priority over convenience.

The architecture should remain simple enough for one developer to understand and maintain while providing a clear path toward a much larger production system.

### One important consequence
We've now answered your earlier concern about **AI memory** at the architecture level.
The model itself doesn't need to "remember" your user forever.
We build the memory system:
```text
                   USER
                     │
                     ▼
                Flutter
                     │
                     ▼
             Spring Boot API
                     │
             ┌───────┴────────┐
             ▼                ▼
          Redis           PostgreSQL
       recent context     full history
             │                │
             └───────┬────────┘
                     ▼
              Context Builder
                     │
                     ▼
                AI Provider

So if tomorrow we replace Gemini with another model, the user’s conversation memory doesn’t disappear. That’s a property of our application, not the AI vendor.

And there’s another important decision we’ve just made: we aren’t going to let an LLM decide whether someone is having an emergency. We’ll create a deterministic rules engine for that, and use the AI to explain the result conversationally. That’s a much more responsible architecture for a health-related application.

Next: 05_Backend_Architecture.md — we’ll go inside the Spring Boot application itself and design the package structure, modules, controllers, services, repositories, DTOs, exception handling, security filters, configuration, AI abstraction, clinic abstraction, and the exact responsibilities of each backend component.