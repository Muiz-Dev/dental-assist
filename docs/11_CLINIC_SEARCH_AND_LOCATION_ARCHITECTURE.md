Absolutely. This is the part that turns DentAssist from “just another dental chatbot” into a useful product: the user can ask a dental question and immediately find a nearby place to get help.

11_CLINIC_SEARCH_AND_LOCATION_ARCHITECTURE.md

# 11_CLINIC_SEARCH_AND_LOCATION_ARCHITECTURE.md
# DentAssist Clinic Search & Location Architecture
Version: 1.0
Status: Draft
---
# Table of Contents
1. Introduction
2. The Clinic Discovery Problem
3. Product Goal
4. What the User Should Be Able to Do
5. Location Architecture
6. GPS and Device Location
7. Permission Flow
8. Location Privacy
9. Coordinates
10. Search Radius
11. Distance Calculation
12. Clinic Provider Abstraction
13. Why Provider Abstraction Matters
14. Clinic Data Model
15. Clinic Normalization
16. Open Map Data
17. Commercial Places APIs
18. Provider Selection Strategy
19. Zero-Budget Development Strategy
20. Mock Clinic Provider
21. Local Clinic Dataset
22. Clinic Search API
23. Search Request
24. Search Response
25. Search Pipeline
26. Geospatial Search
27. PostgreSQL Geospatial Strategy
28. Redis Caching
29. Cache Strategy
30. Cache Expiration
31. Search Ranking
32. Distance Ranking
33. Clinic Quality Ranking
34. Open Now
35. Opening Hours
36. Phone Numbers
37. Websites
38. Booking Links
39. Appointment Availability
40. Booking Architecture
41. Clinic Verification
42. Stale Data
43. Duplicate Clinics
44. Closed Clinics
45. Missing Information
46. User Location Failure
47. Permission Denied
48. GPS Inaccuracy
49. Network Failure
50. Provider Failure
51. Search Failure
52. No Clinics Found
53. Emergency Search
54. Emergency Disclaimer
55. Dental Specialty Filtering
56. Search Filters
57. Map View
58. List View
59. Clinic Details
60. Saved Clinics
61. Recent Clinics
62. User Privacy
63. Abuse Prevention
64. API Security
65. Provider Cost Control
66. Future Geocoding
67. Future Directions
68. Future Booking
69. Future Reviews
70. Future Clinic Accounts
71. Clinic Search Database
72. Database Tables
73. Clinic Lifecycle
74. Provider Synchronization
75. Synchronization Frequency
76. Data Provenance
77. Data Confidence
78. Source Attribution
79. Frontend Architecture
80. Backend Architecture
81. Complete Request Flow
82. Example User Journey
83. Example API Requests
84. Example API Responses
85. Error Responses
86. Testing Strategy
87. Location Testing
88. Provider Testing
89. Ranking Testing
90. Security Testing
91. Performance Testing
92. Zero-Budget MVP
93. Production Version
94. Future Architecture
95. Recommended Build Order
96. Summary
---
# 1. Introduction
DentAssist has two major product capabilities:
1. Dental information.
2. Dental care discovery.
The first capability answers:
    "What might this mean?"
The second answers:
    "Where can I get help?"
The clinic discovery feature therefore connects digital information with real-world healthcare access.
---
# 2. The Clinic Discovery Problem
A user might ask:
    "My tooth is hurting badly. What should I do?"
DentAssist may explain the situation.
But the user may immediately ask:
    "Find a dentist near me."
The application should be able to transition from:
```text
AI conversation

to:

Clinic discovery

without forcing the user to leave the application.

⸻

3. Product Goal

The clinic feature should allow a user to:

* Share their location.
* Search for nearby dental clinics.
* See clinics sorted by distance.
* View clinic information.
* See available contact methods.
* See opening hours when available.
* Open a clinic’s website.
* Open a booking page when available.
* Call a clinic when supported.
* Save a clinic.
* Eventually book an appointment.

⸻

4. What the User Should Be Able to Do

Primary flow:

Find a dentist
      ↓
Allow location
      ↓
Get coordinates
      ↓
Search nearby clinics
      ↓
Display results
      ↓
Select clinic
      ↓
View details
      ↓
Call / Website / Booking

⸻

5. Location Architecture

Location is primarily obtained from the user’s device.

The frontend should request location permission.

The frontend then obtains:

latitude
longitude
accuracy

The backend receives the minimum required information.

⸻

6. GPS and Device Location

Flutter can request the device’s location.

Conceptually:

Phone GPS
   ↓
Flutter location service
   ↓
Latitude / longitude
   ↓
Backend API

The backend should not assume the coordinates are perfectly accurate.

⸻

7. Permission Flow

The application should explain why location is needed.

Example:

Find dentists near you
We use your location to show nearby dental clinics.
[Allow Location]
[Not Now]

Do not request location immediately on application launch unless necessary.

Request it when the user attempts to use location-based functionality.

⸻

8. Location Privacy

Location is sensitive.

The application should:

* Request permission only when needed.
* Avoid storing precise location unnecessarily.
* Avoid logging precise coordinates.
* Avoid sending location to unrelated services.
* Explain how location is used.

⸻

9. Coordinates

Example:

{
  "latitude": 6.5244,
  "longitude": 3.3792
}

These are coordinates only.

The backend can convert them into a search.

⸻

10. Search Radius

The application should support configurable search radius.

Example:

1 km
5 km
10 km
25 km
50 km

Default:

5 km

The exact default can be changed after user testing.

⸻

11. Distance Calculation

The backend should calculate approximate distance between:

User coordinates

and:

Clinic coordinates

Distance can be calculated using geographic formulas or database geospatial functionality.

The frontend can display:

1.2 km away

rather than exposing raw coordinates.

⸻

12. Clinic Provider Abstraction

The backend should define:

public interface ClinicProvider {
    ClinicSearchResult searchNearby(
        double latitude,
        double longitude,
        double radiusKm
    );
}

Possible implementations:

MockClinicProvider
LocalClinicProvider
OpenMapClinicProvider
CommercialPlacesProvider

⸻

13. Why Provider Abstraction Matters

Suppose we initially use an open-data provider.

Later we discover:

* Incomplete clinic information.
* Poor coverage.
* Rate limits.
* Incorrect opening hours.

We should be able to switch providers.

Without abstraction:

Provider logic everywhere

With abstraction:

ClinicService
     ↓
ClinicProvider
     ↓
Provider implementation

Only the implementation changes.

⸻

14. Clinic Data Model

A normalized clinic object could contain:

Clinic
- id
- name
- latitude
- longitude
- address
- city
- country
- phone
- website
- bookingUrl
- openingHours
- specialties
- source
- sourceId
- verificationStatus
- lastUpdated

⸻

15. Clinic Normalization

Different providers may return different fields.

Provider A:

name
address
phone
lat
lng

Provider B:

display_name
formatted_address
telephone
latitude
longitude

DentAssist converts both into:

Clinic

This protects the rest of the application from provider-specific formats.

⸻

16. Open Map Data

Open geographic datasets can potentially provide useful information without commercial API costs.

One example is OpenStreetMap.

The important distinction is:

Open geographic data

does not automatically mean:

Unlimited free API usage.

Public services can have usage policies, limits, and attribution requirements.

The production architecture must respect the selected provider’s terms.

⸻

17. Commercial Places APIs

Commercial providers may offer:

* Better place coverage.
* Business metadata.
* Opening hours.
* Phone numbers.
* Website information.
* Place IDs.
* Search ranking.

But they can introduce:

* API costs.
* Usage limits.
* Billing requirements.
* Provider lock-in.

⸻

18. Provider Selection Strategy

Do not decide:

"We must use provider X forever."

Instead evaluate providers using:

Coverage
Accuracy
Price
Terms
Rate limits
Opening hours
Phone data
Website data
Booking data
Geographic availability

⸻

19. Zero-Budget Development Strategy

During development:

MockClinicProvider

should be sufficient.

Example local dataset:

10 fictional clinics

with realistic coordinates around the developer’s test location.

⸻

20. Mock Clinic Provider

Example:

MockClinicProvider

returns:

[
  {
    "id": "clinic-001",
    "name": "Example Dental Clinic",
    "distanceKm": 1.1
  },
  {
    "id": "clinic-002",
    "name": "Example Smile Centre",
    "distanceKm": 2.7
  }
]

This allows the entire UI to be developed before connecting to a real provider.

⸻

21. Local Clinic Dataset

A development database can contain:

clinic

records.

For example:

Clinic A
Latitude: test coordinate
Longitude: test coordinate
Specialty: General Dentistry

The data should be clearly marked as development/test data.

Never present fake clinics as real clinics in production.

⸻

22. Clinic Search API

Initial endpoint:

GET /api/v1/clinics/nearby

Parameters:

latitude
longitude
radiusKm

Optional:

specialty
openNow

⸻

23. Search Request

Example:

GET /api/v1/clinics/nearby
    ?latitude=6.5244
    &longitude=3.3792
    &radiusKm=5

⸻

24. Search Response

Example:

{
  "results": [
    {
      "id": "clinic-123",
      "name": "Example Dental Clinic",
      "distanceKm": 1.2,
      "address": "Example Address",
      "phone": "+234...",
      "website": "...",
      "bookingUrl": null,
      "isOpen": true
    }
  ],
  "searchRadiusKm": 5
}

⸻

25. Search Pipeline

Flutter
   ↓
Location
   ↓
GET /clinics/nearby
   ↓
ClinicService
   ↓
Cache lookup
   ↓
Local database/provider
   ↓
Normalize results
   ↓
Calculate distance
   ↓
Rank
   ↓
Return

⸻

26. Geospatial Search

The system should avoid retrieving every clinic in the entire database.

Instead:

User coordinate
       ↓
Geospatial query
       ↓
Nearby candidates

Then:

Candidates
    ↓
Filters
    ↓
Ranking

⸻

27. PostgreSQL Geospatial Strategy

For a more advanced implementation, PostgreSQL can use geospatial capabilities such as PostGIS.

Conceptually:

clinic.location

becomes a geographic point.

Then the database can efficiently query:

clinics within X meters

This is preferable to calculating every clinic distance in application code once the database becomes large.

⸻

28. Redis Caching

Clinic searches can be cached.

Example:

Cache key:
clinics:nearby:{geohash}:{radius}:{filters}

A location should be rounded or geohashed rather than creating a unique cache key for every tiny GPS movement.

⸻

29. Cache Strategy

Example:

User location:
6.52441, 3.37920
Nearby user:
6.52445, 3.37925

These searches are effectively similar.

They can share a cache bucket.

⸻

30. Cache Expiration

Clinic data can become stale.

Therefore caches should expire.

Example:

TTL = configurable

The exact TTL should depend on the provider and data type.

Opening hours may need fresher data than static addresses.

⸻

31. Search Ranking

The application should not blindly return results in provider order.

Ranking can consider:

Distance
+
Clinic type
+
Open status
+
Data completeness
+
Verification

⸻

32. Distance Ranking

For a simple MVP:

Closest clinics first

Example:

0.8 km
1.3 km
2.1 km
4.7 km

⸻

33. Clinic Quality Ranking

Later:

Score =
distance
+
availability
+
data quality
+
user preference

Do not make an opaque score too early.

Users should understand why a clinic appears near the top.

⸻

34. Open Now

If reliable opening-hours data exists:

Display:

Open now

or:

Closed

If the data is missing:

Hours unavailable

Never guess.

⸻

35. Opening Hours

Opening hours should be modeled separately.

Example:

Monday:
08:00 - 17:00
Tuesday:
08:00 - 17:00

Special holiday hours may require provider-specific support.

⸻

36. Phone Numbers

If a verified phone number is available:

The app can expose:

Call clinic

The application should not invent phone numbers.

⸻

37. Websites

If a verified website exists:

Visit website

The URL should be treated as external data and safely validated.

⸻

38. Booking Links

A clinic may provide:

bookingUrl

The application can expose:

Book appointment

But the button must not imply DentAssist controls the appointment unless it actually does.

⸻

39. Appointment Availability

There are two very different concepts:

Booking link

and:

Live availability

A booking link means:

"This clinic has an external booking page."

Live availability means:

"The system knows that 3:30 PM is currently available."

Do not confuse them.

⸻

40. Booking Architecture

Future architecture:

DentAssist
     ↓
BookingProvider
     ↓
Clinic booking system

Interface:

public interface BookingProvider {
    List<AppointmentSlot> getAvailableSlots(
        String clinicId,
        LocalDate date
    );
    BookingResult book(
        String clinicId,
        AppointmentRequest request
    );
}

⸻

41. Clinic Verification

A clinic record should have a status.

Example:

UNVERIFIED
PROVIDER_VERIFIED
USER_REPORTED
MANUALLY_VERIFIED

⸻

42. Stale Data

A clinic may:

* Move.
* Close.
* Change phone number.
* Change website.
* Change opening hours.

Therefore:

lastUpdated

should be stored.

⸻

43. Duplicate Clinics

Different providers may return the same clinic.

Example:

Provider A:
Smile Dental Clinic
Provider B:
Smile Dental & Oral Care

The system may need deduplication.

Possible signals:

Same coordinates
+
Similar name
+
Similar address
+
Same phone

⸻

44. Closed Clinics

If a provider indicates that a clinic is permanently closed:

The system should not continue presenting it as an active clinic.

Potential lifecycle:

ACTIVE
TEMPORARILY_CLOSED
PERMANENTLY_CLOSED
UNKNOWN

⸻

45. Missing Information

A clinic may have:

No phone
No website
No hours

That does not necessarily mean it should be removed.

Display:

Phone unavailable
Hours unavailable

rather than inventing information.

⸻

46. User Location Failure

Possible failures:

GPS unavailable
Permission denied
Location timeout
Low accuracy

The application should gracefully handle each.

⸻

47. Permission Denied

If the user denies location:

Show:

Location access is required to automatically find nearby
clinics.
You can also search by entering a location manually.

This is important.

The application should not make location permission the only possible search method.

⸻

48. GPS Inaccuracy

Suppose the device reports:

accuracy = 800 meters

The application should not pretend the user is at an exact point.

Potential UI:

Location accuracy is low.
Try moving outdoors or search by area instead.

⸻

49. Network Failure

If the backend cannot be reached:

We couldn't load nearby clinics.
Check your connection and try again.

Previously loaded clinics can potentially remain visible if cached locally.

⸻

50. Provider Failure

If the clinic provider fails:

ClinicService
      ↓
Provider failure
      ↓
Cached result?
   /       \
 Yes       No
 ↓          ↓
Return    Friendly error
cache

⸻

51. Search Failure

Do not expose internal errors such as:

NullPointerException
Provider HTTP 503
SQLSTATE...

The user sees:

We couldn't load clinics right now.
Please try again.

The technical error goes to logs.

⸻

52. No Clinics Found

Do not say:

"There are no dentists near you."

That may be inaccurate.

Say:

We couldn't find dental clinics within 5 km of this location.
Try expanding the search radius.

⸻

53. Emergency Search

If the AI determines that the conversation may involve an urgent dental issue, the UI could offer:

Find urgent dental care

The clinic search can prioritize:

Open now

when reliable hours are available.

⸻

54. Emergency Disclaimer

The application must not imply:

This is definitely the nearest emergency facility.

Instead:

These are nearby dental-care options based on the available
location and clinic information.

For life-threatening emergencies, the product should direct users toward appropriate emergency services rather than treating a dental clinic directory as a substitute.

⸻

55. Dental Specialty Filtering

Future filters:

General Dentistry
Orthodontics
Pediatric Dentistry
Oral Surgery
Periodontics
Endodontics
Prosthodontics

The application should only display a specialty when the underlying data supports it.

⸻

56. Search Filters

Potential filters:

Distance
Open now
Specialty
Accepts appointments
Has phone
Has website

MVP should remain simple.

Recommended initial filters:

Radius
Open now

⸻

57. Map View

Eventually:

Map
 ├── User location
 ├── Clinic marker
 ├── Clinic marker
 └── Clinic marker

Selecting a marker opens a clinic preview.

⸻

58. List View

List view:

Example Dental Clinic
1.2 km
Open now
Phone available
Example Smile Centre
2.3 km
Closed
Booking available

⸻

59. Clinic Details

A clinic details page may contain:

Name
Address
Distance
Opening hours
Phone
Website
Booking
Specialties
Source / verification information

⸻

60. Saved Clinics

Authenticated users can save clinics.

Database relationship:

User
 |
 └── SavedClinic
        |
        └── Clinic

The user can later access:

My saved clinics

⸻

61. Recent Clinics

The application can maintain:

Recently viewed clinics

This does not necessarily require permanent storage.

Redis or local device storage can handle some recent-history functionality depending on requirements.

⸻

62. User Privacy

The application should not permanently store:

Every GPS location ever sent.

unless there is a clearly justified product feature requiring it.

For simple nearby search:

Current location

is sufficient.

⸻

63. Abuse Prevention

Clinic APIs may have usage limits.

Attack:

Bot
 ↓
10,000 nearby searches
 ↓
Provider API bill

Controls:

Rate limiting
+
Authentication limits
+
Caching
+
Provider quotas

⸻

64. API Security

Validate:

latitude
longitude
radius
filters

Reject:

latitude=999999
radius=999999999

⸻

65. Provider Cost Control

Never let the frontend directly call a paid clinic provider.

Bad:

Flutter
   ↓
Places API

Better:

Flutter
   ↓
DentAssist Backend
   ↓
Cache
   ↓
Clinic Provider

This allows:

* Rate limiting.
* Caching.
* Provider switching.
* Usage monitoring.

⸻

66. Future Geocoding

Users may search:

Dental clinics in Ikeja

rather than sharing GPS.

This requires:

Text location
   ↓
Geocoding
   ↓
Coordinates
   ↓
Clinic search

Geocoding should also be abstracted:

public interface GeocodingProvider {
    Coordinates geocode(String query);
}

⸻

67. Future Directions

A future version could provide:

Get directions

This should preferably open the user’s chosen navigation application or use an integrated directions provider.

⸻

68. Future Booking

Eventually:

Clinic
 ↓
Available slots
 ↓
User selects time
 ↓
Booking provider
 ↓
Confirmation

Booking should be its own subsystem.

Do not mix booking logic into clinic search.

⸻

69. Future Reviews

User reviews could eventually be supported.

However, reviews create:

* Moderation requirements.
* Abuse risks.
* Defamation concerns.
* Spam.
* Fake review problems.

Therefore reviews should not be an MVP requirement.

⸻

70. Future Clinic Accounts

Eventually clinics could claim profiles.

Example:

Clinic
   ↓
Claim profile
   ↓
Verification
   ↓
Clinic dashboard

The clinic could manage:

* Opening hours.
* Phone.
* Website.
* Booking.
* Services.

This can become a future business model.

⸻

71. Clinic Search Database

Potential tables:

clinics
clinic_hours
clinic_specialties
clinic_sources
clinic_verifications
saved_clinics

⸻

72. Database Tables

clinics

id
name
latitude
longitude
address
city
country
phone
website
booking_url
verification_status
last_updated
created_at
updated_at

⸻

clinic_hours

id
clinic_id
day_of_week
open_time
close_time

⸻

clinic_sources

id
clinic_id
provider
external_id
last_synced_at

⸻

73. Clinic Lifecycle

DISCOVERED
    ↓
NORMALIZED
    ↓
VALIDATED
    ↓
ACTIVE
    ↓
UPDATED

Potential alternative:

ACTIVE
   ↓
STALE
   ↓
RECHECK
   ↓
ACTIVE

or:

ACTIVE
   ↓
CLOSED

⸻

74. Provider Synchronization

If DentAssist maintains its own clinic database:

Provider
   ↓
Sync job
   ↓
Normalize
   ↓
Deduplicate
   ↓
Validate
   ↓
PostgreSQL

⸻

75. Synchronization Frequency

Do not continuously refresh everything.

Different data can have different refresh periods.

Example:

Clinic address:
longer refresh period
Opening hours:
shorter refresh period
Booking availability:
real-time

The exact schedule depends on the source.

⸻

76. Data Provenance

Every clinic record should ideally know:

Where did this information come from?

Example:

source:
provider_a
source_id:
abc123

This helps with debugging and trust.

⸻

77. Data Confidence

A future internal field:

dataConfidence

could be:

HIGH
MEDIUM
LOW

This should generally be an internal ranking signal rather than a confusing user-facing number.

⸻

78. Source Attribution

If a provider requires attribution, DentAssist must display it according to that provider’s terms.

This is especially important for open geographic datasets.

⸻

79. Frontend Architecture

Flutter:

ClinicSearchScreen
        |
        v
LocationController
        |
        v
ClinicRepository
        |
        v
HTTP Client
        |
        v
Spring Boot

⸻

80. Backend Architecture

Spring Boot:

ClinicController
       |
       v
ClinicService
       |
       ├── Cache
       |
       ├── Database
       |
       └── ClinicProvider

⸻

81. Complete Request Flow

USER
 |
 | Tap "Find Dentist"
 v
Flutter
 |
 | Request location permission
 v
Device
 |
 | latitude/longitude
 v
Flutter
 |
 | GET /clinics/nearby
 v
Spring Boot
 |
 | Validate request
 v
ClinicService
 |
 | Check Redis
 v
Redis
 |
 +---- Cache hit ----> Return results
 |
 |
 Cache miss
 |
 v
ClinicProvider
 |
 v
Provider
 |
 v
Normalize
 |
 v
Rank
 |
 v
Cache
 |
 v
Response
 |
 v
Flutter
 |
 v
Clinic List

⸻

82. Example User Journey

User:

"Find a dentist near me."

Application:

Allow location?

User:

Yes.

Application:

Searching nearby dental clinics...

Results:

Dental Clinic A
1.1 km
Open now
Call
Website
Dental Clinic B
2.4 km
Closed
Website

User selects Clinic A.

Details:

Dental Clinic A
1.1 km away
Open now
Address:
...
Phone:
...
[Call]
[Website]
[Get Directions]

⸻

83. Example API Requests

GET /api/v1/clinics/nearby?latitude=6.5244&longitude=3.3792&radiusKm=5

⸻

84. Example API Responses

{
  "results": [
    {
      "id": "cln_001",
      "name": "Dental Clinic A",
      "distanceKm": 1.1,
      "isOpen": true,
      "address": "Example Address",
      "phone": "+234...",
      "website": "https://example.com"
    }
  ],
  "metadata": {
    "radiusKm": 5,
    "resultCount": 1
  }
}

⸻

85. Error Responses

Invalid coordinates:

{
  "error": {
    "code": "INVALID_LOCATION",
    "message": "The supplied location is invalid."
  }
}

Provider unavailable:

{
  "error": {
    "code": "CLINIC_SEARCH_UNAVAILABLE",
    "message": "Clinic search is temporarily unavailable."
  }
}

⸻

86. Testing Strategy

Test:

Valid coordinates
Invalid coordinates
Small radius
Large radius
No results
Provider failure
Cache hit
Cache miss
Permission denied
GPS unavailable
Duplicate clinics
Missing phone
Missing hours
Closed clinic

⸻

87. Location Testing

Test locations across:

Urban
Suburban
Rural
Dense clinic areas
Sparse clinic areas

The product should not assume that clinic density is the same everywhere.

⸻

88. Provider Testing

Create contract tests.

Example:

Every ClinicProvider implementation must:
return normalized clinics
handle provider errors
respect radius
not return malformed coordinates

⸻

89. Ranking Testing

Given:

Clinic A = 1 km
Clinic B = 3 km
Clinic C = 5 km

Expected:

A
B
C

when distance is the only ranking factor.

⸻

90. Security Testing

Test:

Invalid coordinates
Extremely large radius
Malformed query parameters
Unauthorized saved-clinic requests
Provider URL injection

⸻

91. Performance Testing

Clinic search should ideally feel fast.

Target:

Cache hit:
very fast
Normal provider search:
acceptable latency
Provider failure:
fast failure rather than hanging

Exact latency targets can be established after implementation.

⸻

92. Zero-Budget MVP

The first implementation should be:

Flutter
   ↓
Spring Boot
   ↓
PostgreSQL
   ↓
MockClinicProvider

Features:

✓ Request location
✓ Nearby clinic list
✓ Distance
✓ Clinic details
✓ Phone button
✓ Website button
✓ Search radius

No real booking required.

⸻

93. Production Version

Eventually:

Flutter
   ↓
Spring Boot
   ↓
Redis
   ↓
PostgreSQL/PostGIS
   ↓
ClinicProvider
   ↓
External geographic/place data

Optional:

BookingProvider
GeocodingProvider
DirectionsProvider

⸻

94. Future Architecture

The long-term architecture:

                     DentAssist
                         |
              ┌──────────┴──────────┐
              |                     |
             AI                  Clinics
              |                     |
      ┌───────┼───────┐      ┌─────┼─────┐
      |       |       |      |     |     |
   Memory  Knowledge Safety Search Map Booking
                              |
                       ClinicProvider
                              |
                 ┌────────────┼────────────┐
                 |            |            |
              Open Data   Places API   Clinic DB

⸻

95. Recommended Build Order

Build in this order:

Step 1

Create:

Clinic

domain model.

⸻

Step 2

Create:

ClinicProvider

interface.

⸻

Step 3

Implement:

MockClinicProvider

⸻

Step 4

Create:

GET /clinics/nearby

⸻

Step 5

Implement:

ClinicService

⸻

Step 6

Implement:

Flutter location permission

⸻

Step 7

Build:

Clinic list screen

⸻

Step 8

Build:

Clinic details screen

⸻

Step 9

Add:

Redis caching

⸻

Step 10

Add:

Real clinic provider

only after the rest works.

⸻

Step 11

Add:

Map view

⸻

Step 12

Add:

Booking integration

later.

⸻

96. Summary

Clinic discovery should be treated as a first-class subsystem.

The key architectural principles are:

1. Do not hard-code one map provider.
2. Create a ClinicProvider interface.
3. Start with MockClinicProvider.
4. Keep provider credentials on the backend.
5. Do not expose paid API keys in Flutter.
6. Use device GPS when the user permits it.
7. Offer manual location search as a fallback.
8. Validate coordinates.
9. Support configurable search radius.
10. Rank results by distance initially.
11. Never fabricate clinic information.
12. Never invent phone numbers.
13. Never invent opening hours.
14. Never claim live appointment availability without live data.
15. Separate booking from clinic search.
16. Cache appropriate searches.
17. Rate-limit provider requests.
18. Store provider/source information.
19. Track data freshness.
20. Handle duplicate clinics.
21. Handle closed clinics.
22. Handle missing information gracefully.
23. Respect provider usage terms.
24. Respect attribution requirements.
25. Minimize storage of precise user location.
26. Build map view after list view works.
27. Build real provider integration after the mock system works.
28. Build booking after clinic discovery works.
29. Keep the entire subsystem replaceable.
30. Optimize for reliability before adding complexity.

The most important architectural boundary is:

             DENTASSIST
                  |
        ┌─────────┴─────────┐
        |                   |
       AI               CLINICS
        |                   |
   AiProvider         ClinicProvider
        |                   |
   ┌────┴────┐        ┌─────┴─────┐
   |    |    |        |     |     |
 Mock Local Cloud   Open  Places  DB

This means your original idea is becoming a real platform rather than a single chatbot.

The user can go from:

"I have tooth pain."

to:

"Help me understand it."

to:

"How urgent is this?"

to:

"Find a dentist near me."

to:

"Which one is open?"

to:

"How do I contact them?"

and eventually:

"Book me an appointment."

That entire journey is what makes DentAssist interesting.

Next, we should define 12_DATABASE_SCHEMA_AND_DATA_MODEL.md—the actual PostgreSQL design for users, conversations, messages, AI memory, usage/credits, clinics, saved clinics, provider records, and the relationships between all of them.