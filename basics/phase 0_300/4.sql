CREATE TYPE user_type_enum AS ENUM (
    'SYSTEM_USER',
    'GUEST'
);

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

SELECT * FROM users WHERE address = 'KIGALI' AND status = 'true';

SELECT firstName, lastName, age FROM users WHERE age BETWEEN 18 AND 35;

SELECT id, firstName, lastName, address FROM users WHERE address IN ('KIGALI', 'NORTH', 'SOUTH', 'WEST', 'EAST');

SELECT id, email, firstName FROM users WHERE firstName LIKE 'A%';

SELECT id, email FROM users WHERE status != 'true';

SELECT id, email, lastName, age FROM users ORDER BY age DESC LIMIT 5;

SELECT address, COUNT(*) AS total_location FROM users GROUP BY address;

SELECT age, COUNT(*) AS total_age FROM users GROUP BY age HAVING COUNT(*) > 25;