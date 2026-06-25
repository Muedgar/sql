CREATE TYPE user_type_enum AS ENUM (
    'SYSTEM_USER',
    'GUEST'
)

CREATE TABLE users (
    pkid INT PRIMARY KEY,
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
    createdAt DATE
);



-- 1. FIND ALL ACTIVE USERS FROM KIGALI
SELECT * FROM users
    WHERE address = 'KIGALI'
    AND status = 'true';

-- 2. FIND ALL USERS WHOSE AGE IS BETWEEN 18 AND 35
SELECT firstName, lastName, age
    FROM users
    WHERE age BETWEEN 18 AND 35;

-- 3. FIND ALL USERS WHO ARE EITHER IN KIGALI, NORTH, SOUTH, WEST OR EAST
SELECT id, firstName, lastName, address
    FROM users
    WHERE address IN ('KIGALI', 'NORTH', 'SOUTH', 'WEST', 'EAST');

-- 4. FIND ALL USERS WHOSE FIRST NAME STARTS WITH A
SELECT id, email, firstName
    FROM users
    WHERE firstName LIKE 'A%';

-- 5. FIND ALL USERS WHO ARE NOT ACTIVE
SELECT id, email
    FROM users
    WHERE status != 'true';

-- 6. LIST THE FIRST 5 OLDEST USERS
SELECT id, firstName, lastName, age
    FROM users
    ORDER BY age DESC
    LIMIT 5;

-- 7. How many users are in each address
SELECT address, COUNT(*) AS total_location
    FROM users
    GROUP BY address;

-- 8. Find users with age older than 25
SELECT age, COUNT(*) AS total_age
    FROM users
    GROUP BY age
    HAVING COUNT(*) > 25;

-- 9. Find the youngest and oldest user by location
