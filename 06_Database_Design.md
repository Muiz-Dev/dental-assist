Yes. This is the point where we define the actual source of truth for the application. I’m also going to make an important distinction between data we must permanently store and data we should not store just because we can.

06_Database_Design.md

# 06_Database_Design.md
# DentAssist Database Design
Version: 1.0
Status: Draft
Dependencies:
- 00_Vision.md
- 01_Product_Requirements.md
- 02_User_Personas.md
- 03_User_Journeys.md
- 04_System_Architecture.md
- 05_Backend_Architecture.md
---
# Table of Contents
1. Introduction
2. Database Goals
3. Database Technology
4. Data Ownership
5. Data Classification
6. Entity Relationship Overview
7. UUID Strategy
8. Timestamp Strategy
9. Users
10. User Preferences
11. Refresh Tokens
12. Conversations
13. Messages
14. Conversation Summaries
15. Guest Sessions
16. Usage Records
17. Symptom Assessments
18. Symptom Answers
19. Symptom Results
20. Saved Clinics
21. Clinic Cache
22. Feedback
23. Notifications
24. Audit Events
25. Database Relationships
26. Indexing Strategy
27. Constraints
28. Soft Deletion
29. Data Retention
30. Privacy
31. Database Transactions
32. Concurrency
33. Redis vs PostgreSQL
34. Future Vector Search
35. Migration Strategy
36. Backup Strategy
37. Database Security
38. Performance
39. Example Queries
40. Final Schema
41. Summary
---
# 1. Introduction
PostgreSQL is the permanent source of truth for DentAssist.
The database stores information required to:
- Identify users.
- Authenticate users.
- Maintain conversations.
- Preserve AI chat history.
- Store symptom assessments.
- Store user preferences.
- Track usage.
- Store feedback.
- Store saved clinics.
- Manage notifications.
The database must not become a dumping ground for every piece of information the application encounters.
Only information necessary for product functionality, security, reliability, analytics, or legal requirements should be persisted.
---
# 2. Database Goals
The database must provide:
- Strong consistency.
- Referential integrity.
- Efficient querying.
- Clear relationships.
- Privacy-aware storage.
- Easy migrations.
- Reliable backups.
- Future extensibility.
The schema should remain understandable to a single developer.
---
# 3. Database Technology
Primary database:
PostgreSQL.
Recommended capabilities:
- UUID support.
- JSONB where appropriate.
- Full-text search.
- PostgreSQL extensions.
- pgvector in a future version.
---
# 4. Data Ownership
Each backend module owns its primary data.
```text
User Module
    ↓
users
user_preferences
Conversation Module
    ↓
conversations
messages
conversation_summaries
Authentication Module
    ↓
refresh_tokens
Symptom Module
    ↓
symptom_assessments
symptom_answers
symptom_results
Clinic Module
    ↓
saved_clinics
Feedback Module
    ↓
feedback
Notification Module
    ↓
notifications

This organization makes ownership clear.

⸻

5. Data Classification

Not all data has the same sensitivity.

Public Data

Examples:

* Clinic name.
* Clinic address.
* Public clinic phone number.
* Public clinic website.

⸻

Account Data

Examples:

* Email address.
* Display name.
* Timezone.
* Preferences.

⸻

Private User Data

Examples:

* Conversations.
* Symptom assessment responses.
* Saved clinics.

This information must be protected by authorization.

⸻

Security Data

Examples:

* Password hashes.
* Refresh tokens.
* Authentication metadata.

This information requires stronger controls.

⸻

6. Entity Relationship Overview

erDiagram
    USERS ||--o{ CONVERSATIONS : owns
    USERS ||--o{ REFRESH_TOKENS : has
    USERS ||--|| USER_PREFERENCES : has
    USERS ||--o{ SYMPTOM_ASSESSMENTS : creates
    USERS ||--o{ SAVED_CLINICS : saves
    USERS ||--o{ FEEDBACK : submits
    USERS ||--o{ NOTIFICATIONS : receives
    CONVERSATIONS ||--o{ MESSAGES : contains
    CONVERSATIONS ||--o{ FEEDBACK : receives
    CONVERSATIONS ||--o| CONVERSATION_SUMMARIES : has
    SYMPTOM_ASSESSMENTS ||--o{ SYMPTOM_ANSWERS : contains
    SYMPTOM_ASSESSMENTS ||--o| SYMPTOM_RESULTS : produces
    MESSAGES ||--o{ FEEDBACK : receives

⸻

7. UUID Strategy

Primary identifiers should use UUIDs rather than sequential integers.

Example:

550e8400-e29b-41d4-a716-446655440000

Benefits:

* Difficult to guess.
* Suitable for distributed systems.
* Safer for public APIs.
* Easier to generate independently.

The application should avoid exposing sequential database IDs.

⸻

8. Timestamp Strategy

All timestamps should be stored in UTC.

Recommended PostgreSQL type:

TIMESTAMPTZ

Application representation:

Instant

Common fields:

created_at
updated_at
deleted_at

User-facing timestamps are converted to the user’s configured timezone.

⸻

9. Users

Table:

users

Purpose:

Stores the core identity of an application user.

⸻

Columns

id
email
password_hash
status
email_verified
created_at
updated_at
deleted_at

⸻

Example

CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(320) NOT NULL,
    password_hash TEXT NOT NULL,
    status VARCHAR(30) NOT NULL,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ
);

⸻

Email

Email addresses should be normalized before storage.

Example:

User@Example.COM

becomes:

user@example.com

The exact normalization policy must be consistent.

⸻

User Status

Possible values:

ACTIVE
SUSPENDED
PENDING
DELETED

⸻

10. User Preferences

Table:

user_preferences

Purpose:

Stores non-critical personalization settings.

Columns:

id
user_id
display_name
preferred_language
timezone
notifications_enabled
created_at
updated_at

⸻

Relationship

users 1 ─── 1 user_preferences

⸻

11. Refresh Tokens

Table:

refresh_tokens

Purpose:

Supports long-lived authenticated sessions.

Columns:

id
user_id
token_hash
expires_at
revoked_at
created_at
last_used_at

Important:

The raw refresh token should not be stored if avoidable.

Store a secure hash.

⸻

12. Conversations

Table:

conversations

Purpose:

Represents a user’s AI conversation.

Columns:

id
user_id
title
status
created_at
updated_at
deleted_at

⸻

Conversation Status

ACTIVE
ARCHIVED
DELETED

⸻

Conversation Title

The initial title can be generated from the first message.

Example:

User:

“My tooth hurts when I drink cold water.”

Conversation title:

“Tooth sensitivity”

The title should not expose unnecessary sensitive information.

⸻

13. Messages

Table:

messages

This is one of the most important tables.

Columns:

id
conversation_id
role
content
status
provider
model
input_tokens
output_tokens
created_at

⸻

Message Role

Possible values:

USER
ASSISTANT
SYSTEM

In most cases, SYSTEM messages should not be exposed to users.

⸻

Message Status

PENDING
COMPLETED
FAILED

⸻

Why Store Provider Information?

Example:

provider = gemini
model = model-name

This allows us to understand:

* Which provider generated a response.
* Which model was used.
* Whether one provider performs better.
* How usage is distributed.

⸻

Token Usage

Potential columns:

input_tokens
output_tokens

These may be nullable because not every provider returns usage metadata.

⸻

14. Conversation Summaries

Long conversations eventually become expensive to send to an AI model.

A summary table allows older conversations to be compressed.

Table:

conversation_summaries

Columns:

id
conversation_id
summary
message_count
created_at
updated_at

⸻

Example

Instead of sending 100 old messages:

Summary:
User has experienced intermittent sensitivity
in an upper-left molar for approximately three weeks.
They report cold sensitivity and no known swelling.

Then send:

Summary
+
Recent messages
+
Current message

⸻

Important

The summary is not the authoritative medical record.

It is an AI context optimization.

The original messages remain the source of truth while retained.

⸻

15. Guest Sessions

Guests need limited functionality without accounts.

A guest session may be represented by:

guest_sessions

Columns:

id
anonymous_identifier
conversation_id
message_count
expires_at
created_at

Guest data should have a short retention period.

⸻

Guest Identifier

The application should avoid relying solely on IP addresses.

A temporary anonymous identifier may be generated by the client/backend.

⸻

16. Usage Records

Table:

usage_records

Purpose:

Tracks feature usage.

Columns:

id
user_id
guest_session_id
feature
usage_count
period_start
period_end
created_at
updated_at

⸻

Example

feature = AI_CHAT
usage_count = 4
period_start = 2026-08-30
period_end = 2026-08-31

The exact usage system may eventually move heavily into Redis for fast enforcement while PostgreSQL retains durable accounting information.

⸻

17. Symptom Assessments

Table:

symptom_assessments

Columns:

id
user_id
status
primary_symptom
started_at
completed_at
created_at

⸻

Assessment Status

IN_PROGRESS
COMPLETED
ABANDONED

⸻

Primary Symptom

Example:

TOOTH_PAIN
GUM_BLEEDING
SWELLING
TOOTH_SENSITIVITY
BROKEN_TOOTH
JAW_PAIN
MOUTH_ULCER
BAD_BREATH
OTHER

⸻

18. Symptom Answers

Table:

symptom_answers

Columns:

id
assessment_id
question_key
answer_value
created_at

⸻

Example

assessment_id = ...
question_key = pain_severity
answer_value = 7

Another:

question_key = swelling
answer_value = false

⸻

Why Key/Value?

The symptom questionnaire may evolve.

Version 1 may ask:

pain_severity
duration
swelling
fever

Version 2 may introduce:

trauma
bleeding
medication

Using a flexible answer model allows questionnaires to evolve without constantly redesigning the entire schema.

⸻

19. Symptom Results

Table:

symptom_results

Columns:

id
assessment_id
urgency_level
rule_version
explanation
created_at

⸻

Urgency Level

LOW
MODERATE
HIGH
EMERGENCY

⸻

Rule Version

Example:

rule_version = 1

This is important.

If the symptom rules change later, we must know which version produced an historical result.

⸻

20. Saved Clinics

Table:

saved_clinics

Users can save clinics.

Columns:

id
user_id
provider
provider_clinic_id
name
address
latitude
longitude
phone
website
created_at
updated_at

⸻

Why Store Clinic Information?

Because the provider may change.

A saved clinic should remain visible even if the user is temporarily offline.

However, cached information should not be presented as guaranteed current information.

⸻

21. Clinic Cache

Clinic search results should primarily be cached in Redis.

A persistent PostgreSQL clinic cache may be introduced later if needed.

Redis key:

clinic:nearby:{locationHash}:{radius}

Example:

clinic:nearby:6fabc:5000

⸻

Cache Expiration

Example:

TTL = 10 minutes

This is configurable.

⸻

22. Feedback

Table:

feedback

Columns:

id
user_id
conversation_id
message_id
rating
category
comment
created_at

⸻

Rating

POSITIVE
NEGATIVE

⸻

Category

INCORRECT
CONFUSING
IRRELEVANT
TOO_LONG
UNSAFE
OTHER

⸻

23. Notifications

Table:

notifications

Columns:

id
user_id
type
title
body
scheduled_for
sent_at
status
created_at

⸻

Notification Status

PENDING
SENT
FAILED
CANCELLED

⸻

24. Audit Events

Table:

audit_events

This is primarily for security and administrative events.

Examples:

* Login.
* Logout.
* Password change.
* Account deletion.
* Permission changes.
* Administrative actions.

Columns:

id
user_id
event_type
metadata
created_at

The metadata must not contain secrets.

⸻

25. Database Relationships

User → Conversations

One user can have many conversations.

users.id
    ↓
conversations.user_id

⸻

Conversation → Messages

One conversation can have many messages.

conversations.id
    ↓
messages.conversation_id

⸻

User → Symptom Assessments

One user can create many assessments.

⸻

Assessment → Answers

One assessment can have many answers.

⸻

Assessment → Result

One completed assessment should produce one final result for that assessment version.

⸻

26. Indexing Strategy

Indexes should support real application queries.

⸻

Users

Index:

users.email

Because login searches by email.

⸻

Conversations

Composite index:

(user_id, updated_at DESC)

Supports:

“Show my recent conversations.”

⸻

Messages

Composite index:

(conversation_id, created_at)

Supports:

“Load conversation messages chronologically.”

⸻

Symptom Answers

Index:

assessment_id

⸻

Feedback

Index:

message_id
created_at

⸻

27. Constraints

Use database constraints wherever possible.

Examples:

NOT NULL
UNIQUE
FOREIGN KEY
CHECK

⸻

Example

Email:

UNIQUE(email)

Message content:

NOT NULL

Foreign key:

messages.conversation_id
REFERENCES conversations(id)

⸻

28. Soft Deletion

Some entities may use:

deleted_at

instead of immediate physical deletion.

Useful for:

* Conversations.
* Users.

However, soft deletion is not a replacement for actual data deletion requirements.

If a user requests deletion where applicable, the system must have a defined process for permanently removing or anonymizing data.

⸻

29. Data Retention

Different data types should have different retention policies.

Example:

Guest conversations:

Short retention.

Inactive temporary data:

Short retention.

Registered conversations:

Retained until deleted by the user or according to the product’s retention policy.

Security logs:

Retained according to operational/security requirements.

Retention periods must be finalized before production launch.

⸻

30. Privacy

DentAssist should follow data minimization.

Do not store:

* Unnecessary medical information.
* Raw location history.
* Sensitive information that isn’t needed.
* AI prompts unnecessarily outside conversation history.

⸻

Location Privacy

The application should not continuously track users.

Instead:

Request location
     ↓
Find nearby clinics
     ↓
Use location
     ↓
Discard precise coordinates unless necessary

A user should not have their movement permanently recorded merely because they used the clinic finder.

⸻

31. Database Transactions

Transactions are required where multiple related records must succeed together.

Example:

User registration:

Create user
Create preferences
Create initial usage record

If one fails:

Rollback.

⸻

Chat

A typical successful message may involve:

Create user message
Generate AI response
Create assistant message
Update conversation

These operations must be designed carefully because AI generation is an external, potentially slow operation.

Do not hold a database transaction open while waiting several seconds for an external AI request.

⸻

Recommended Chat Strategy

1. Validate request.
2. Save user message.
3. Mark AI generation as pending.
4. Call AI provider outside the database transaction.
5. Save completed assistant message.
6. Update conversation metadata.

If AI generation fails:

Mark generation as failed.

This gives us reliable state management without holding database connections open unnecessarily.

⸻

32. Concurrency

Two requests may arrive simultaneously.

Example:

User taps Send twice.

The backend must prevent:

* Duplicate messages.
* Corrupted conversation ordering.
* Incorrect usage counts.

Potential solutions:

* Idempotency keys.
* Database constraints.
* Redis locks where necessary.
* Request deduplication.

⸻

Idempotency

The frontend may send:

Idempotency-Key: abc123

If the same request is accidentally sent twice, the backend can recognize it.

This is especially useful for:

* Chat messages.
* Account operations.
* Future appointment bookings.

⸻

33. Redis vs PostgreSQL

Use PostgreSQL for permanent information.

Use Redis for:

* Rate limiting.
* Temporary context.
* Cache.
* Short-lived sessions.
* Fast counters.

⸻

Example

Bad:

Store user's only copy of conversation in Redis.

Good:

PostgreSQL → permanent conversation
Redis → recent conversation cache

⸻

34. Future Vector Search

DentAssist may eventually use semantic memory.

Possible architecture:

PostgreSQL
      +
pgvector

Instead of searching only by exact keywords, the system can search by semantic similarity.

Example:

User previously said:

“My gums sometimes bleed after brushing.”

Later:

“Why does this happen?”

A vector search could retrieve the relevant older conversation.

⸻

Important

Vector memory should not automatically become medical truth.

It is a retrieval mechanism.

The application should still distinguish:

* User statements.
* AI-generated summaries.
* Verified educational content.

⸻

35. Migration Strategy

Flyway manages database changes.

Example:

V1__create_users.sql
V2__create_user_preferences.sql
V3__create_refresh_tokens.sql
V4__create_conversations.sql
V5__create_messages.sql
V6__create_conversation_summaries.sql
V7__create_guest_sessions.sql
V8__create_usage_records.sql
V9__create_symptom_assessments.sql
V10__create_symptom_answers.sql
V11__create_symptom_results.sql
V12__create_saved_clinics.sql
V13__create_feedback.sql
V14__create_notifications.sql
V15__create_audit_events.sql

Never rewrite an already-applied production migration.

Create a new migration instead.

⸻

36. Backup Strategy

Production PostgreSQL must have backups.

Minimum strategy:

* Automated backups.
* Point-in-time recovery where available.
* Periodic backup verification.

A backup that has never been restored successfully should not be considered reliable.

⸻

37. Database Security

Database credentials must:

* Never be committed to Git.
* Never be included in Flutter.
* Be stored as environment/deployment secrets.

Database access should be private.

The database should not be exposed directly to the public internet if the hosting environment allows private networking.

⸻

38. Performance

Avoid loading entire conversations unnecessarily.

Example:

Bad:

Load 10,000 messages

Better:

Load latest 20 messages
+
conversation summary

⸻

Pagination

Conversation history should be paginated.

Example:

GET /api/v1/conversations?page=0&size=20

Messages:

GET /api/v1/conversations/{id}/messages?before=...

Cursor-based pagination may be preferable for large conversations.

⸻

39. Example Queries

Find Recent Conversations

SELECT *
FROM conversations
WHERE user_id = :userId
AND deleted_at IS NULL
ORDER BY updated_at DESC
LIMIT 20;

⸻

Find Recent Messages

SELECT *
FROM messages
WHERE conversation_id = :conversationId
ORDER BY created_at DESC
LIMIT 20;

⸻

Find User’s Saved Clinics

SELECT *
FROM saved_clinics
WHERE user_id = :userId
ORDER BY created_at DESC;

⸻

40. Final Schema

The initial schema can be represented as:

users
│
├── user_preferences
├── refresh_tokens
├── conversations
│   │
│   ├── messages
│   │   └── feedback
│   │
│   └── conversation_summaries
│
├── symptom_assessments
│   │
│   ├── symptom_answers
│   └── symptom_results
│
├── saved_clinics
├── feedback
├── notifications
└── audit_events

⸻

41. Summary

PostgreSQL is the permanent source of truth for DentAssist.

The initial core tables are:

users
user_preferences
refresh_tokens
conversations
messages
conversation_summaries
guest_sessions
usage_records
symptom_assessments
symptom_answers
symptom_results
saved_clinics
feedback
notifications
audit_events

The database should follow these principles:

1. Use UUID identifiers.
2. Store timestamps in UTC.
3. Normalize emails.
4. Hash passwords.
5. Never store raw refresh tokens.
6. Use foreign keys.
7. Add indexes based on real query patterns.
8. Use transactions for related database operations.
9. Never hold long database transactions open during AI requests.
10. Use Redis for temporary/high-speed data.
11. Use PostgreSQL for permanent data.
12. Minimize sensitive data collection.
13. Provide account deletion mechanisms.
14. Use migrations.
15. Back up production data.
16. Test backup restoration.
17. Design for future pgvector support.
18. Do not treat AI-generated data as authoritative medical records.
19. Prevent duplicate requests with idempotency where appropriate.
20. Keep the schema simple until actual product requirements justify additional complexity.

The database is not merely storage.

It is the foundation that allows DentAssist to provide reliable conversation memory, user accounts, usage management, symptom history, and personalization while keeping Redis and external AI providers replaceable.

## A key thing we just solved
This document gives us a much better answer to your original **"How will the AI remember?"** question.
Imagine someone has a conversation that's 200 messages long.
We **do not** send all 200 messages to the AI every time.
Instead:
```text
                 PostgreSQL
                     │
             200-message history
                     │
                     ▼
             Context Manager
                     │
          ┌──────────┴──────────┐
          │                     │
   Conversation Summary    Recent 20 msgs
          │                     │
          └──────────┬──────────┘
                     ▼
               Current message
                     │
                     ▼
                     AI

That is the beginning of a proper memory architecture.

And later, we can add:

                 pgvector
                    │
                    ▼
        "What old information is
         relevant to this question?"
                    │
                    ▼
             Relevant memories

So memory isn’t something we have to buy from the AI provider. It’s something we can engineer ourselves.

The next document is 07_API_Specification.md. That’s a major milestone: we’ll define the actual REST API contract between Flutter and Spring Boot—every endpoint, HTTP method, authentication requirement, request body, response body, error code, pagination strategy, idempotency behavior, and API versioning convention.