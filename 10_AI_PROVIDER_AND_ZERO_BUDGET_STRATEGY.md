Next is the practical zero-budget strategy. The goal is not to pretend a production-grade AI service will always be free; it is to make sure we can build and test almost the entire product without paying for one.

10_AI_PROVIDER_AND_ZERO_BUDGET_STRATEGY.md

# 10_AI_PROVIDER_AND_ZERO_BUDGET_STRATEGY.md
# DentAssist AI Provider & Zero-Budget Strategy
Version: 1.0
Status: Draft
---
# Table of Contents
1. Introduction
2. The Zero-Budget Constraint
3. The Most Important Principle
4. What Actually Costs Money
5. What Can Be Built for $0
6. Development Architecture
7. AI Provider Abstraction
8. Mock AI Provider
9. Local AI Provider
10. Cloud AI Provider
11. Provider Configuration
12. Environment Variables
13. Development Modes
14. Mock Mode
15. Local Mode
16. Cloud Mode
17. Production Mode
18. Recommended Development Order
19. Local Database
20. Local Redis
21. Local Backend
22. Local Frontend
23. Local AI
24. Docker
25. Free Hosting Considerations
26. Database Hosting
27. Redis Hosting
28. Backend Hosting
29. Frontend Hosting
30. Domain Names
31. HTTPS
32. Maps and Clinic Search
33. Geolocation
34. Clinic Data
35. Appointment Booking
36. AI Cost Management
37. Token Management
38. Context Management
39. Caching
40. Usage Limits
41. Free User Strategy
42. Paid User Strategy
43. Provider Failover
44. Provider Outages
45. Model Switching
46. Secret Management
47. API Security
48. Abuse Prevention
49. AI Monitoring
50. Budget Alerts
51. Development Cost Table
52. Zero-Budget MVP
53. First Production Version
54. Scaling
55. What Not to Build Yet
56. Recommended Technology Stack
57. Final Architecture
58. Development Roadmap
59. Summary
---
# 1. Introduction
DentAssist is being designed under a strict constraint:
    Initial development budget = $0
This does not mean:
    "The final production application must permanently cost $0."
It means:
    "We should avoid spending money before the product
    has demonstrated enough value to justify spending."
This distinction prevents unnecessary expenses.
---
# 2. The Zero-Budget Constraint
The initial goal is to build:
- Frontend.
- Backend.
- Database.
- Authentication.
- Chat.
- Conversation history.
- AI architecture.
- Memory architecture.
- Clinic search architecture.
- Usage limits.
- Safety system.
without requiring paid infrastructure.
---
# 3. The Most Important Principle
Never make an external paid service a requirement for development.
Instead:
```text
Production dependency
        |
        v
Interface
        |
        ├── Real Provider
        ├── Local Provider
        └── Mock Provider

This is the central zero-budget strategy.

⸻

4. What Actually Costs Money

Potential future costs include:

* AI API requests.
* Cloud compute.
* Managed databases.
* Redis hosting.
* Object storage.
* Maps/geocoding.
* Email services.
* SMS.
* Push notification infrastructure.
* Domain name.
* App-store developer accounts.
* Payment processing.

Not all of these are required on day one.

⸻

5. What Can Be Built for $0

We can build locally:

Flutter
Spring Boot
PostgreSQL
Redis
Docker
Mock AI
Local AI
REST API
Authentication
Database
Testing

The entire application can run on one development machine.

⸻

6. Development Architecture

Initial development:

┌───────────────────────────────┐
│          Developer PC         │
│                               │
│  Flutter                      │
│      │                        │
│      ▼                        │
│  Spring Boot                  │
│      │                        │
│  ┌───┼──────────────┐         │
│  ▼   ▼              ▼         │
│ DB  Redis        AI Provider  │
│              ┌──────┼──────┐  │
│              ▼      ▼      ▼  │
│            Mock   Local   Cloud│
└───────────────────────────────┘

Only one AI path is required at a time.

⸻

7. AI Provider Abstraction

The backend owns an interface:

public interface AiProvider {
    AiResponse generate(AiRequest request);
}

Implementations:

MockAiProvider
LocalAiProvider
CloudAiProvider

The application uses:

aiProvider.generate(request);

It does not use:

geminiService.generate();

throughout the application.

⸻

8. Mock AI Provider

The mock provider is the first implementation.

Example:

User:
What is a cavity?
Mock provider:
A cavity is an area of tooth decay that can damage the
tooth's structure.

The mock provider can support dozens of scripted scenarios.

⸻

Why Mock AI Is Important

It allows development of:

* Chat UI.
* Message persistence.
* Loading states.
* Errors.
* Retry behavior.
* Conversation history.
* Usage limits.
* Memory.
* Authentication.

without AI API costs.

⸻

9. Local AI Provider

A local model can eventually run on the developer’s machine.

Architecture:

Spring Boot
     |
     v
Local AI Server
     |
     v
Local Model

Possible local model runtimes can change over time.

The application should not depend on a specific runtime.

⸻

Local AI Advantages

Potential advantages:

* No per-request API bill.
* No API key.
* Data can remain local.
* Offline development may be possible.
* Useful for experimentation.

⸻

Local AI Disadvantages

Local models can require:

* Significant RAM.
* GPU resources.
* Storage.
* Setup time.
* Model downloads.

Quality may also be below the best hosted models.

Therefore:

Local AI is a development option, not automatically
the production choice.

⸻

10. Cloud AI Provider

A hosted AI provider may provide better:

* Reasoning.
* Language quality.
* Reliability.
* Vision.
* Latency.

But it introduces:

* Cost.
* Network dependency.
* Provider limits.
* API keys.
* Data-handling considerations.

⸻

11. Provider Configuration

Provider selection should be configurable.

Example:

AI_PROVIDER=mock

or:

AI_PROVIDER=local

or:

AI_PROVIDER=cloud

The application code remains unchanged.

⸻

12. Environment Variables

Secrets should never be committed into Git.

Examples:

AI_API_KEY=
DATABASE_URL=
DATABASE_USERNAME=
DATABASE_PASSWORD=
REDIS_URL=
JWT_SECRET=

Use environment variables or a secure secret manager.

⸻

13. Development Modes

DentAssist should have explicit modes.

DEVELOPMENT
TEST
STAGING
PRODUCTION

⸻

14. Mock Mode

Mock mode:

AI_PROVIDER=mock

Use when:

* Building frontend.
* Writing backend tests.
* Working offline.
* Debugging memory.
* Testing API behavior.

⸻

15. Local Mode

Local mode:

AI_PROVIDER=local

Use when:

* Testing realistic conversations.
* Experimenting with prompts.
* Avoiding cloud costs.

⸻

16. Cloud Mode

Cloud mode:

AI_PROVIDER=cloud

Use when:

* Testing a real model.
* Comparing model quality.
* Testing production-like behavior.

⸻

17. Production Mode

Production should have explicit configuration.

Example:

AI_PROVIDER=primary-cloud

with optional fallback:

AI_FALLBACK_PROVIDER=secondary-cloud

⸻

18. Recommended Development Order

Build in this order:

1. Mock AI
2. Backend API
3. Database
4. Redis
5. Flutter chat
6. Authentication
7. Memory
8. Safety rules
9. Local AI
10. Real cloud AI

Do not start by integrating a complicated AI provider.

⸻

19. Local Database

Use PostgreSQL locally.

Example:

localhost:5432

Database:

dentassist

This costs:

$0

during local development.

⸻

20. Local Redis

Run Redis locally.

Example:

localhost:6379

Redis handles:

* Cache.
* Rate limits.
* Temporary state.
* Session information.
* AI request coordination.

⸻

21. Local Backend

Spring Boot:

localhost:8080

API:

/api/v1

⸻

22. Local Frontend

Flutter can run on:

* Android emulator.
* Physical Android device.
* Web.
* Desktop during development.

This is especially important because an app-store account is not required to develop the application.

⸻

23. Local AI

If the development machine can handle a local model:

Flutter
    ↓
Spring Boot
    ↓
Local AI runtime
    ↓
Local model

Otherwise:

Flutter
    ↓
Spring Boot
    ↓
Mock AI

is perfectly acceptable.

⸻

24. Docker

Docker can make local infrastructure easier.

Example:

docker-compose
postgres
redis
backend

Potential future addition:

local-ai

⸻

Why Docker?

It allows the development environment to become reproducible.

Another developer can eventually run:

docker compose up

and receive:

PostgreSQL
Redis
Backend dependencies

without manually installing every service.

⸻

25. Free Hosting Considerations

At some point the application needs to become publicly accessible.

Free hosting options can change over time.

Therefore:

Do not design the architecture around a specific free
hosting provider.

Instead design:

Containerized backend
+
PostgreSQL
+
Redis
+
Environment variables

so it can be deployed to whichever suitable provider is available.

⸻

26. Database Hosting

A hosted PostgreSQL database may eventually be needed.

Possible approaches:

Development:
Local PostgreSQL
Early testing:
Free/low-cost hosted PostgreSQL if available
Production:
Reliable managed PostgreSQL

The application should remain PostgreSQL-compatible across environments.

⸻

27. Redis Hosting

Development:

Local Redis

Production:

Managed Redis

or another compatible Redis service.

⸻

28. Backend Hosting

Spring Boot can eventually run as:

Docker container

This makes deployment portable.

⸻

29. Frontend Hosting

Flutter web can be deployed separately if web support is enabled.

For mobile development:

APK

can be distributed directly during testing without publishing to Google Play.

⸻

30. Domain Names

A domain is not required during development.

Development:

localhost

Testing:

temporary deployment URL

Production:

custom domain

A domain can be purchased later.

⸻

31. HTTPS

Production APIs should use HTTPS.

Local development can use:

http://localhost

or local HTTPS if needed.

Never send production credentials over plain HTTP.

⸻

32. Maps and Clinic Search

Clinic discovery introduces another provider dependency.

The architecture should use:

ClinicProvider

instead of hard-coding a particular map provider.

Conceptually:

public interface ClinicProvider {
    List<Clinic> findNearby(
        double latitude,
        double longitude,
        double radius
    );
}

⸻

Clinic Provider Implementations

Potential:

OpenMapProvider
GooglePlacesProvider
OtherClinicProvider
MockClinicProvider

The exact provider depends on:

* Coverage.
* Terms.
* Free-tier availability.
* Data quality.
* API limits.

⸻

33. Geolocation

The user’s phone can provide:

latitude
longitude

The application then sends those coordinates to the backend.

The backend performs clinic discovery.

⸻

34. Clinic Data

Do not assume that every map provider gives reliable:

* Dental specialty.
* Opening hours.
* Booking.
* Phone numbers.
* Availability.

The application should normalize whatever information is available.

⸻

35. Appointment Booking

Appointment booking should initially be treated as optional.

MVP:

Find clinic
     ↓
View information
     ↓
Call
or
Open booking page

Later:

Find clinic
     ↓
Available slots
     ↓
Select slot
     ↓
Confirm booking

⸻

36. AI Cost Management

If a cloud model is eventually used:

Every request may cost money.

Therefore:

User
 ↓
Usage check
 ↓
Context optimization
 ↓
AI

⸻

37. Token Management

Avoid sending unnecessary text.

Bad:

Entire 10,000-message conversation

Better:

Summary
+
Relevant recent messages
+
Current message

⸻

38. Context Management

The context manager should:

1. Load recent messages.
2. Load summary.
3. Retrieve relevant memory.
4. Retrieve relevant knowledge.
5. Remove unnecessary information.
6. Build the final prompt.

This reduces cost and improves relevance.

⸻

39. Caching

Cache only appropriate requests.

Good candidates:

"What is enamel?"
"What is fluoride?"
"What is a root canal?"

Potentially poor candidates:

"My face is swollen."

Personalized symptom conversations should generally not be treated like static FAQ responses.

⸻

40. Usage Limits

The backend should enforce:

Guest limit
Free-user limit
Premium limit

Example:

Guest:
3 requests/day
Free:
10 requests/day
Premium:
Higher limit

These numbers are configurable.

⸻

41. Free User Strategy

A zero-budget product can still allow users to experience AI.

For example:

Guest
  ↓
Limited AI experience
  ↓
Sign up
  ↓
More usage

The important point is:

Do not promise unlimited AI if each request costs money.

⸻

42. Paid User Strategy

If the product eventually earns revenue:

Subscription
     ↓
AI usage budget
     ↓
Higher limits

Revenue can subsidize AI infrastructure.

⸻

43. Provider Failover

Example:

Primary AI
     |
     | timeout
     v
Fallback AI
     |
     | failure
     v
Safe error

Failover should have strict retry limits.

⸻

44. Provider Outages

If the AI provider is unavailable:

The rest of DentAssist should continue working.

For example:

AI unavailable
Still available:
- User login
- Conversation history
- Clinic search
- Saved clinics
- Settings

Only AI functionality should degrade.

⸻

45. Model Switching

Because of the provider abstraction:

Model A

can eventually become:

Model B

without rewriting:

* Flutter.
* Database.
* Authentication.
* Conversations.
* Memory.

⸻

46. Secret Management

Never commit:

AI_API_KEY=real-secret

to GitHub.

Never place provider keys inside Flutter.

Bad:

Flutter
   ↓
AI Provider

because the key can be extracted from the application.

Correct:

Flutter
   ↓
DentAssist Backend
   ↓
AI Provider

⸻

47. API Security

The backend must protect:

* AI keys.
* Database credentials.
* JWT secrets.
* Provider credentials.
* Internal service URLs.

⸻

48. Abuse Prevention

Even a free application can be abused.

Potential attacks:

Bot creates thousands of accounts.
Bot sends thousands of AI requests.

Controls:

* Rate limiting.
* Usage limits.
* IP controls.
* Account-level quotas.
* Request validation.
* Suspicious activity detection.

⸻

49. AI Monitoring

Track:

Requests
Failures
Latency
Token usage
Provider costs
Fallback usage
Safety failures

This helps answer:

"Where is our money going?"

⸻

50. Budget Alerts

When real cloud AI is introduced:

Define thresholds.

Example:

Daily budget:
$1
Monthly budget:
$20

If the threshold is exceeded:

Alert
     ↓
Investigate
     ↓
Potentially disable expensive features

The exact values are examples.

⸻

51. Development Cost Table

Component	Development Cost
Flutter	$0
Spring Boot	$0
PostgreSQL local	$0
Redis local	$0
Docker	$0
Git	$0
Mock AI	$0
Local AI	$0 if hardware supports it
Cloud AI	Potential cost
Maps API	Potential cost
Domain	Potential cost
Cloud hosting	Potential cost
Google Play publishing	Requires developer account fee
iOS publishing	Requires Apple developer membership

The important point is that publishing is not required to build the application.

⸻

52. Zero-Budget MVP

The first complete prototype can be:

Flutter
     ↓
Spring Boot
     ↓
PostgreSQL
     ↓
Redis
     ↓
Mock AI

Features:

✓ Home screen
✓ Chat
✓ Conversations
✓ Message history
✓ Authentication
✓ Usage limits
✓ Basic memory
✓ Basic safety rules
✓ Clinic search interface
✓ Settings

The AI can initially be mocked.

⸻

53. First Production Version

When the product is ready for real users:

Flutter
     ↓
HTTPS
     ↓
Spring Boot
     ↓
┌────┼───────────────┐
│    │               │
DB  Redis         AI Provider
│                    │
│              ┌─────┴─────┐
│              │           │
│           Primary      Fallback
│
└──────── Clinic Provider

⸻

54. Scaling

Do not prematurely build:

10 microservices
5 databases
Kubernetes
Kafka
complex event systems

Start with:

One Spring Boot application
One PostgreSQL database
One Redis instance

This is enough for the early product.

⸻

55. What Not to Build Yet

Do not build these first:

AI fine-tuning
Advanced vector database
Complex multi-agent architecture
Voice assistant
Real-time video dentist
Advanced image diagnosis
Full appointment marketplace
Payment system
10 AI providers
Kubernetes
Microservices

These may eventually become useful.

They are not prerequisites for validating the idea.

⸻

56. Recommended Technology Stack

Initial stack:

Frontend:
Flutter
Backend:
Spring Boot
Language:
Java
Database:
PostgreSQL
Cache:
Redis
API:
REST
Authentication:
JWT / secure session architecture
AI abstraction:
AiProvider
Development AI:
MockAiProvider
Optional local AI:
LocalAiProvider
Production AI:
CloudAiProvider
Clinic abstraction:
ClinicProvider
Containerization:
Docker

⸻

57. Final Architecture

The zero-budget architecture:

                        FLUTTER
                           |
                           |
                        REST API
                           |
                           v
                  ┌─────────────────┐
                  │   SPRING BOOT   │
                  │                 │
                  │ Authentication  │
                  │ Conversations   │
                  │ Memory          │
                  │ Safety          │
                  │ Clinics         │
                  │ Usage           │
                  │ AI Orchestrator │
                  └───────┬─────────┘
                          |
             ┌────────────┼────────────┐
             |            |            |
             v            v            v
        PostgreSQL      Redis      AiProvider
                                      |
                        ┌─────────────┼─────────────┐
                        |             |             |
                        v             v             v
                       Mock         Local         Cloud
                        AI            AI            AI

⸻

58. Development Roadmap

Phase 1

Build:

Project structure
Spring Boot
Flutter
PostgreSQL
Redis
Docker

⸻

Phase 2

Build:

Authentication
Users
Conversations
Messages

⸻

Phase 3

Build:

Mock AI
AI abstraction
AI orchestration

⸻

Phase 4

Build:

Memory
Summaries
Context management

⸻

Phase 5

Build:

Safety
Usage limits
Rate limiting

⸻

Phase 6

Build:

Clinic search
Location handling
Clinic provider abstraction

⸻

Phase 7

Test:

Full application

using:

Mock AI

⸻

Phase 8

Add:

Local AI

if practical.

⸻

Phase 9

Add:

Cloud AI

when appropriate.

⸻

Phase 10

Deploy.

⸻

59. Summary

The zero-budget strategy is not:

"Find one magical AI API that is permanently free."

The strategy is:

"Build DentAssist so that no single AI provider is required
for development."

Therefore:

1. Use a provider abstraction.
2. Start with MockAiProvider.
3. Build the entire application around the mock.
4. Add LocalAiProvider if hardware permits.
5. Add CloudAiProvider later.
6. Never put AI credentials in Flutter.
7. Keep AI orchestration in Spring Boot.
8. Keep memory in the application.
9. Keep usage limits on the server.
10. Optimize context before spending money.
11. Cache appropriate non-personalized information.
12. Rate-limit expensive operations.
13. Monitor AI usage.
14. Configure budget thresholds.
15. Do not prematurely build expensive infrastructure.
16. Use local PostgreSQL during development.
17. Use local Redis during development.
18. Use Docker for reproducibility.
19. Do not buy a domain until it is useful.
20. Do not publish to an app store until the product is ready.
21. Build the web/mobile experience before worrying about publishing.
22. Keep clinic search behind a provider interface.
23. Keep appointment booking optional.
24. Treat image analysis as a later feature.
25. Build the MVP before building advanced AI infrastructure.

The result is a project that can start at:

$0

and evolve toward:

real AI
real users
real infrastructure
real revenue

without throwing away the original codebase.

## The key decision for DentAssist
I would **not** make "finding a completely free, perfect AI" our blocker.
I'd build this sequence:
```text
                TODAY
                  │
                  ▼
        ┌──────────────────┐
        │ Flutter Frontend │
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Spring Boot API  │
        └────────┬─────────┘
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
 PostgreSQL    Redis    Mock AI

Then:

Mock AI
   ↓
Local AI (optional)
   ↓
Real hosted AI

That means we can start coding the product even before we decide which AI provider ultimately powers it.

And importantly, you don’t need Google Play Store to build this. During development, you can run the Flutter app directly on an Android phone/emulator or as a web app. The Play Store becomes a distribution step, not a development requirement.

The next document should be 11_CLINIC_SEARCH_AND_LOCATION_ARCHITECTURE.md, where we design the other major half of your original idea: “find the nearest dental office around me.” We’ll cover GPS, permissions, coordinates, radius searches, geospatial database queries, free/open map data vs commercial APIs, clinic normalization, distance sorting, opening hours, phone numbers, booking links, and how to avoid showing fake or stale dental clinics.