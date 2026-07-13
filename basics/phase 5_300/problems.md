Below are 10 intermediate → hard PostgreSQL migration problems.
Assume tables like:
users(id, full_name, email, phone, status, created_at)
orders(id, user_id, total_amount, status, created_at)
profiles(id, user_id, bio)


1. Add a new nullable column safely
Problem: Add last_login_at to users.
ALTER TABLE users
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP;


2. Rename a column
Problem: Rename phone to phone_number.
ALTER TABLE users
RENAME COLUMN phone TO phone_number;


3. Change a column type safely
Problem: Change total_amount from INT to NUMERIC(12,2).
ALTER TABLE orders
ALTER COLUMN total_amount TYPE NUMERIC(12, 2)
USING total_amount::NUMERIC(12, 2);


4. Add and remove constraints
Problem: Make email unique, then show rollback.
ALTER TABLE users
ADD CONSTRAINT users_email_unique UNIQUE (email);

Rollback:
ALTER TABLE users
DROP CONSTRAINT IF EXISTS users_email_unique;


5. Backfill data safely
Problem: Add status, backfill old users, then make it required.
ALTER TABLE users
ADD COLUMN IF NOT EXISTS status VARCHAR(20);

UPDATE users
SET status = 'ACTIVE'
WHERE status IS NULL;

ALTER TABLE users
ALTER COLUMN status SET DEFAULT 'ACTIVE';

ALTER TABLE users
ALTER COLUMN status SET NOT NULL;


6. Nullable → non-null migration with validation
Problem: Make email required safely.
SELECT COUNT(*) AS users_without_email
FROM users
WHERE email IS NULL;

-- Only continue if count = 0

ALTER TABLE users
ALTER COLUMN email SET NOT NULL;


7. Split one table into two tables
Problem: Move profile fields from users into user_profiles.
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL,
    bio TEXT,
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

INSERT INTO user_profiles (user_id, bio, address)
SELECT id, bio, address
FROM users
WHERE bio IS NOT NULL OR address IS NOT NULL
ON CONFLICT (user_id) DO NOTHING;


8. Merge two tables into one
Problem: Merge customers into users.
INSERT INTO users (id, full_name, email, created_at)
SELECT 
    id,
    name AS full_name,
    email,
    created_at
FROM customers
ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name;


9. Idempotent migration
Problem: Add deleted_at only if it does not exist.
ALTER TABLE users
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_users_deleted_at
ON users(deleted_at);


10. Clean old unused data safely
Problem: Delete old draft orders older than 1 year.
BEGIN;

SELECT COUNT(*) AS rows_to_delete
FROM orders
WHERE status = 'DRAFT'
  AND created_at < NOW() - INTERVAL '1 year';

DELETE FROM orders
WHERE status = 'DRAFT'
  AND created_at < NOW() - INTERVAL '1 year'
RETURNING id, status, created_at;

-- If result is wrong:
-- ROLLBACK;

-- If result is correct:
COMMIT;

Important production idea: schema migration is not just “change table.” It is usually:
add safely → backfill data → validate → enforce constraint → clean old structure


