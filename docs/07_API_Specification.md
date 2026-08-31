Absolutely. Now we define the contract between the frontend and backend. This is important because once this is clear, Flutter and Spring Boot can be developed somewhat independently without us constantly guessing what the other side expects.

07_API_Specification.md

# 07_API_Specification.md
# DentAssist REST API Specification
Version: 1.0
Status: Draft
Base URL:
    /api/v1
Dependencies:
- 00_Vision.md
- 01_Product_Requirements.md
- 02_User_Personas.md
- 03_User_Journeys.md
- 04_System_Architecture.md
- 05_Backend_Architecture.md
- 06_Database_Design.md
---
# Table of Contents
1. Introduction
2. API Design Principles
3. Base URL
4. HTTP Methods
5. Authentication
6. Authorization
7. Request IDs
8. Idempotency
9. Standard Response Format
10. Error Format
11. HTTP Status Codes
12. API Versioning
13. Authentication Endpoints
14. User Endpoints
15. Conversation Endpoints
16. Message Endpoints
17. AI Behavior
18. Symptom Assessment Endpoints
19. Clinic Endpoints
20. Saved Clinic Endpoints
21. Feedback Endpoints
22. Notification Endpoints
23. Usage Endpoints
24. Guest Mode
25. Pagination
26. Cursor Pagination
27. Filtering
28. Sorting
29. Rate Limiting
30. Validation
31. Security Headers
32. Content Types
33. File Uploads
34. Image Analysis
35. Appointment Integration
36. API Error Codes
37. API Documentation
38. API Testing
39. Backward Compatibility
40. Deprecation
41. Example User Journey
42. Final Endpoint Map
43. Summary
---
# 1. Introduction
The DentAssist API is the communication layer between:
- Flutter/mobile clients.
- Future web clients.
- Administrative interfaces.
- The Spring Boot backend.
The API must remain stable even if the internal backend implementation changes.
For example:
The backend may change:
    Gemini
    ↓
    another AI provider
without requiring the Flutter application to understand the provider change.
The client should communicate with DentAssist.
It should not communicate directly with AI providers.
---
# 2. API Design Principles
The API follows these principles:
1. REST-oriented resources.
2. JSON by default.
3. Versioned endpoints.
4. Predictable response structures.
5. Consistent errors.
6. Explicit authentication.
7. Strong authorization.
8. Input validation.
9. Pagination for collections.
10. Idempotency for sensitive operations.
11. No provider-specific implementation details exposed unnecessarily.
---
# 3. Base URL
Development:
    http://localhost:8080/api/v1
Production:
    https://api.example.com/api/v1
The actual production domain will be selected during deployment.
Flutter should store the API base URL in configuration rather than hard-code it throughout the application.
---
# 4. HTTP Methods
Use standard HTTP methods.
GET:
    Retrieve information.
POST:
    Create a resource or execute an action.
PUT:
    Replace a resource.
PATCH:
    Partially update a resource.
DELETE:
    Delete a resource.
---
# 5. Authentication
Protected endpoints require authentication.
Example:
    Authorization: Bearer <access-token>
The backend validates the token before allowing access.
---
# Authentication Architecture
```text
Flutter
   |
   | Authorization: Bearer token
   v
Spring Security
   |
   v
Authentication Filter
   |
   v
Authenticated User
   |
   v
Controller

⸻

6. Authorization

Authentication does not automatically grant access to every resource.

Example:

User A:

user_id = A

Conversation:

conversation.user_id = B

If User A requests User B’s conversation:

403 Forbidden

or:

404 Not Found

depending on the chosen information-disclosure policy.

The implementation should avoid leaking whether private resources exist.

⸻

7. Request IDs

Every API request should have a correlation ID.

Header:

X-Request-ID: req_abc123

If absent, the backend generates one.

The request ID should be returned in error responses.

Example:

{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "Something went wrong.",
    "requestId": "req_abc123"
  }
}

⸻

8. Idempotency

Certain POST operations can accidentally be sent twice.

For example:

User taps:

Send

Network fails.

Flutter retries.

Without protection:

Message 1
Message 2

may be created.

The client may send:

Idempotency-Key: 01JXYZ123

The backend uses the key to recognize duplicate requests.

⸻

Operations That Should Support Idempotency

Initially:

* Sending chat messages.
* Creating appointments when appointment booking is eventually supported.
* Other financially or operationally significant operations.

⸻

9. Standard Response Format

Successful responses should use a predictable structure.

Example:

{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000"
  }
}

Collections:

{
  "data": [
    {
      "id": "..."
    },
    {
      "id": "..."
    }
  ],
  "pagination": {
    "hasMore": true
  }
}

⸻

10. Error Format

All application errors should use a standard structure.

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data.",
    "requestId": "req_abc123",
    "details": []
  }
}

⸻

Validation Error

Example:

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data.",
    "requestId": "req_abc123",
    "details": [
      {
        "field": "message",
        "code": "REQUIRED",
        "message": "Message is required."
      }
    ]
  }
}

⸻

11. HTTP Status Codes

Use conventional status codes.

200:

Successful request.

201:

Resource created.

202:

Request accepted for asynchronous processing.

204:

Successful request with no response body.

400:

Invalid request.

401:

Authentication required or invalid.

403:

Authenticated but not authorized.

404:

Resource not found.

409:

Conflict.

422:

Semantically invalid request.

429:

Rate limit exceeded.

500:

Unexpected server error.

502:

Upstream provider failure.

503:

Service temporarily unavailable.

⸻

12. API Versioning

Initial version:

/api/v1

Future breaking version:

/api/v2

Do not introduce breaking changes into v1 without a migration strategy.

⸻

13. Authentication Endpoints

Base:

/api/v1/auth

⸻

Register

POST /auth/register

Request:

{
  "email": "user@example.com",
  "password": "strong-password"
}

Response:

{
  "data": {
    "user": {
      "id": "...",
      "email": "user@example.com"
    },
    "accessToken": "...",
    "refreshToken": "..."
  }
}

⸻

Password Rules

The backend should enforce reasonable password requirements.

Do not make the requirements unnecessarily hostile to users.

The exact policy should be finalized during implementation.

⸻

Login

POST /auth/login

Request:

{
  "email": "user@example.com",
  "password": "strong-password"
}

Response:

{
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}

⸻

Refresh Token

POST /auth/refresh

Request:

{
  "refreshToken": "..."
}

Response:

{
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}

The refresh token may be rotated.

⸻

Logout

POST /auth/logout

Response:

204 No Content

The refresh token should be revoked.

⸻

14. User Endpoints

Base:

/api/v1/users

⸻

Get Current User

GET /users/me

Response:

{
  "data": {
    "id": "...",
    "email": "user@example.com",
    "displayName": null,
    "preferredLanguage": "en",
    "timezone": "Africa/Lagos"
  }
}

⸻

Update Current User

PATCH /users/me

Request:

{
  "displayName": "John"
}

⸻

Update Preferences

PATCH /users/me/preferences

Request:

{
  "preferredLanguage": "en",
  "timezone": "Africa/Lagos",
  "notificationsEnabled": true
}

⸻

Delete Account

DELETE /users/me

This operation should require appropriate confirmation.

Potential flow:

DELETE /users/me
        ↓
Authenticate
        ↓
Verify confirmation
        ↓
Deactivate/delete account
        ↓
Revoke sessions
        ↓
Handle retained data
        ↓
Return success

⸻

15. Conversation Endpoints

Base:

/api/v1/conversations

⸻

Create Conversation

POST /conversations

Request:

{}

Response:

{
  "data": {
    "id": "...",
    "title": null,
    "status": "ACTIVE",
    "createdAt": "...",
    "updatedAt": "..."
  }
}

⸻

List Conversations

GET /conversations

Optional:

?page=0&size=20

Response:

{
  "data": [
    {
      "id": "...",
      "title": "Tooth sensitivity",
      "status": "ACTIVE",
      "createdAt": "...",
      "updatedAt": "..."
    }
  ],
  "pagination": {
    "page": 0,
    "size": 20,
    "hasMore": false
  }
}

⸻

Get Conversation

GET /conversations/{conversationId}

Response:

{
  "data": {
    "id": "...",
    "title": "Tooth sensitivity",
    "status": "ACTIVE",
    "createdAt": "...",
    "updatedAt": "..."
  }
}

⸻

Delete Conversation

DELETE /conversations/{conversationId}

Response:

204 No Content

⸻

Archive Conversation

POST /conversations/{conversationId}/archive

Response:

{
  "data": {
    "id": "...",
    "status": "ARCHIVED"
  }
}

⸻

16. Message Endpoints

Base:

/api/v1/conversations/{conversationId}/messages

⸻

Send Message

POST /conversations/{conversationId}/messages

Request:

{
  "message": "My tooth hurts when I drink something cold."
}

Headers:

Authorization: Bearer <token>
Idempotency-Key: <unique-key>

Response:

{
  "data": {
    "conversationId": "...",
    "userMessage": {
      "id": "...",
      "content": "My tooth hurts when I drink something cold.",
      "role": "USER",
      "createdAt": "..."
    },
    "assistantMessage": {
      "id": "...",
      "content": "Cold sensitivity can have several possible causes...",
      "role": "ASSISTANT",
      "createdAt": "..."
    }
  }
}

⸻

Get Messages

GET /conversations/{conversationId}/messages

Example:

?limit=20

Response:

{
  "data": [
    {
      "id": "...",
      "role": "USER",
      "content": "...",
      "createdAt": "..."
    },
    {
      "id": "...",
      "role": "ASSISTANT",
      "content": "...",
      "createdAt": "..."
    }
  ],
  "pagination": {
    "hasMore": true,
    "nextCursor": "..."
  }
}

⸻

17. AI Behavior

The API deliberately hides AI provider details from the frontend.

Flutter should not know:

Gemini API key
Groq API key
OpenRouter API key
model-specific prompts

Flutter only knows:

DentAssist API

⸻

AI Response Metadata

The API may optionally expose:

{
  "data": {
    "content": "...",
    "messageId": "...",
    "safety": {
      "level": "NORMAL"
    }
  }
}

Provider information should generally remain internal.

⸻

18. Symptom Assessment Endpoints

Base:

/api/v1/assessments

⸻

Create Assessment

POST /assessments

Request:

{
  "type": "TOOTH_PAIN"
}

Response:

{
  "data": {
    "id": "...",
    "status": "IN_PROGRESS",
    "type": "TOOTH_PAIN"
  }
}

⸻

Get Assessment

GET /assessments/{assessmentId}

⸻

Submit Answer

POST /assessments/{assessmentId}/answers

Request:

{
  "questionKey": "painSeverity",
  "answer": 7
}

⸻

Complete Assessment

POST /assessments/{assessmentId}/complete

Response:

{
  "data": {
    "assessmentId": "...",
    "urgency": "MODERATE",
    "explanation": "Your answers suggest that a dental evaluation would be appropriate."
  }
}

⸻

Important Safety Rule

The assessment endpoint must not claim:

"You have an abscess."

It should instead communicate:

"Your answers may be consistent with a condition that should be evaluated by a dentist."

The system provides guidance, not diagnosis.

⸻

Emergency Result

If the rules detect an emergency indicator:

{
  "data": {
    "urgency": "EMERGENCY",
    "message": "Your symptoms may require urgent medical attention."
  }
}

The exact emergency wording must be professionally reviewed before launch.

⸻

19. Clinic Endpoints

Base:

/api/v1/clinics

⸻

Find Nearby Clinics

GET /clinics/nearby

Parameters:

latitude
longitude
radius

Example:

GET /clinics/nearby?latitude=6.5244&longitude=3.3792&radius=5000

Response:

{
  "data": [
    {
      "id": "...",
      "name": "Example Dental Clinic",
      "address": "Example address",
      "latitude": 6.52,
      "longitude": 3.38,
      "phone": "+234...",
      "website": "...",
      "distanceMeters": 750
    }
  ]
}

⸻

Location Privacy

The backend should use coordinates only as necessary for the search.

The application should not create a permanent location history unless the user explicitly uses a feature that requires it.

⸻

Clinic Details

GET /clinics/{clinicId}

This may return normalized provider information.

⸻

20. Saved Clinic Endpoints

Base:

/api/v1/users/me/saved-clinics

⸻

Save Clinic

POST /users/me/saved-clinics

Request:

{
  "provider": "example-provider",
  "providerClinicId": "123",
  "name": "Example Dental Clinic"
}

⸻

List Saved Clinics

GET /users/me/saved-clinics

⸻

Remove Saved Clinic

DELETE /users/me/saved-clinics/{savedClinicId}

⸻

21. Feedback Endpoints

Base:

/api/v1/feedback

⸻

Submit Message Feedback

POST /feedback

Request:

{
  "messageId": "...",
  "rating": "NEGATIVE",
  "category": "CONFUSING",
  "comment": "I didn't understand the explanation."
}

Response:

{
  "data": {
    "id": "...",
    "status": "RECEIVED"
  }
}

⸻

Feedback Purpose

Feedback can eventually help us identify:

* Bad answers.
* Missing information.
* Safety problems.
* UX problems.
* Prompt failures.

It should not automatically be treated as ground truth.

⸻

22. Notification Endpoints

Base:

/api/v1/notifications

⸻

List Notifications

GET /notifications

⸻

Mark Notification Read

POST /notifications/{notificationId}/read

⸻

23. Usage Endpoints

Base:

/api/v1/usage

⸻

Get Current Usage

GET /usage

Response:

{
  "data": {
    "aiChat": {
      "used": 3,
      "limit": 5,
      "remaining": 2
    }
  }
}

⸻

Why Expose Usage?

The frontend can display:

2 AI messages remaining today.

This creates transparency.

The frontend must never be trusted to enforce the limit.

The backend is authoritative.

⸻

24. Guest Mode

Guest users should be able to experience the core product before registration.

Possible guest endpoints:

POST /guest/session
POST /guest/conversations
POST /guest/conversations/{id}/messages

⸻

Guest Flow

Open App
   ↓
Guest Session
   ↓
Ask Question
   ↓
AI Response
   ↓
Usage Limit
   ↓
"Create an account to continue"

This supports the product principle:

Demonstrate value before demanding registration.

⸻

Guest Restrictions

Guests may have:

* Fewer messages.
* No long-term history.
* No saved clinics.
* No advanced features.

Registered users receive:

* Persistent history.
* Higher limits.
* Saved clinics.
* More features.

⸻

25. Pagination

Never return unlimited collections.

Bad:

GET /conversations

returning:

50,000 conversations

Good:

GET /conversations?page=0&size=20

⸻

Maximum Page Size

The backend should enforce a maximum.

Example:

size <= 100

If the client requests:

size=100000

the backend rejects or caps it.

⸻

26. Cursor Pagination

Cursor pagination is preferred for rapidly changing datasets.

Example:

GET /messages?limit=20&before=<cursor>

Response:

{
  "data": [],
  "pagination": {
    "hasMore": true,
    "nextCursor": "eyJpZCI6..."
  }
}

The cursor should be opaque.

The frontend should not interpret it.

⸻

27. Filtering

Where useful, resources may support filters.

Example:

GET /conversations?status=ARCHIVED

Do not create dozens of filters before they are needed.

⸻

28. Sorting

Example:

GET /conversations?sort=updatedAt_desc

Allowed sorting fields should be whitelisted.

Never dynamically concatenate arbitrary client-provided fields into SQL.

⸻

29. Rate Limiting

API limits exist at multiple levels.

Example:

IP
 ↓
Global API limit
 ↓
User
 ↓
Feature
 ↓
AI provider

⸻

AI Rate Limit

The AI endpoint may have a stricter limit than:

GET /users/me

because AI requests consume external resources.

⸻

Rate Limit Response

HTTP:

429 Too Many Requests

Response:

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "You have reached your current usage limit.",
    "requestId": "req_abc123"
  }
}

⸻

30. Validation

All user-controlled input must be validated.

Examples:

Message:

Required
Maximum length

Latitude:

-90 to 90

Longitude:

-180 to 180

Radius:

Positive
Maximum allowed value

Email:

Valid format

UUID:

Valid UUID

⸻

31. Security Headers

Production API responses should include appropriate security headers.

Examples include:

Content-Security-Policy
X-Content-Type-Options
Referrer-Policy

The exact headers depend on deployment architecture.

⸻

32. Content Types

Default request:

Content-Type: application/json

Default response:

Content-Type: application/json

Character encoding:

UTF-8

⸻

33. File Uploads

The initial API should avoid unnecessary file upload complexity.

However, future image analysis will require uploads.

Potential endpoint:

POST /conversations/{id}/images

Multipart request:

image=<file>

The backend should:

1. Validate MIME type.
2. Validate file size.
3. Validate image dimensions.
4. Scan/validate the file.
5. Store temporarily or in object storage.
6. Process it.
7. Delete temporary data according to retention policy.

⸻

34. Image Analysis

Image analysis is a future capability.

Potential flow:

Flutter
   ↓
Upload dental image
   ↓
Spring Boot
   ↓
Validate image
   ↓
Image processing
   ↓
AI vision model
   ↓
Safety validation
   ↓
Response

⸻

Important Product Constraint

The image feature must not claim:

"This image proves you have cavity X."

Instead:

"The image may show an area that should be examined by a dentist."

Images can be misleading because:

* Lighting varies.
* Camera quality varies.
* Angles vary.
* Hidden areas cannot be observed.
* Similar visual appearances can have different causes.

⸻

Image Privacy

Images should have stricter retention policies than ordinary text.

The default should be:

Do not retain longer than necessary.

If retention is introduced later, the user should understand what is being stored and why.

⸻

35. Appointment Integration

Appointment booking is a future feature.

The API should not initially pretend that every clinic can be booked.

Potential future endpoint:

GET /clinics/{id}/appointment-options

Possible response:

{
  "data": {
    "bookingAvailable": true,
    "provider": "example-provider",
    "bookingUrl": "..."
  }
}

⸻

External Booking

Some clinics may not expose an API.

In that case, DentAssist may simply provide:

Call clinic

or:

Visit booking website

rather than pretending DentAssist completed a booking.

⸻

36. API Error Codes

Standard error codes:

VALIDATION_ERROR
UNAUTHORIZED
FORBIDDEN
RESOURCE_NOT_FOUND
CONFLICT
RATE_LIMIT_EXCEEDED
USAGE_LIMIT_EXCEEDED
AI_PROVIDER_ERROR
AI_TIMEOUT
CLINIC_PROVIDER_ERROR
CLINIC_PROVIDER_TIMEOUT
ASSESSMENT_INVALID
ASSESSMENT_ALREADY_COMPLETED
IMAGE_TOO_LARGE
UNSUPPORTED_IMAGE
INTERNAL_ERROR
SERVICE_UNAVAILABLE

⸻

37. API Documentation

The API should generate OpenAPI documentation.

Potential URL during development:

/swagger-ui/index.html

OpenAPI specification:

/v3/api-docs

These should be restricted or configured appropriately in production.

⸻

38. API Testing

Every endpoint should eventually have tests.

Example:

Auth
├── Register
├── Login
├── Refresh
└── Logout
Conversation
├── Create
├── List
├── Get
├── Delete
└── Archive
Messages
├── Send
├── Duplicate Send
├── Get
└── Unauthorized Access
Clinics
├── Nearby
└── Details
Assessments
├── Create
├── Answer
├── Complete
└── Invalid Input

⸻

Security Tests

Must verify:

User A cannot access User B's conversation.
User A cannot delete User B's conversation.
Expired token cannot access protected endpoint.
Invalid token cannot access protected endpoint.
Guest cannot access registered-only resources.
Rate limits cannot be bypassed simply by modifying frontend state.

⸻

39. Backward Compatibility

Once Flutter is released, changing API contracts becomes expensive.

Therefore:

Avoid changing:

{
  "message": "..."
}

into:

{
  "text": "..."
}

without a compatibility strategy.

Instead, introduce new fields/endpoints when necessary.

⸻

40. Deprecation

When an endpoint needs replacement:

1. Mark it deprecated.
2. Document the replacement.
3. Keep it temporarily.
4. Update clients.
5. Monitor usage.
6. Remove it only after migration.

⸻

41. Example User Journey

Consider:

User opens DentAssist.

They are not authenticated.

⸻

Step 1

Flutter creates guest session.

POST /guest/session

⸻

Step 2

User asks:

"Why does my tooth hurt when I drink cold water?"

Flutter:

POST /guest/conversations/{id}/messages

⸻

Step 3

Backend:

Validate
   ↓
Rate limit
   ↓
Create message
   ↓
Build context
   ↓
AI
   ↓
Safety check
   ↓
Save response

⸻

Step 4

AI response:

Cold sensitivity can have several possible causes.
It may be related to exposed dentin, gum recession,
tooth wear, decay, or another dental issue.
If the pain is severe, lasts after the cold stimulus
is removed, or occurs with swelling or fever, you
should seek professional dental evaluation.

⸻

Step 5

User reaches guest limit.

Backend:

{
  "error": {
    "code": "USAGE_LIMIT_EXCEEDED",
    "message": "Create an account to continue using AI chat."
  }
}

Flutter displays:

Create a free account to continue.

⸻

42. Final Endpoint Map

AUTH
POST   /auth/register
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout
USER
GET    /users/me
PATCH  /users/me
PATCH  /users/me/preferences
DELETE /users/me
CONVERSATIONS
POST   /conversations
GET    /conversations
GET    /conversations/{id}
DELETE /conversations/{id}
POST   /conversations/{id}/archive
MESSAGES
POST   /conversations/{id}/messages
GET    /conversations/{id}/messages
ASSESSMENTS
POST   /assessments
GET    /assessments/{id}
POST   /assessments/{id}/answers
POST   /assessments/{id}/complete
CLINICS
GET    /clinics/nearby
GET    /clinics/{id}
SAVED CLINICS
POST   /users/me/saved-clinics
GET    /users/me/saved-clinics
DELETE /users/me/saved-clinics/{id}
FEEDBACK
POST   /feedback
NOTIFICATIONS
GET    /notifications
POST   /notifications/{id}/read
USAGE
GET    /usage
GUEST
POST   /guest/session
POST   /guest/conversations
POST   /guest/conversations/{id}/messages

⸻

43. Summary

The DentAssist API exists to create a stable boundary between clients and backend services.

The key principles are:

1. Use /api/v1.
2. Use JSON.
3. Use predictable response envelopes.
4. Use predictable error structures.
5. Authenticate protected resources.
6. Authorize resource ownership.
7. Validate all user input.
8. Rate-limit expensive operations.
9. Use idempotency for operations that may be retried.
10. Paginate collections.
11. Prefer cursor pagination for messages.
12. Hide AI provider implementation details.
13. Hide provider API keys from clients.
14. Keep image processing server-side.
15. Do not present AI outputs as diagnoses.
16. Do not pretend every clinic supports online booking.
17. Give users transparent usage information.
18. Support a useful guest experience.
19. Keep the API backward-compatible.
20. Document the API with OpenAPI.

The API contract should be finalized before the Flutter frontend and Spring Boot implementation become deeply coupled.

The frontend should depend on this contract.

The backend should implement this contract.

Neither side should depend unnecessarily on the internal implementation details of the other.

### The architecture is starting to become real
We now have:
```text
01  Product Requirements
02  Users
03  User Journeys
04  System Architecture
05  Backend Architecture
06  Database Design
07  API Specification

And there’s an important architectural picture emerging:

                         DENTASSIST
                             │
                ┌────────────┴────────────┐
                │                         │
             Flutter                  Spring Boot
             Frontend                    Backend
                │                         │
                │                  ┌──────┴──────┐
                │                  │             │
                │                Redis       PostgreSQL
                │                  │             │
                │                  └──────┬──────┘
                │                         │
                │                    AI Service
                │                         │
                │              ┌──────────┼──────────┐
                │              │          │          │
                │             AI       Context    Safety
                │          Provider     Memory
                │
                │
                └────────────── REST API

And this is why I wouldn’t worry too much yet about finding a “perfect free AI.” The architecture deliberately puts an AiProvider abstraction between your app and the model.

That means we can build the entire application around:

“DentAssist needs an AI capable of answering dental questions.”

rather than:

“DentAssist must permanently depend on AI provider X.”

We can use whatever provider/model is practical during development, mock it completely during testing, and swap providers later without rewriting the conversation system.

Next is 08_AI_Architecture_and_Memory.md. That’s probably the most important document in the entire project for your original concern: exactly how the AI gets dental-only behavior, how conversation memory works, how long-term memory works, how context is selected, how summaries are created, how we prevent context drift, how safety boundaries work, how image analysis eventually fits in, and how we can build it without paying for an AI API during development.