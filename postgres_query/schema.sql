-- CREATE DATABASE formatted_zone;

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
    flightNumber TEXT,
    departureAirportFsCode TEXT,
    arrivalAirportFsCode TEXT,
    departureTime TIMESTAMP,
    arrivalTime TIMESTAMP,
    stops BIGINT,
    departureTerminal INT,
    arrivalTerminal INT
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id TEXT UNIQUE,
    product_weight_g DOUBLE PRECISION,
    product_length_cm DOUBLE PRECISION,
    product_height_cm DOUBLE PRECISION,
    product_width_cm DOUBLE PRECISION,
    product_category_name_english TEXT,
    product_name TEXT
--     product_image_link TEXT
);

-- DROP TABLE IF EXISTS addresses;
-- CREATE TABLE addresses (
--     id SERIAL PRIMARY KEY,
--     streetName TEXT,
--     streetNumber INT,
--     buildingNumber TEXT,
--     city TEXT,
--     postalCode INT,
--     province TEXT,
--     country TEXT,
--     address_id INT UNIQUE
-- );

DROP TABLE IF EXISTS cities_distances;
CREATE TABLE cities_distances (
    country1 TEXT,
    name1 TEXT,
    country2 TEXT,
    name2 TEXT,
    distance_km DOUBLE PRECISION,
    currency TEXT,
    lpg_price DOUBLE PRECISION,
    diesel_price DOUBLE PRECISION,
    gasoline_price DOUBLE PRECISION
);


DROP TABLE IF EXISTS requests;
CREATE TABLE requests (
    initializationUserId BIGINT,
    collectionUserId BIGINT,
    travellerId INT,
    productId TEXT,
    dateToDeliver TIMESTAMP,
    dateDelivered TIMESTAMP,
    requestDate TIMESTAMP,
    pickUpAddress BIGINT,
    collectionAddress BIGINT,
    deliveryFee DOUBLE PRECISION,
    requestId INT,
    Satisfactory BOOLEAN
);

DROP TABLE IF EXISTS travels;
CREATE TABLE travels (
    userId BIGINT,
    departureAirportFsCode TEXT,
    arrivalAirportFsCode TEXT,
    departureTime TIMESTAMP,
    arrivalTime TIMESTAMP,
    extraLuggage BIGINT
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id BIGINT UNIQUE,
    -- firstname TEXT,
    -- lastname TEXT,
    gender TEXT,
    nationality TEXT,
--     mobile VARCHAR(50),
    dob DATE,
    is_traveller BOOLEAN,
    address BIGINT,
    city TEXT
);

-- DROP TABLE IF EXISTS dhl_price;
-- CREATE TABLE dhl_price (
--     Weight BIGINT,
--     A DOUBLE PRECISION,
--     B DOUBLE PRECISION,
--     C DOUBLE PRECISION,
--     D DOUBLE PRECISION
-- );

-- DROP TABLE IF EXISTS dhl_zone;
-- CREATE TABLE dhl_zone (
--     Region_start TEXT,
--     Zone_start BIGINT,
--     Region_end TEXT,
--     Zone_end BIGINT,
--     Type TEXT
-- );