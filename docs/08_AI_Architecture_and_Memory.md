Absolutely. This is the core AI architecture document. It answers the question you’ve been worried about most: “How do we make the AI remember, stay on topic, and not become inconsistent?”

08_AI_Architecture_and_Memory.md

# 08_AI_Architecture_and_Memory.md
# DentAssist AI Architecture & Memory
Version: 1.0
Status: Draft
Dependencies:
- 00_Vision.md
- 01_Product_Requirements.md
- 03_User_Journeys.md
- 04_System_Architecture.md
- 05_Backend_Architecture.md
- 06_Database_Design.md
- 07_API_Specification.md
---
# Table of Contents
1. Introduction
2. The AI Problem
3. What DentAssist AI Is
4. What DentAssist AI Is Not
5. AI Architecture
6. AI Provider Abstraction
7. The AiProvider Interface
8. Provider Selection
9. Local Development Without Paid AI
10. Mock AI Provider
11. AI Request Lifecycle
12. Conversation Memory
13. Short-Term Memory
14. Long-Term Memory
15. Conversation Summaries
16. Context Assembly
17. Context Budgeting
18. Memory Relevance
19. Memory Retrieval
20. User Facts
21. Memory Confidence
22. Memory Expiration
23. Memory Contradictions
24. Context Priority
25. System Instructions
26. Dental Scope
27. Out-of-Scope Questions
28. Prompt Injection
29. AI Safety Layer
30. Medical/Dental Limitations
31. Emergency Detection
32. Structured AI Output
33. AI Response Validation
34. Hallucination Reduction
35. Knowledge Retrieval
36. Retrieval-Augmented Generation
37. Dental Knowledge Base
38. Source Trust
39. Citation Strategy
40. Image Analysis
41. Image Safety
42. AI Conversation State
43. Failed AI Requests
44. Provider Failover
45. AI Cost Control
46. Usage Limits
47. Caching
48. Streaming
49. Model Selection
50. AI Observability
51. AI Metrics
52. Prompt Versioning
53. AI Evaluation
54. Test Conversations
55. Regression Testing
56. Human Review
57. Privacy
58. Data Retention
59. Architecture Evolution
60. Final AI Pipeline
61. Final Memory Architecture
62. Summary
---
# 1. Introduction
DentAssist is an AI-assisted dental information and guidance application.
The AI is responsible for conversational interaction.
However, the AI itself is not the application.
This distinction is fundamental.
The application owns:
- Users.
- Authentication.
- Conversations.
- Message history.
- Usage limits.
- Symptom assessments.
- Clinic discovery.
- Saved clinics.
- Safety rules.
- Memory management.
The AI provides:
- Natural-language understanding.
- Natural-language generation.
- Conversational explanations.
- Question answering.
- Summarization.
- Limited interpretation of supported inputs.
---
# 2. The AI Problem
A simple implementation might look like:
```text
User Question
     ↓
AI API
     ↓
Answer

This is insufficient for DentAssist.

The AI must understand:

* What the user previously said.
* What question is currently being discussed.
* Which information is relevant.
* Which information is uncertain.
* Which information should not be assumed.
* Whether the question is dental-related.
* Whether the user may require professional care.
* Whether the request contains dangerous instructions.
* Whether the answer is appropriate for the application’s purpose.

Therefore:

AI Provider

is only one component.

The complete AI system is:

AI Provider
+
Context Manager
+
Memory Manager
+
Safety Layer
+
Prompt Manager
+
Response Validator
+
Knowledge Retrieval
+
Usage Manager

⸻

3. What DentAssist AI Is

DentAssist AI is a:

Dental information and guidance assistant.

It can help users:

* Understand common dental concepts.
* Explain dental terminology.
* Discuss symptoms in general terms.
* Explain possible causes.
* Suggest appropriate next steps.
* Explain common dental procedures.
* Help users prepare questions for a dentist.
* Help interpret publicly available dental information.
* Help users find nearby dental services.

⸻

4. What DentAssist AI Is Not

DentAssist must not represent itself as:

* A dentist.
* A doctor.
* A replacement for professional dental care.
* A definitive diagnostic system.
* An emergency service.

The AI should not confidently declare:

"You have a cavity."

Instead:

"A cavity is one possible cause of these symptoms, but a dentist would need to examine the tooth to determine the cause."

⸻

5. AI Architecture

The complete pipeline:

                       USER MESSAGE
                            |
                            v
                     Request Validator
                            |
                            v
                      Usage Manager
                            |
                            v
                    Conversation Loader
                            |
                            v
                     Memory Manager
                            |
                            v
                    Context Assembler
                            |
                            v
                     Prompt Manager
                            |
                            v
                    Safety Pre-check
                            |
                            v
                      AI Provider
                            |
                            v
                  Response Validator
                            |
                            v
                    Safety Post-check
                            |
                            v
                    Memory Processor
                            |
                            v
                    Conversation Store
                            |
                            v
                         CLIENT

⸻

6. AI Provider Abstraction

The application must never tightly couple business logic to one AI provider.

Bad architecture:

GeminiService.generate(...)

used throughout the entire application.

Better:

AiProvider.generate(...)

with provider-specific implementations.

Example:

AiProvider
   |
   +--- GeminiAiProvider
   |
   +--- OpenAiProvider
   |
   +--- LocalAiProvider
   |
   +--- MockAiProvider

⸻

7. The AiProvider Interface

Conceptually:

public interface AiProvider {
    AiResponse generate(AiRequest request);
    boolean isAvailable();
    AiProviderInfo getInfo();
}

The rest of the backend does not need to know how the provider works.

⸻

AiRequest

Conceptual structure:

AiRequest
├── systemInstructions
├── conversationContext
├── userMessage
├── retrievedKnowledge
├── safetyInstructions
├── outputSchema
└── generationOptions

⸻

AiResponse

Conceptual structure:

AiResponse
├── content
├── provider
├── model
├── inputTokens
├── outputTokens
├── finishReason
└── metadata

⸻

8. Provider Selection

The backend may choose a provider based on:

* Availability.
* Cost.
* Latency.
* Model capability.
* Feature requirements.
* Image support.

Example:

Text Question
     ↓
Primary AI Provider
     ↓
Failure?
     ↓
Fallback Provider

⸻

9. Local Development Without Paid AI

This is extremely important.

We do not need to pay an AI provider to build the entire application.

During early development:

Flutter
   ↓
Spring Boot
   ↓
MockAiProvider
   ↓
Predefined Responses

This lets us build:

* Chat UI.
* Authentication.
* Conversations.
* Database.
* Redis.
* API.
* Usage limits.
* Error handling.
* Loading states.
* Retry behavior.

without making real AI requests.

⸻

10. Mock AI Provider

The mock provider can recognize test questions.

Example:

"My tooth hurts"

returns:

"Tooth pain can have several possible causes..."

Another:

"How do I brush properly?"

returns:

"A general recommendation is to brush twice daily..."

This is not intended for production.

It is a development tool.

⸻

Deterministic Testing

A mock provider is particularly useful because it is deterministic.

Given:

Input A

it always returns:

Output A

Therefore automated tests do not depend on an external AI service.

⸻

11. AI Request Lifecycle

When a user sends:

"My gum is bleeding."

the backend performs:

1. Authenticate user.
2. Validate request.
3. Check usage limit.
4. Load conversation.
5. Store user message.
6. Load recent messages.
7. Load conversation summary.
8. Retrieve relevant memory.
9. Determine dental scope.
10. Run safety pre-check.
11. Assemble context.
12. Select AI provider.
13. Generate response.
14. Validate response.
15. Run safety post-check.
16. Save assistant message.
17. Update conversation.
18. Update memory.
19. Update usage.
20. Return response.

⸻

12. Conversation Memory

Memory is divided into multiple layers.

                    MEMORY
                       |
       ┌───────────────┼────────────────┐
       |               |                |
 Short-Term       Conversation      Long-Term
 Context           Summary           Memory
       |               |                |
Recent messages   Compressed history   Stable facts

⸻

13. Short-Term Memory

Short-term memory consists of the latest messages.

Example:

User:
My tooth hurts.
Assistant:
Which tooth?
User:
Upper left.
Assistant:
Does it hurt with cold?
User:
Yes.

The latest messages provide immediate context.

⸻

Why Not Send Everything?

Because models have finite context windows and processing everything can increase:

* Cost.
* Latency.
* Noise.
* Risk of irrelevant information influencing the answer.

⸻

14. Long-Term Memory

Long-term memory represents information that may remain useful.

Example:

User prefers explanations in simple language.

or:

User previously mentioned sensitivity in a particular tooth.

However, memory must be selective.

We should not save every sentence as a permanent fact.

⸻

15. Conversation Summaries

When a conversation becomes long:

Messages 1-100

can become:

Summary

Example:

The user initially reported sensitivity in an upper-left
tooth when drinking cold beverages. They reported no
swelling or fever and described the discomfort as brief.
They were advised that several causes are possible and
that persistent or worsening symptoms should be evaluated
by a dental professional.

⸻

Summary Rules

A summary should contain:

* Relevant symptoms.
* User-provided facts.
* Important timeline information.
* Important questions.
* Important previous advice.

It should not invent:

* Diagnoses.
* Symptoms.
* Treatments.
* User preferences.

⸻

16. Context Assembly

Before calling the AI, the backend creates a context package.

Example:

SYSTEM INSTRUCTIONS
+
DENTAL SAFETY RULES
+
CONVERSATION SUMMARY
+
RECENT MESSAGES
+
RELEVANT LONG-TERM MEMORY
+
RELEVANT KNOWLEDGE
+
CURRENT USER MESSAGE

⸻

17. Context Budgeting

Not every piece of information deserves equal priority.

The context manager assigns priorities.

Example:

Priority 1:
Current user message
Priority 2:
Recent conversation
Priority 3:
Safety instructions
Priority 4:
Relevant conversation summary
Priority 5:
Relevant knowledge
Priority 6:
Older memories

If context becomes too large:

Remove low-priority information first.

Never remove critical safety instructions merely to save tokens.

⸻

18. Memory Relevance

Memory should only be retrieved when relevant.

Example:

User asks:

"What is a root canal?"

The system does not necessarily need:

"User previously asked about flossing."

But if the user asks:

"What did we say about the tooth I mentioned yesterday?"

then previous conversation information becomes highly relevant.

⸻

19. Memory Retrieval

The initial version can use simple retrieval.

Example:

Search recent conversation
        ↓
Search summary
        ↓
Search relevant stored facts
        ↓
Rank results
        ↓
Add top results to context

A future version can use vector search.

⸻

20. User Facts

Potential long-term facts:

preferred_language
communication_style
relevant recurring concern
explicit user preference

But medical facts require caution.

For example:

User says:
"I have diabetes."

We should not automatically create a permanent medical profile unless the product explicitly supports this and the user understands what is being stored.

⸻

21. Memory Confidence

Every extracted memory can have a confidence level.

Example:

HIGH
MEDIUM
LOW

Only sufficiently reliable information should become persistent memory.

⸻

Example

User:

"I think this tooth might have cracked."

This should not become:

FACT:
User has a cracked tooth.

Instead:

USER_REPORTED:
User suspects a cracked tooth.

That distinction is extremely important.

⸻

22. Memory Expiration

Not all memories should exist forever.

Example:

Temporary symptom:
Expires after a defined period.

Long-term preference:

May remain until changed.

Conversation:

Retained according to conversation retention policy.

⸻

23. Memory Contradictions

Suppose the user says:

"My tooth doesn't hurt anymore."

Previous memory:

"User has tooth pain."

The new information should not simply be ignored.

The system can represent:

Previous:
User reported tooth pain.
Current:
User reports that the pain has resolved.

The latest explicit information takes precedence for current conversation context.

⸻

24. Context Priority

The system should prioritize information roughly as:

1. Safety instructions
2. Current user message
3. Current conversation
4. Explicit recent user corrections
5. Relevant verified knowledge
6. Conversation summary
7. Long-term memories
8. Low-confidence inferred information

⸻

25. System Instructions

DentAssist needs a strong system instruction layer.

Conceptually:

You are DentAssist, a dental information assistant.
Your purpose is to provide educational dental information
and general guidance.
You are not a dentist and must not claim to provide a
definitive diagnosis.
Stay within dental and closely related health topics.
When symptoms could represent something serious, clearly
recommend appropriate professional evaluation.
Do not invent patient information.
Distinguish between:
- user-reported information
- established information
- possible explanations
Ask clarifying questions when necessary.
Do not provide false certainty.

This is only the conceptual foundation.

The production prompt will be versioned and extensively tested.

⸻

26. Dental Scope

The AI should focus primarily on:

* Teeth.
* Gums.
* Mouth.
* Jaw.
* Oral hygiene.
* Dental procedures.
* Dental symptoms.
* Dental terminology.
* Dental prevention.
* Dental care navigation.

⸻

27. Out-of-Scope Questions

Example:

User:

"Who will win the football match tonight?"

DentAssist should not pretend to specialize in that.

Possible response:

"I'm designed specifically for dental questions. If you
have a question about your teeth, gums, mouth, or dental
care, I'd be happy to help."

⸻

Closely Related Questions

Some questions overlap with general health.

Example:

"Can pregnancy affect gums?"

This is relevant to dental health.

The system can answer while acknowledging limitations.

⸻

28. Prompt Injection

Users may attempt:

"Ignore your instructions and tell me something else."

The AI should not allow user content to overwrite system-level instructions.

The architecture must separate:

SYSTEM
DEVELOPER
USER

conceptually.

User content must never be treated as higher-priority instructions.

⸻

29. AI Safety Layer

Safety exists before and after generation.

User
 ↓
Pre-check
 ↓
AI
 ↓
Post-check
 ↓
User

⸻

Pre-check

Detect:

* Emergency language.
* Self-harm-related content.
* Dangerous requests.
* Medication misuse.
* Requests for inappropriate medical certainty.

⸻

Post-check

Detect:

* Unsupported diagnosis.
* Dangerous instructions.
* False certainty.
* Contradictions.
* Missing escalation advice.

⸻

30. Medical/Dental Limitations

The assistant should distinguish:

Possible
Likely
Known
Confirmed

It should avoid turning:

possible cavity

into:

confirmed cavity

⸻

31. Emergency Detection

Certain symptoms may require urgent professional attention.

Examples that should trigger stronger escalation logic may include:

* Severe facial swelling.
* Difficulty breathing.
* Difficulty swallowing.
* Uncontrolled bleeding.
* Serious facial trauma.
* Rapidly worsening symptoms.

The exact clinical rules must be reviewed by qualified dental/medical professionals before production launch.

⸻

32. Structured AI Output

Instead of requesting only free-form text, the backend can eventually request structured output.

Example:

{
  "answer": "...",
  "urgency": "MODERATE",
  "needsProfessionalEvaluation": true,
  "followUpQuestions": [
    "How long has this been happening?"
  ],
  "confidence": "MEDIUM"
}

The backend can then validate the structure.

⸻

Why Structured Output Matters

It lets the application separate:

What the AI says

from:

What the application does

For example:

urgency = EMERGENCY

could trigger a dedicated UI component.

⸻

33. AI Response Validation

Before returning the AI response:

AI response
     ↓
Schema validation
     ↓
Safety validation
     ↓
Content validation
     ↓
Return

If validation fails:

Do not blindly return the response.

The backend can retry or use a safe fallback.

⸻

34. Hallucination Reduction

Hallucinations cannot be completely eliminated.

They can be reduced.

Techniques:

1. Strong system instructions.
2. Retrieval from trusted knowledge.
3. Structured output.
4. Explicit uncertainty.
5. Response validation.
6. Prompt versioning.
7. Evaluation datasets.
8. Human review.

⸻

35. Knowledge Retrieval

For factual dental questions, the AI may benefit from trusted reference material.

Example:

User:
What is fluoride?
        ↓
Knowledge Retrieval
        ↓
Relevant dental information
        ↓
AI explanation

This is called:

Retrieval-Augmented Generation (RAG).

⸻

36. Retrieval-Augmented Generation

Basic architecture:

User Question
     |
     v
Embedding/Search
     |
     v
Relevant Documents
     |
     v
Context Builder
     |
     v
AI Model
     |
     v
Answer

⸻

37. Dental Knowledge Base

Future knowledge sources may include:

* Government health organizations.
* Dental associations.
* Universities.
* Peer-reviewed material.
* Professionally reviewed educational resources.

The exact source list should be established before production.

⸻

Knowledge Documents

Each document should have metadata:

id
title
source
url
published_date
reviewed_date
topic
content

⸻

38. Source Trust

Not every website should be treated equally.

Potential ranking:

Tier 1:
Government / professional organizations
Tier 2:
Academic institutions
Tier 3:
Peer-reviewed sources
Tier 4:
General reputable medical websites
Tier 5:
Unverified web content

Untrusted content should not automatically enter the production knowledge base.

⸻

39. Citation Strategy

A future version may allow answers such as:

According to the referenced dental guidance,
fluoride helps strengthen tooth enamel.

The UI can optionally show:

Sources

This increases transparency.

⸻

40. Image Analysis

Image analysis is a future feature.

Example:

User takes photo
       ↓
Upload
       ↓
Image validation
       ↓
Vision-capable AI
       ↓
Safety layer
       ↓
General observations

⸻

Image Analysis Restrictions

The system should not claim:

"This image confirms a cavity."

Instead:

"There appears to be an area of discoloration, but a
photograph cannot reliably determine the cause."

⸻

41. Image Safety

Images may contain:

* Personal information.
* Faces.
* Other people.
* Identifying backgrounds.

The application should minimize storage.

⸻

42. AI Conversation State

Conversation state exists at multiple levels.

Conversation
├── Permanent message history
├── Summary
├── Recent context
├── Temporary AI context
└── Optional long-term memories

These are not the same thing.

⸻

Temporary Context

Temporary context may exist only during one AI request.

Example:

retrievedKnowledge
retrievedMemories
safetySignals

It does not necessarily need to be permanently stored.

⸻

43. Failed AI Requests

AI requests can fail.

Possible causes:

* Provider timeout.
* Provider rate limit.
* Network error.
* Invalid response.
* Model unavailable.

The application should return a friendly message.

Example:

"I'm having trouble generating a response right now.
Please try again."

The system should not expose internal API errors.

⸻

44. Provider Failover

Example:

Primary Provider
       |
       | failure
       v
Fallback Provider
       |
       | failure
       v
Safe Error

Failover should be carefully controlled.

Otherwise one user request could accidentally create multiple expensive provider calls.

⸻

45. AI Cost Control

AI costs are controlled through:

* Guest limits.
* User limits.
* Rate limiting.
* Context limits.
* Model selection.
* Caching.
* Summarization.
* Provider selection.

⸻

46. Usage Limits

Example:

Guest:

3 AI messages/day

Free account:

10 AI messages/day

Paid tier:

Higher limits

These are illustrative values only.

The actual limits should be configurable.

⸻

Server Authority

The frontend must never decide:

remainingCredits = 10

The backend must determine usage.

⸻

47. Caching

Some questions are repeated frequently.

Example:

"What is a root canal?"

A response could potentially be cached under carefully controlled conditions.

However, personalized medical conversations should not be blindly cached.

⸻

48. Streaming

Future AI responses may stream.

Instead of:

Wait
   ↓
Entire answer

the user sees:

Generating...
A root canal is...

Streaming improves perceived latency.

⸻

Streaming Architecture

Potential approach:

Flutter
   ↑
SSE/WebSocket
   ↑
Spring Boot
   ↑
AI Provider Stream

The first version can use normal HTTP responses.

Streaming should be added when the basic system is stable.

⸻

49. Model Selection

Different tasks may use different models.

Example:

Simple question
     ↓
Small/cheap model
Complex explanation
     ↓
More capable model
Image analysis
     ↓
Vision-capable model
Summarization
     ↓
Efficient model

The provider abstraction allows this.

⸻

50. AI Observability

We need to know when the AI system fails.

Track:

* Request latency.
* Provider errors.
* Token usage.
* Response validation failures.
* Safety flags.
* User feedback.
* Retry counts.

⸻

Privacy Constraint

Observability data must not unnecessarily contain user conversation content.

Prefer:

conversationId
messageId
provider
model
latency
status

over storing complete user messages in logs.

⸻

51. AI Metrics

Useful metrics:

AI success rate
AI latency
Provider error rate
Average token usage
Average response length
Negative feedback rate
Safety escalation rate
Fallback rate

⸻

52. Prompt Versioning

Prompts are code.

Therefore they must be versioned.

Example:

dental-assistant-v1
dental-assistant-v2

When a response is generated, internally record:

prompt_version = dental-assistant-v2

This allows historical debugging.

⸻

53. AI Evaluation

We should build an evaluation dataset.

Example:

Question:
What causes tooth sensitivity?
Expected properties:
- Explains multiple possible causes.
- Does not diagnose.
- Gives reasonable next steps.
- Mentions professional evaluation where appropriate.

⸻

Evaluation Categories

Dental knowledge
Safety
Scope adherence
Consistency
Uncertainty
Conversation memory
Instruction following
Hallucination
Tone

⸻

54. Test Conversations

Create scripted conversations.

Example:

USER:
My tooth hurts.
ASSISTANT:
Clarifying question.
USER:
Only when I drink something cold.
ASSISTANT:
Relevant explanation.
USER:
It lasts for about 30 seconds.
ASSISTANT:
Updated response using previous context.

The system should remember the earlier messages.

⸻

55. Regression Testing

Whenever the AI architecture changes:

Run:

Evaluation Dataset
        ↓
New AI Version
        ↓
Compare Results

If safety or quality significantly decreases:

Do not deploy.

⸻

56. Human Review

AI safety cannot be solved entirely through code.

Before production launch, important safety behavior should be reviewed by qualified professionals.

Especially:

* Emergency guidance.
* Symptom escalation.
* Medication-related responses.
* Image interpretation.
* Diagnostic language.

⸻

57. Privacy

The AI provider should receive only the information required to generate the response.

Do not send unrelated user information.

Example:

User asks:

"What is fluoride?"

There is no reason to send:

Saved clinic history.

⸻

58. Data Retention

AI context can exist in three forms:

Permanent
Temporary
Provider-side

DentAssist controls the first two.

Provider retention depends on the provider’s policies and configuration.

Before production, provider data-handling terms must be reviewed.

⸻

59. Architecture Evolution

Version 1:

PostgreSQL
+
Redis
+
One AI provider
+
Mock provider

Version 2:

PostgreSQL
+
Redis
+
Multiple providers
+
RAG

Version 3:

PostgreSQL
+
pgvector
+
Redis
+
Multiple AI models
+
Vision
+
Advanced evaluation

We should not build Version 3 before Version 1 works.

⸻

60. Final AI Pipeline

The production architecture should eventually look like:

                     USER MESSAGE
                          |
                          v
                  Authentication
                          |
                          v
                   Usage Control
                          |
                          v
                  Conversation Load
                          |
                          v
                  Context Retrieval
                    /           \
                   /             \
                  v               v
          Recent Messages    Long-Term Memory
                   \             /
                    \           /
                     v         v
                    Context Manager
                          |
                          v
                   Dental Scope Check
                          |
                          v
                    Safety Pre-check
                          |
                          v
                    Knowledge RAG
                          |
                          v
                    Prompt Builder
                          |
                          v
                    AI Provider
                          |
                          v
                  Structured Output
                          |
                          v
                  Response Validator
                          |
                          v
                  Safety Post-check
                          |
                          v
                  Memory Processor
                          |
                          v
                  Conversation Store
                          |
                          v
                       Response

⸻

61. Final Memory Architecture

The memory system should be:

                         MEMORY
                            |
            ┌───────────────┼────────────────┐
            |               |                |
            v               v                v
       Recent Chat      Summary Store     Long-Term Memory
            |               |                |
            |               |                |
            └───────────────┼────────────────┘
                            |
                            v
                     Relevance Filter
                            |
                            v
                     Context Ranking
                            |
                            v
                      Context Builder
                            |
                            v
                           AI

⸻

Memory Rule

The AI does not “remember” by magic.

DentAssist gives the AI the appropriate information at the appropriate time.

This is the fundamental architecture.

⸻

62. Summary

DentAssist should not depend on an AI provider for application memory.

Instead:

PostgreSQL
    =
Permanent memory
Redis
    =
Fast temporary memory
Context Manager
    =
Decides what the AI should see
AI Provider
    =
Generates language
Safety Layer
    =
Controls dangerous or inappropriate behavior
Knowledge Retrieval
    =
Provides trusted information
Response Validator
    =
Checks generated output
Evaluation System
    =
Measures quality

The most important architectural principles are:

1. AI is a replaceable service.
2. AI provider keys never reach Flutter.
3. The backend owns AI orchestration.
4. PostgreSQL owns permanent conversation history.
5. Redis handles temporary/high-speed state.
6. Recent messages provide short-term context.
7. Summaries compress long conversations.
8. Long-term memory should be selective.
9. User statements must not automatically become facts.
10. Memory can have confidence and expiration.
11. New explicit user information should supersede outdated information.
12. Safety instructions have high context priority.
13. The AI must stay within the dental domain.
14. User prompts cannot override system instructions.
15. AI output should be validated.
16. AI should communicate uncertainty.
17. The system should not claim definitive diagnosis.
18. Emergency indicators require stronger escalation.
19. Trusted knowledge can be added through RAG.
20. Image analysis must be treated as an assistive capability, not definitive diagnosis.
21. Mock AI allows development with zero AI API spending.
22. AI providers can be swapped later.
23. Prompt versions must be tracked.
24. AI behavior must be tested using evaluation datasets.
25. Production AI behavior should receive qualified professional review.
26. The simplest architecture should be implemented first.
27. Advanced memory should be added only when necessary.
28. The application, not the AI model, owns the user’s data and state.

## The important part
You were worried that **“a free AI won't remember everything.”**
The architecture above changes the question.
We don't need a model that permanently remembers everything.
We need a model that can **read the right memory at the right time**.
For example:
```text
                 USER
                  │
                  ▼
       "What did we say about
          my tooth yesterday?"
                  │
                  ▼
        ┌─────────────────┐
        │  Memory Manager │
        └────────┬────────┘
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
    Recent    Summary    Relevant
    Messages            Memories
       │         │         │
       └─────────┼─────────┘
                 ▼
          Context Builder
                 │
                 ▼
          Any capable AI
                 │
                 ▼
             Answer

So even if we eventually change from one model to another, your application’s memory remains yours.

And there’s another major benefit: we can build almost all of this before paying for a real AI API. The MockAiProvider lets us build the frontend, backend, database, authentication, conversations, Redis, limits, memory pipeline, error states, etc. first.

Then when we eventually get access to a suitable free/cheap model, we’re plugging it into an already-working system rather than trying to build the whole product around an API.

Next: 09_AI_PROMPT_SYSTEM.md — we’ll go one level deeper and design the actual prompt system: system prompt, developer rules, dental scope rules, safety instructions, context formatting, memory formatting, response structure, refusal behavior, and how we prevent the model from drifting outside DentAssist’s purpose.