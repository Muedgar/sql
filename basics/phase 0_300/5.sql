CREATE TYPE user_type_enum AS ENUM (
    'SYSTEM_USER',
    'GUEST'
);

CREATE TABLE users (
    pkid INTEGER PRIMARY KEY,
    id UUID UNIQUE DEFAULT gen_random_uuid(),
    firstName VARCHAR(200),
    lastName VARCHAR(200),
    age INT,
    nationalId VARCHAR(100),
    email VARCHAR(100),
    phoneNumber VARCHAR(100),
    address VARCHAR(100),
    password VARCHAR(100),
    status BOOLEAN,
    userType user_type_enum NOT NULL,
    createdAt DATE,
    updatedAt DATE
);

-- find all active users from kigali
SELECT * FROM users WHERE address = 'KIGALI' AND status = 'true';

-- find all users whose age is between 18 and 35
SELECT firstName, lastName, age FROM users WHERE age BETWEEN 18 AND 35;

-- find all users who are either in kigali, north, south, west or east
SELECT id, firstName, lastName, address FROM users WHERE address IN ('KIGALI', 'NORTH', 'SOUTH', 'WEST', 'EAST');

-- find all users whose first name starts with a
SELECT id, email, firstName FROM users WHERE firstName LIKE 'A%';

-- find all users who are not active
SELECT id, email FROM users WHERE status != 'true';

-- list the first 5 oldest users
SELECT id, firstName, lastName, age FROM users ORDER BY age DESC LIMIT 5;

-- how many users are in each address
SELECT address, COUNT(*) AS total_location FROM users GROUP BY address;

-- find users with age older than 25
SELECT age, COUNT(*) AS total_age FROM users GROUP BY age HAVING COUNT(*) > 25;

-- HOW MANY USERS ARE IN EACH ADDRESS
SELECT address, COUNT(*) AS total_location FROM users GROUP BY address;

-- find users with age older than 25
SELECT age, COUNT(*) AS total_age FROM users GROUP BY age HAVING COUNT(*) > 25;