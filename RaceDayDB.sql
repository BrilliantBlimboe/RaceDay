IF DB_ID(N'RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

CREATE TABLE dbo.[EVENT]
(
    EventID             INT IDENTITY(1,1) NOT NULL,
    EventName           VARCHAR(150) NOT NULL,
    EventDescription    VARCHAR(MAX) NULL,
    EventType           VARCHAR(20) NOT NULL
        CONSTRAINT CK_EVENT_EventType
        CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    EventDate            DATETIME NOT NULL,
    StartLocation        VARCHAR(150) NOT NULL,
    EndLocation          VARCHAR(150) NOT NULL,
    CreatedAt            DATETIME NOT NULL
        CONSTRAINT DF_EVENT_CreatedAt DEFAULT GETDATE(),
    Status               VARCHAR(20) NOT NULL
        CONSTRAINT DF_EVENT_Status DEFAULT 'Draft'
        CONSTRAINT CK_EVENT_Status
        CHECK (Status IN ('Draft', 'Published', 'Cancelled')),

    CONSTRAINT PK_EVENT PRIMARY KEY (EventID),
    CONSTRAINT UQ_EVENT_NameDate UNIQUE (EventName, EventDate)
);

CREATE TABLE dbo.CATEGORY
(
    CategoryID      INT IDENTITY(1,1) NOT NULL,
    EventID         INT NOT NULL,
    CategoryName    VARCHAR(100) NOT NULL,
    CategoryType    VARCHAR(50) NOT NULL,
    Gender          VARCHAR(20) NOT NULL
        CONSTRAINT DF_CATEGORY_Gender DEFAULT 'Open'
        CONSTRAINT CK_CATEGORY_Gender
        CHECK (Gender IN ('Male', 'Female', 'Mixed', 'Open')),
    MinAge          INT NULL,
    MaxAge          INT NULL,
    Distance        DECIMAL(6,2) NULL,
    TeamSize        INT NULL,
    Description     VARCHAR(MAX) NULL,

    CONSTRAINT PK_CATEGORY PRIMARY KEY (CategoryID),

    CONSTRAINT FK_CATEGORY_Event
        FOREIGN KEY (EventID) REFERENCES dbo.[EVENT](EventID),

    CONSTRAINT UQ_CATEGORY_EventName
        UNIQUE (EventID, CategoryName),

    CONSTRAINT UQ_CATEGORY_CategoryEvent
        UNIQUE (CategoryID, EventID),

    CONSTRAINT CK_CATEGORY_Age
        CHECK (
            (MinAge IS NULL OR MinAge >= 0)
            AND
            (MaxAge IS NULL OR MaxAge >= 0)
            AND
            (MinAge IS NULL OR MaxAge IS NULL OR MinAge <= MaxAge)
        ),

    CONSTRAINT CK_CATEGORY_Distance
        CHECK (Distance IS NULL OR Distance > 0),

    CONSTRAINT CK_CATEGORY_TeamSize
        CHECK (TeamSize IS NULL OR TeamSize > 0)
);
GO

CREATE TABLE dbo.EVENT_ORGANISER
(
    EventOrganiserID INT IDENTITY(1,1) NOT NULL,
    UserID           INT NOT NULL,
    EventID          INT NOT NULL,
    AssignedAt       DATETIME NOT NULL
        CONSTRAINT DF_EVENT_ORGANISER_AssignedAt DEFAULT GETDATE(),
    RoleInEvent      VARCHAR(20) NOT NULL
        CONSTRAINT DF_EVENT_ORGANISER_RoleInEvent DEFAULT 'Main'
        CONSTRAINT CK_EVENT_ORGANISER_RoleInEvent
        CHECK (RoleInEvent IN ('Main', 'Co-ordinator')),

    CONSTRAINT PK_EVENT_ORGANISER PRIMARY KEY (EventOrganiserID),

    CONSTRAINT FK_EVENT_ORGANISER_User
        FOREIGN KEY (UserID) REFERENCES dbo.[USER](UserID),

    CONSTRAINT FK_EVENT_ORGANISER_Event
        FOREIGN KEY (EventID) REFERENCES dbo.[EVENT](EventID),

    CONSTRAINT UQ_EVENT_ORGANISER_UserEvent
        UNIQUE (UserID, EventID)
);
GO

CREATE TABLE dbo.REGISTRATION
(
    RegistrationID      INT IDENTITY(1,1) NOT NULL,
    UserID              INT NOT NULL,
    EventID             INT NOT NULL,
    CategoryID          INT NOT NULL,
    RegistrationDate    DATETIME NOT NULL
        CONSTRAINT DF_REGISTRATION_RegistrationDate DEFAULT GETDATE(),
    PaymentStatus       VARCHAR(20) NOT NULL
        CONSTRAINT DF_REGISTRATION_PaymentStatus DEFAULT 'Pending'
        CONSTRAINT CK_REGISTRATION_PaymentStatus
        CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed')),
    PaymentReference    VARCHAR(100) NULL,
    EntryFee            DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_REGISTRATION_EntryFee DEFAULT 0.00
        CONSTRAINT CK_REGISTRATION_EntryFee CHECK (EntryFee >= 0),
    Status              VARCHAR(20) NOT NULL
        CONSTRAINT DF_REGISTRATION_Status DEFAULT 'Active'
        CONSTRAINT CK_REGISTRATION_Status
        CHECK (Status IN ('Active', 'Cancelled', 'DNS')),

    CONSTRAINT PK_REGISTRATION PRIMARY KEY (RegistrationID),

    CONSTRAINT FK_REGISTRATION_User
        FOREIGN KEY (UserID) REFERENCES dbo.[USER](UserID),

    CONSTRAINT FK_REGISTRATION_Event
        FOREIGN KEY (EventID) REFERENCES dbo.[EVENT](EventID),

    CONSTRAINT FK_REGISTRATION_CategoryEvent
        FOREIGN KEY (CategoryID, EventID)
        REFERENCES dbo.CATEGORY(CategoryID, EventID),

    CONSTRAINT UQ_REGISTRATION_UserEvent
        UNIQUE (UserID, EventID),

    CONSTRAINT UQ_REGISTRATION_PaymentReference
        UNIQUE (PaymentReference)
);
GO

CREATE TABLE dbo.RESULT
(
    ResultID           INT IDENTITY(1,1) NOT NULL,
    RegistrationID     INT NOT NULL,
    FinishTime         DATETIME NULL,
    ChipTime           TIME(0) NULL,
    PositionOverall    INT NULL,
    PositionCategory   INT NULL,
    Pace               DECIMAL(6,2) NULL,
    RecordedAt         DATETIME NOT NULL
        CONSTRAINT DF_RESULT_RecordedAt DEFAULT GETDATE(),

    CONSTRAINT PK_RESULT PRIMARY KEY (ResultID),

    CONSTRAINT FK_RESULT_Registration
        FOREIGN KEY (RegistrationID)
        REFERENCES dbo.REGISTRATION(RegistrationID),

    CONSTRAINT UQ_RESULT_Registration UNIQUE (RegistrationID),

    CONSTRAINT CK_RESULT_PositionOverall
        CHECK (PositionOverall IS NULL OR PositionOverall > 0),

    CONSTRAINT CK_RESULT_PositionCategory
        CHECK (PositionCategory IS NULL OR PositionCategory > 0),

    CONSTRAINT CK_RESULT_Pace
        CHECK (Pace IS NULL OR Pace > 0)
);
GO

CREATE TABLE dbo.ROUTE
(
    RouteID          INT IDENTITY(1,1) NOT NULL,
    EventID          INT NOT NULL,
    RouteName        VARCHAR(100) NOT NULL,
    Distance         DECIMAL(6,2) NOT NULL,
    ElevationGain    INT NOT NULL
        CONSTRAINT DF_ROUTE_ElevationGain DEFAULT 0,
    RouteDescription VARCHAR(MAX) NULL,
    MapURL           VARCHAR(255) NULL,
    GPXFileUrl       VARCHAR(255) NULL,
    CreatedAt        DATETIME NOT NULL
        CONSTRAINT DF_ROUTE_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_ROUTE PRIMARY KEY (RouteID),

    CONSTRAINT FK_ROUTE_Event
        FOREIGN KEY (EventID) REFERENCES dbo.[EVENT](EventID),

    CONSTRAINT UQ_ROUTE_EventID UNIQUE (EventID),

    CONSTRAINT CK_ROUTE_Distance CHECK (Distance > 0),
    CONSTRAINT CK_ROUTE_ElevationGain CHECK (ElevationGain >= 0)
);
GO

CREATE TABLE dbo.WEATHER
(
    WeatherID          INT IDENTITY(1,1) NOT NULL,
    EventID            INT NOT NULL,
    WeatherDate        DATETIME NOT NULL,
    TemperatureMin     DECIMAL(5,2) NULL,
    TemperatureMax     DECIMAL(5,2) NULL,
    Conditions         VARCHAR(100) NULL,
    Precipitation      DECIMAL(6,2) NULL,
    WindSpeed          DECIMAL(6,2) NULL,
    Humidity            INT NULL,
    Source              VARCHAR(100) NULL,
    CreatedAt           DATETIME NOT NULL
        CONSTRAINT DF_WEATHER_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_WEATHER PRIMARY KEY (WeatherID),

    CONSTRAINT FK_WEATHER_Event
        FOREIGN KEY (EventID) REFERENCES dbo.[EVENT](EventID),

    CONSTRAINT CK_WEATHER_Temperature
        CHECK (
            TemperatureMin IS NULL OR
            TemperatureMax IS NULL OR
            TemperatureMin <= TemperatureMax
        ),

    CONSTRAINT CK_WEATHER_Precipitation
        CHECK (Precipitation IS NULL OR Precipitation >= 0),

    CONSTRAINT CK_WEATHER_WindSpeed
        CHECK (WindSpeed IS NULL OR WindSpeed >= 0),

    CONSTRAINT CK_WEATHER_Humidity
        CHECK (Humidity IS NULL OR Humidity BETWEEN 0 AND 100)
);
GO

CREATE TABLE dbo.[USER]
(
    UserID          INT IDENTITY(1,1) NOT NULL,
    FirstName       VARCHAR(50) NOT NULL,
    LastName        VARCHAR(50) NOT NULL,
    Email           VARCHAR(100) NOT NULL,
    PasswordHash    VARCHAR(255) NOT NULL,
    Phone           VARCHAR(20) NULL,
    DateOfBirth     DATE NULL,
    Role            VARCHAR(20) NOT NULL
        CONSTRAINT CK_USER_Role CHECK (Role IN ('Participant', 'Organiser')),
    CreatedAt       DATETIME NOT NULL
        CONSTRAINT DF_USER_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_USER PRIMARY KEY (UserID),
    CONSTRAINT UQ_USER_Email UNIQUE (Email)
);
GO

INSERT INTO dbo.[EVENT]
    (EventName, EventDescription, EventType, EventDate,
     StartLocation, EndLocation, Status)
VALUES
    ('Pretoria City 10K', 
     'A community road-running event through central Pretoria.',
     'Run', '2026-10-11 07:00:00',
     'Union Buildings', 'Church Square', 'Published'),

    ('Limpopo Family Walk',
     'A family-friendly walking event with scenic routes.',
     'Walk', '2026-11-08 08:00:00',
     'Polokwane Civic Centre', 'Polokwane Game Reserve Gate', 'Published'),

    ('Gauteng Cycle Challenge',
     'A road-cycling challenge for recreational and experienced cyclists.',
     'Cycle', '2026-12-06 06:30:00',
     'Irene Mall', 'Centurion Sports Centre', 'Draft');
GO

INSERT INTO dbo.[USER]
    (FirstName, LastName, Email, PasswordHash, Phone, DateOfBirth, Role)
VALUES
    ('Thabo', 'Mokoena', 'thabo.mokoena@raceday.co.za',
     'HASH_DEMO_THABO_001', '0825550101', '1988-04-15', 'Organiser'),

    ('Naledi', 'Mahlangu', 'naledi.mahlangu@raceday.co.za',
     'HASH_DEMO_NALEDI_002', '0835550102', '1990-09-22', 'Organiser'),

    ('Kabelo', 'Molefe', 'kabelo.molefe@example.com',
     'HASH_DEMO_KABELO_003', '0845550103', '2001-06-10', 'Participant'),

    ('Lerato', 'Ndlovu', 'lerato.ndlovu@example.com',
     'HASH_DEMO_LERATO_004', '0855550104', '1998-11-03', 'Participant');
GO

INSERT INTO dbo.CATEGORY
    (EventID, CategoryName, CategoryType, Gender,
     MinAge, MaxAge, Distance, TeamSize, Description)
VALUES
    -- Event 1: Pretoria City 10K
    (1, '10K Open', 'Distance', 'Open',
     18, 99, 10.00, NULL, 'Open 10 kilometre race category.'),

    (1, '10K Junior', 'Age Group', 'Open',
     13, 17, 10.00, NULL, 'Junior 10 kilometre category.'),

    -- Event 2: Limpopo Family Walk
    (2, '5K Family Walk', 'Distance', 'Mixed',
     8, 99, 5.00, 4, 'Family teams of up to four walkers.'),

    (2, '10K Open Walk', 'Distance', 'Open',
     16, 99, 10.00, NULL, 'Open ten kilometre walking category.'),

    -- Event 3: Gauteng Cycle Challenge
    (3, '40K Road Cycle', 'Distance', 'Open',
     18, 99, 40.00, NULL, 'Forty kilometre road cycling category.'),

    (3, '20K Development Cycle', 'Distance', 'Open',
     14, 17, 20.00, NULL, 'Junior development cycling category.');
GO

INSERT INTO dbo.EVENT_ORGANISER
    (UserID, EventID, RoleInEvent)
VALUES
    (1, 1, 'Main'),
    (2, 2, 'Main'),
    (1, 3, 'Main'),
    (2, 3, 'Co-ordinator');
GO

INSERT INTO dbo.REGISTRATION
    (UserID, EventID, CategoryID, RegistrationDate,
     PaymentStatus, PaymentReference, EntryFee, Status)
VALUES
    (3, 1, 1, '2026-08-20 10:15:00',
     'Paid', 'PAY-RD-10001', 180.00, 'Active'),

    (4, 1, 1, '2026-08-21 11:30:00',
     'Paid', 'PAY-RD-10002', 180.00, 'Active'),

    (3, 2, 3, '2026-08-25 09:20:00',
     'Paid', 'PAY-RD-10003', 100.00, 'Active'),

    (4, 2, 4, '2026-08-26 14:05:00',
     'Pending', 'PAY-RD-10004', 130.00, 'Active'),

    (3, 3, 5, '2026-08-28 16:10:00',
     'Paid', 'PAY-RD-10005', 250.00, 'Active');
GO

INSERT INTO dbo.RESULT
    (RegistrationID, FinishTime, ChipTime,
     PositionOverall, PositionCategory, Pace)
VALUES
    (1, '2026-10-11 08:02:15', '01:02:15',
     12, 7, 6.23),

    (2, '2026-10-11 08:08:40', '01:08:40',
     21, 13, 6.87);
GO

INSERT INTO dbo.ROUTE
    (EventID, RouteName, Distance, ElevationGain,
     RouteDescription, MapURL, GPXFileUrl)
VALUES
    (1, 'Union Buildings to Church Square',
     10.00, 95,
     'City route through Pretoria central with a gradual finish.',
     'https://example.com/routes/pretoria-10k',
     'https://example.com/gpx/pretoria-10k.gpx'),

    (2, 'Polokwane Family Scenic Route',
     5.00, 35,
     'Mostly flat scenic family walking route.',
     'https://example.com/routes/limpopo-family',
     'https://example.com/gpx/limpopo-family.gpx'),

    (3, 'Irene to Centurion Challenge',
     40.00, 420,
     'Road cycling route with moderate climbs.',
     'https://example.com/routes/gauteng-cycle',
     'https://example.com/gpx/gauteng-cycle.gpx');
GO

INSERT INTO dbo.WEATHER
    (EventID, WeatherDate, TemperatureMin, TemperatureMax,
     Conditions, Precipitation, WindSpeed, Humidity, Source)
VALUES
    (1, '2026-10-11 06:30:00', 12.00, 24.00,
     'Clear', 0.00, 10.50, 55, 'RaceDay Forecast'),

    (2, '2026-11-08 07:30:00', 15.00, 27.00,
     'Partly Cloudy', 0.20, 8.00, 60, 'RaceDay Forecast'),

    (3, '2026-12-06 06:00:00', 14.00, 26.00,
     'Sunny', 0.00, 14.00, 48, 'RaceDay Forecast');
GO

