CREATE TABLE Ride (
    RideID INT PRIMARY KEY,
    UserID INT,
    DriverID INT,
    PickupLocationID INT,
    DropoffLocationID INT,
    RideDateTime DATETIME,
    RideDuration INT,
    FareAmount DECIMAL(10, 2),
    RideStatus VARCHAR(20),
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    FOREIGN KEY (PickupLocationID) REFERENCES Location(LocationID),
    FOREIGN KEY (DropoffLocationID) REFERENCES Location(LocationID)
);


CREATE TABLE User (
    UserID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    RegistrationDate DATE,
    UserType VARCHAR(20)
);


CREATE TABLE Driver (
    DriverID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    RegistrationDate DATE,
    VehicleType VARCHAR(50),
    AverageRating DECIMAL(3, 2),
    TotalRidesCompleted INT
);


CREATE TABLE Location (
    LocationID INT PRIMARY KEY,
    Latitude DECIMAL(9, 6),
    Longitude DECIMAL(9, 6),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);