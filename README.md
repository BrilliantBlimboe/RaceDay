# RaceDay

## South African Road Running, Walking and Cycling Event Management System

RaceDay is a full-stack web-based event management system designed for the South African road running, walking and cycling community.

The system is designed to help Event Organisers manage events, categories, participant enrolments and race results, while allowing Participants to browse events, enter races and view their performance history.

---

## Project Overview

Many road running, walking and cycling events are still managed using paper forms, spreadsheets and disconnected communication systems.

RaceDay aims to provide a centralised digital platform that makes event management easier for organisers and provides participants with a convenient way to manage their race activities.

The project will be developed progressively across multiple parts, starting with system planning and database design.

---

## Main Users

### Participant

Participants will be able to:

- Register and log in.
- View and update their profile.
- Browse upcoming events.
- View event information.
- Enrol in events.
- Select an event category.
- View their own race results.
- Track their performance history.
- View route information.
- View weather information.

### Event Organiser

Organisers will be able to:

- Register and log in.
- View and update their profile.
- Create events.
- Update events.
- Delete events.
- Manage event categories.
- View participant enrolments.
- Capture participant results.
- Manage event information.
- View event results.

---

# Part 1 - System Planning and Database

Part 1 focuses on planning the RaceDay system before application development begins.

## Section A - Entity Relationship Diagram

The RaceDay database contains the following main entities:

- User
- Event
- EventOrganiser
- Category
- Registration
- Result
- Route
- Weather

The ERD identifies:

- Primary keys
- Foreign keys
- Entity attributes
- One-to-many relationships
- Many-to-many relationships
- Database cardinality

The ERD is available in:

`/docs/RaceDay_ERD.png`

---

## Section B - API Endpoint Plan

The API endpoint plan defines the RESTful endpoints that will be implemented in Part 2.

The planned API covers:

- Authentication
- User profiles
- Events
- Categories
- Event enrolments
- Results

The API endpoint plan is available in:

`/docs/API_Endpoint_Plan.pdf`

The implemented API will be developed according to the approved endpoint plan.

---

## Section C - SQL Database Script

The RaceDay database is designed for Microsoft SQL Server and can be created using SQL Server Management Studio (SSMS).

The SQL script contains:

- Database creation
- Table creation
- Primary keys
- Foreign keys
- NOT NULL constraints
- UNIQUE constraints
- DEFAULT constraints
- CHECK constraints
- Sample data

The database is seeded with:

- At least 2 Organisers
- At least 2 Participants
- 3 Events
- Categories for each event
- Sample event enrolments
- Sample results
- Route information
- Weather information

The SQL script is available in:

`/docs/RaceDay_Database.sql`

---

# Database Entities

| Entity | Purpose |
|---|---|
| User | Stores participant and organiser information |
| Event | Stores road running, walking and cycling events |
| EventOrganiser | Links organisers to events |
| Category | Stores age and distance categories |
| Registration | Records participant event enrolments |
| Result | Stores participant race results |
| Route | Stores event route information |
| Weather | Stores event weather information |

---

# Technology Stack

The project is planned to use:

- SQL Server
- SQL Server Management Studio (SSMS)
- RESTful API
- C#
- .NET
- GitHub
- Git/GitHub version control

---

# Repository Structure

```text
RaceDay/
│
├── docs/
│   ├── RaceDay_ERD.png
│   ├── API_Endpoint_Plan.pdf
│   └── RaceDay_Database.sql
│
├── src/
│
└── README.md
