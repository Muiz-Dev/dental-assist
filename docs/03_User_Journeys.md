# 03_User_Journeys.md

# DentAssist User Journeys & Interaction Flows

Version: 1.0

Status: Draft

Dependencies:

- 00_Vision.md
- 01_Product_Requirements.md
- 02_User_Personas.md

---

# Table of Contents

1. Introduction
2. Journey Design Principles
3. Application Entry
4. First-Time Guest Journey
5. AI Chat Journey
6. Conversation Memory Journey
7. Guest Usage Limit Journey
8. Registration Journey
9. Login Journey
10. Returning User Journey
11. Symptom Assessment Journey
12. Emergency Journey
13. Find a Dentist Journey
14. Clinic Details Journey
15. Appointment Journey
16. Location Permission Journey
17. Error Journeys
18. AI Failure Journey
19. Network Failure Journey
20. Account Deletion Journey
21. Feedback Journey
22. Future Image Journey
23. Complete User Journey
24. Journey-to-API Mapping

---

# 1. Introduction

This document defines how users interact with DentAssist.

A user journey describes:

- What the user wants.
- What the user sees.
- What action the user takes.
- What the system does.
- What happens next.

These journeys will eventually be translated into:

- Flutter screens.
- Flutter navigation.
- Backend API endpoints.
- Database operations.
- Redis operations.
- AI requests.
- Error handling.
- Analytics events.

---

# 2. Journey Design Principles

DentAssist follows five major interaction principles.

## Principle 1 — Value Before Registration

Users should not be forced to create an account before understanding the value of DentAssist.

A guest should be able to:

1. Open the application.
2. Ask a question.
3. Receive an answer.
4. Search for a dentist.

Registration comes later.

---

## Principle 2 — Minimize Friction

The user may be experiencing pain or anxiety.

The application should therefore avoid unnecessary steps.

For example:

Bad:

Open app → welcome page → create account → verify email → complete profile → accept preferences → finally ask question.

Good:

Open app → ask question.

---

## Principle 3 — Preserve Context

The user should never need to repeatedly explain the same problem.

---

## Principle 4 — Always Provide a Next Step

AI responses should not simply provide information.

Where appropriate, they should tell the user what they can do next.

Examples:

- Monitor symptoms.
- Contact a dentist.
- Find a nearby clinic.
- Seek urgent care.

---

## Principle 5 — Safety Overrides Convenience

If information suggests a potentially serious situation, the application should prioritize professional medical care over continued AI conversation.

---

# 3. Application Entry

When the user opens DentAssist, the application displays the home screen.

Example:

--------------------------------

DentAssist

How can we help with your dental health?

[ Ask a dental question ]

[ Check my symptoms ]

[ Find a dentist ]

[ Explore oral health ]

--------------------------------

A small disclaimer may appear:

"Educational information only. DentAssist does not diagnose or replace a dentist."

---

# 4. First-Time Guest Journey

## Step 1

User opens the application.

System checks whether the user has an existing authenticated session.

If no session exists:

User becomes a guest.

---

## Step 2

Home screen is displayed.

The user sees four primary actions:

1. Ask AI
2. Check Symptoms
3. Find Dentist
4. Learn

---

## Step 3

User selects:

"Ask a dental question."

---

## Step 4

Chat interface opens.

Example:

"Hi! I'm DentAssist. What would you like to know about your dental health?"

Input:

[ Type your question... ]

---

## Step 5

User enters:

"My tooth hurts when I drink cold water."

---

## Step 6

Frontend sends request to backend.

Example:

POST /api/v1/chat/messages

---

## Step 7

Backend:

1. Validates request.
2. Checks rate limit.
3. Retrieves conversation context.
4. Builds AI prompt.
5. Calls AI provider.
6. Validates response.
7. Stores response.
8. Returns response.

---

## Step 8

User sees AI response.

Example:

"Tooth sensitivity to cold can have several causes..."

The response should explain possible reasons without claiming a diagnosis.

---

# 5. AI Chat Journey

## Starting a New Conversation

User selects:

"New conversation."

Backend creates:

conversation_id

Example:

conv_01JABC123

---

## Sending a Message

Frontend sends:

POST /api/v1/conversations/{conversationId}/messages

Request:

{
    "message": "Why does my gum bleed?"
}

---

## Backend Processing

The backend performs:

1. Authentication check.
2. Rate-limit check.
3. Input validation.
4. Conversation lookup.
5. Context retrieval.
6. Safety classification.
7. AI provider selection.
8. Prompt construction.
9. AI request.
10. Response validation.
11. Message persistence.
12. Response delivery.

---

# 6. Conversation Memory Journey

Memory is one of the most important components of DentAssist.

The application should not depend on the AI provider remembering the conversation.

The backend owns the memory.

---

## Example Conversation

User:

"My tooth hurts."

AI:

"Where is the pain located?"

User:

"Upper left."

AI:

"How long has it been hurting?"

User:

"About three days."

User:

"It hurts when I drink cold water."

The backend understands that the final statement belongs to the same conversation.

---

# Memory Architecture

Short-term context:

Redis

Long-term storage:

PostgreSQL

Future semantic memory:

PostgreSQL + pgvector

---

# Redis Context

Redis may store the most recent messages.

Example:

conversation:conv_123:context

Containing:

- Last 10–20 messages.
- Conversation metadata.
- Temporary state.

---

# PostgreSQL Conversation

PostgreSQL permanently stores:

Conversation.

Message.

Sender.

Timestamp.

AI provider.

Model.

Token usage.

Safety classification.

---

# Context Construction

When a new message arrives:

Backend retrieves:

Recent conversation messages.

Then constructs:

SYSTEM PROMPT

+

RELEVANT USER INFORMATION

+

RECENT CONVERSATION

+

CURRENT MESSAGE

The AI receives only the information necessary for the current response.

---

# 7. Guest Usage Limit Journey

Guests should have limited free usage.

Example:

5 AI messages per day.

---

## First Message

Remaining:

4

---

## Second Message

Remaining:

3

---

## Fifth Message

Remaining:

0

---

## Sixth Message

Instead of returning an AI response:

"Create a free account to continue using DentAssist."

Buttons:

[ Create Account ]

[ Sign In ]

The user should not lose their existing conversation.

---

# Guest Conversation Preservation

Before registration, the frontend may maintain a temporary guest conversation ID.

After registration:

Backend associates the guest conversation with the new account.

Example:

Guest:

guest_conv_123

After signup:

user_id = user_456

Conversation owner becomes:

user_456

---

# 8. Registration Journey

Registration should be intentionally simple.

Fields:

- Email
- Password

Optional later:

- Name
- Date of birth
- Country
- Preferred language

Do not collect unnecessary health information during registration.

---

## Registration Flow

User selects:

"Create Account."

Frontend displays:

Email

Password

Confirm Password

---

User submits.

Backend:

1. Validates email.
2. Checks whether account exists.
3. Hashes password.
4. Creates user.
5. Creates account preferences.
6. Generates authentication tokens.
7. Associates guest data.
8. Returns authenticated session.

---

# 9. Login Journey

User enters:

Email

Password

Backend validates credentials.

If successful:

Authentication session is created.

User returns to previous destination.

Example:

If user attempted to continue a chat before logging in, they return to that chat.

---

# 10. Returning User Journey

Authenticated user opens DentAssist.

Backend validates session.

Home screen displays personalized content.

Example:

"Welcome back."

Recent conversations:

- Tooth sensitivity
- Wisdom tooth questions
- Gum bleeding

User selects:

"Tooth sensitivity."

Conversation resumes.

---

# 11. Symptom Assessment Journey

The symptom checker is separate from the AI chat.

This is intentional.

A structured workflow produces more consistent results than asking users to describe everything themselves.

---

## Step 1

User selects:

"Check my symptoms."

---

## Step 2

System asks:

"What are you experiencing?"

Options:

- Tooth pain
- Gum bleeding
- Swelling
- Broken tooth
- Tooth sensitivity
- Bad breath
- Mouth ulcer
- Jaw pain
- Other

---

## Step 3

User selects:

"Tooth pain."

---

## Step 4

System asks:

"Where is the pain?"

Options:

- Upper left
- Upper right
- Lower left
- Lower right
- Front teeth
- Multiple areas
- I'm not sure

---

## Step 5

Pain severity:

1–10

---

## Step 6

Duration:

- Less than one day
- 1–3 days
- 4–7 days
- More than one week
- More than one month

---

## Step 7

Associated symptoms:

- Swelling
- Fever
- Bleeding
- Bad taste
- Pus
- Difficulty opening mouth
- Difficulty swallowing
- Difficulty breathing
- None

---

## Step 8

System calculates a preliminary urgency category.

Possible categories:

LOW

MODERATE

HIGH

EMERGENCY

Important:

These categories are not medical diagnoses.

They are triage-oriented educational guidance.

---

# 12. Emergency Journey

Certain answers should immediately change the experience.

Example:

User selects:

"Difficulty breathing."

The application should not continue asking twenty questions.

Instead:

--------------------------------

Potential Emergency

Difficulty breathing can be associated with conditions that require immediate professional attention.

Please seek emergency medical care now.

If you are in immediate danger, contact your local emergency service.

[ Find Nearby Care ]

--------------------------------

The AI should not attempt to diagnose the underlying cause.

---

# Emergency Trigger Examples

Potential high-priority indicators include:

- Difficulty breathing.
- Severe facial swelling.
- Difficulty swallowing.
- Uncontrolled bleeding.
- Severe trauma.
- Loss of consciousness.
- Rapidly worsening symptoms.

The exact rules must be reviewed before production deployment.

---

# 13. Find a Dentist Journey

User selects:

"Find a dentist."

---

## Step 1

Application requests location permission.

---

## Step 2

If permission is granted:

Frontend obtains approximate coordinates.

Example:

latitude

longitude

---

## Step 3

Frontend sends:

GET /api/v1/clinics/nearby

Parameters:

latitude

longitude

radius

---

## Step 4

Backend queries the configured location provider.

Potential providers:

- OpenStreetMap
- Geoapify
- Google Places

The provider should be abstracted behind our own service.

---

# Clinic Search Architecture

Frontend

↓

Clinic API

↓

Clinic Service

↓

Location Provider

↓

Results

---

# Clinic Result

Each result may contain:

- Name
- Address
- Distance
- Phone
- Website
- Opening hours
- Rating
- Coordinates

Availability depends on the provider.

The application must never invent missing information.

---

# 14. Clinic Details Journey

User selects a clinic.

Details page displays:

Clinic name

Address

Distance

Opening status

Phone

Website

Available services

---

Actions:

[ Call ]

[ Directions ]

[ Website ]

[ Book Appointment ]

Not every clinic will support appointment booking.

---

# 15. Appointment Journey

DentAssist should not initially attempt to build a complete appointment-booking infrastructure.

Instead, Version 1 should support:

External booking.

If a clinic provides a booking URL:

[ Book Appointment ]

opens the provider's booking page.

---

## Future Appointment Architecture

Later:

DentAssist

↓

Clinic Integration API

↓

Clinic Scheduling System

↓

Available Slots

↓

Booking

↓

Confirmation

---

# 16. Location Permission Journey

If permission is denied:

Display:

"Location access is disabled."

Options:

[ Enable Location ]

[ Search Manually ]

---

Manual search may allow:

City

Area

Postal code

---

The application should never prevent the user from using the AI simply because location permission was denied.

---

# 17. Error Journeys

Every external dependency can fail.

Potential failures:

- AI provider unavailable.
- Location provider unavailable.
- Database unavailable.
- Redis unavailable.
- Network unavailable.
- Authentication failure.

Errors should be user-friendly.

Never display:

"NullPointerException"

or

"500 Internal Server Error"

to the user.

---

# 18. AI Failure Journey

If the primary AI provider fails:

Backend attempts a fallback provider if configured.

Example:

Gemini

↓

Failure

↓

Groq

↓

Failure

↓

OpenRouter

---

If all providers fail:

"Sorry, we're having trouble generating a response right now. Please try again shortly."

The message should not be stored as an AI answer.

---

# 19. Network Failure Journey

If the user loses connectivity:

Display:

"You're offline."

The application may still allow:

- Viewing previously loaded conversations.
- Viewing saved clinics.
- Reading cached educational content.

Sending new AI messages requires connectivity.

---

# 20. Account Deletion Journey

User navigates:

Settings

→ Account

→ Delete Account

System displays:

"Deleting your account will permanently remove your account and associated data."

User confirms.

Backend:

1. Revokes sessions.
2. Deletes account data.
3. Deletes conversations.
4. Deletes preferences.
5. Deletes associated application data.
6. Removes caches.

Third-party provider data must be handled according to applicable provider agreements and privacy requirements.

---

# 21. Feedback Journey

After an AI response:

👍 Helpful

👎 Not Helpful

If user selects 👎:

Optional:

"What went wrong?"

Options:

- Incorrect
- Confusing
- Not relevant
- Too long
- Unsafe
- Other

This feedback becomes valuable for improving the system.

---

# 22. Future Image Journey

Image analysis should not be part of the initial MVP.

Future flow:

User:

"Show me what might be wrong."

↓

Upload image

↓

Image validation

↓

Image processing

↓

AI vision model

↓

Safety filtering

↓

Educational interpretation

---

The system must never say:

"You definitely have X."

Instead:

"The image appears to show redness around the gumline. An image alone cannot confirm the cause. A dentist should examine it if symptoms persist or worsen."

---

# 23. Complete User Journey

Example:

User experiences tooth pain.

↓

Opens DentAssist.

↓

Selects:

"Check my symptoms."

↓

Answers guided questions.

↓

System determines that professional evaluation may be appropriate.

↓

User selects:

"Ask DentAssist."

↓

AI receives structured symptom information.

↓

AI explains possible causes and appropriate next steps.

↓

User selects:

"Find a dentist."

↓

Location permission granted.

↓

Nearby clinics displayed.

↓

User selects clinic.

↓

User selects:

"Book Appointment."

↓

External booking page opens.

↓

User receives treatment from a professional.

---

# 24. Journey-to-API Mapping

| Journey | API |
|---|---|
| Start Chat | POST /api/v1/conversations |
| Send Message | POST /api/v1/conversations/{id}/messages |
| Conversation History | GET /api/v1/conversations |
| Conversation | GET /api/v1/conversations/{id} |
| Delete Conversation | DELETE /api/v1/conversations/{id} |
| Register | POST /api/v1/auth/register |
| Login | POST /api/v1/auth/login |
| Logout | POST /api/v1/auth/logout |
| Current User | GET /api/v1/users/me |
| Nearby Clinics | GET /api/v1/clinics/nearby |
| Clinic Details | GET /api/v1/clinics/{id} |
| Submit Feedback | POST /api/v1/feedback |
| Delete Account | DELETE /api/v1/users/me |

---

# Final Journey Principle

The ideal DentAssist experience should feel like this:

Problem

↓

Understanding

↓

Guidance

↓

Professional Care

The application should never attempt to become the final authority.

DentAssist's job is to help the user make a better next decision.