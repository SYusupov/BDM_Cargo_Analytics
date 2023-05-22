-- CREATE DATABASE formatted_zone;

DROP TABLE IF EXISTS scheduledFlights;
CREATE TABLE scheduledFlights (
    id SERIAL PRIMARY KEY,
    flightNumber VARCHAR(50),
    departureAirportFsCode VARCHAR(50),
    arrivalAirportFsCode VARCHAR(50),
    departureTime TIMESTAMP,
    arrivalTime TIMESTAMP,
    stops INT,
    departureTerminal INT,
    arrivalTerminal INT
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,
    product_category_name_english TEXT,
    product_name TEXT,
    product_image_link TEXT
);

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    streetName TEXT,
    streetNumber INT,
    buildingNumber TEXT,
    city TEXT,
    postalCode INT,
    province TEXT,
    country TEXT,
    address_id INT UNIQUE
);

DROP TABLE IF EXISTS cities_distances;
CREATE TABLE cities_distances (
    id SERIAL PRIMARY KEY,
    country1 TEXT,
    latitude1 FLOAT,
    longitude1 FLOAT,
    name1 TEXT,
    country2 TEXT,
    latitude2 FLOAT,
    longitude2 FLOAT,
    name2 TEXT,
    distance_km FLOAT
);

DROP TABLE IF EXISTS requests;
CREATE TABLE requests (
    id SERIAL PRIMARY KEY,
    initializationUserId INT,
    collectionUserId INT,
    travellerId INT,
    productId VARCHAR(50),
    dateToDeliver TIMESTAMP,
    dateDelivered TIMESTAMP,
    requestDate TIMESTAMP,
    pickUpAddress INT,
    collectionAddress INT,
    description TEXT,
    deliveryFee FLOAT
);

DROP TABLE IF EXISTS travels;
CREATE TABLE travels (
    id SERIAL PRIMARY KEY,
    userId INT,
    departureAirportFsCode VARCHAR(5),
    arrivalAirportFsCode VARCHAR(5),
    departureTime TIMESTAMP,
    arrivalTime TIMESTAMP,
    extraLuggage INT
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE,
    firstname TEXT,
    lastname TEXT,
    gender TEXT,
    nationality TEXT,
    mobile VARCHAR(50),
    dob DATE,
    is_traveller BOOL,
    address INT
);
