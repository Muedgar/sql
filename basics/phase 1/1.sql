CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_type_enum AS ENUM ('SYSTEM_USER', 'GUEST');

CREATE TABLE users (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    first_name VARCHAR(200),
    last_name VARCHAR(200),
    email VARCHAR(150) UNIQUE NOT NULL,
    phone_number VARCHAR(50) UNIQUE,
    password_hash TEXT NOT NULL,
    user_type user_type_enum NOT NULL DEFAULT 'GUEST',
    status BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
)