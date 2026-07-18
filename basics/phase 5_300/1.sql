-- ADD A NEW NULLABLE COLUMN SAFELY
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP;

-- RENAME A COLUMN
ALTER TABLE users RENAME COLUMN phone TO phone_number;

-- CHANGE A COLUMN TYPE SAFELY
ALTER TABLE orders ALTER COLUMN total_amount TYPE NUMERIC(12,2) USING total_amount::NUMERIC(12, 2);

-- ADD AND REMOVE CONSTRAINTS
-- Make email unique, then show rollback.
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Rollback:
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_unique;

-- BACKFILL DATA SAFELY
-- Add status, 
ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(20);

UPDATE users SET status = 'ACTIVE' WHERE status IS NULL;

ALTER TABLE users ALTER COLUMN status SET DEFAULT 'ACTIVE';

ALTER TABLE users ALTER COLUMN status SET NOT NULL;

-- NULLABLE -> NOT NULL MIGRATION WITH VALIDATION
-- Make email required safely.
SELECT COUNT(*) AS users_without_email FROM users WHERE email IS NULL;

-- Only continue if count = 0
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- Split one table into two tables
-- Move profile fields from users into user_profiles.
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL,
    bio TEXT,
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO user_profiles (user_id, bio, address) SELECT id, bio, address FROM users WHERE bio IS NOT NULL OR address IS NOT NULL ON CONFLICT (user_id) DO NOTHING;

-- Merge two tables into one
INSERT INTO users (id, full_name, email, created_at) SELECT id, name AS full_name, email, created_at FROM customers ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name;

-- Idempotent migration
-- Add deleted_at only if it does not exists.
ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);

-- CLEAN OLD UNUSED DATA SAFELY
-- Delete old draft orders older than 1 year.
BEGIN;
SELECT COUNT(*) AS rows_to_delete FROM orders WHERE status = 'DRAFT' AND created_at < NOW() - INTERVAL '1 year';

DELETE FROM orders WHERE status = 'DRAFT' AND created_at < NOW() - INTERVAL '1 year' RETURNING id, status, created_at;

-- If result is wrong:
-- ROLLBACK;

-- If result is correct:
COMMIT;