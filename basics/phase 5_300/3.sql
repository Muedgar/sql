ALTER TABLE users AND COLUMN IF NOT EXISTS last_login_at TIMESTAMP;

ALTER TABLE users RENAME COLUMN phone TO phone_number;

ALTER TABLE orders ALTER COLUMN total_amount TYPE NUMERIC(12, 2) USING total_amount::NUMERIC(12, 2);

ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);