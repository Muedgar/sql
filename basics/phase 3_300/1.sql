-- UPDATE ONE USER SAFELY
UPDATE users SET name = 'Edgar Mutangana', updated_at = NOW() WHERE id = 'USER_UUID_HERE' RETURNING id, name, updated_at;

UPDATE posts SET status = 'ARCHIVED', updated_at = NOW() WHERE status = 'DRAFT' AND created_at < NOW() - INTERVAL '90 days' RETURNING id, title, status;

DELETE FROM posts WHERE id = 'POST_UUID_HERE' RETURNING id, title;

-- DELETE WITH SAFETY CHECKS
DELETE FROM posts WHERE status = 'DRAFT' AND created_at < NOW() - INTERVAL '1 year' RETURNING id, title, created_at;

-- INSERT FROM ANOTHER TABLE
INSERT INTO archived_users (id, name, email, archived_at) SELECT id, name, email, NOW() FROM users WHERE status = 'INACTIVE' RETURNING id, email, archived_at;

-- UPSERT USER BY EMAIL
INSERT INTO users (id, name, email, status, created_at, updated_at) VALUES (gen_random_uuid(), 'Edgar', 'edgar@example.com', 'ACTIVE', NOW(), NOW()) ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, status = EXCLUDED.status, updated_at = NOW() RETURNING id, name, email, status;

-- BULK INSERT DATA
INSERT INTO users (id, name, email, status, created_at, updated_at) VALUES 
(gen_random_uuid(), 'Alice', 'alice@example.com', 'ACTIVE', NOW(), NOW()),
(gen_random_uuid(), 'Bob', 'bob@example.com', 'ACTIVE', NOW(), NOW()),
(gen_random_uuid(), 'Clara', 'clara@example.com', 'INACTIVE', NOW(), NOW()) RETURNING id, name, email;

-- COPY AND MODIFY DATA DURING INSERT
INSERT INTO archived_users (id, name, email, archived_at) SELECT id, UPPER(name) AS name, LOWER(email) AS email, NOW FROM users WHERE status = 'INACTIVE' RETURNING id, name, email;

-- SAFE TRANSACTION WITH ROLLBACK OPTION
BEGIN;
UPDATE orders
SET 
    status = 'CANCELLED',
    updated_at = NOW()
WHERE status = 'PENDING'
    AND created_at < NOW() - INTERVAL '30 days'
RETURNING id, status, updated_at;

-- If result looks wrong:
-- ROOLBACK;

-- If result looks correct:
COMMIT;

-- Production-safe update with pre-check
BEGIN;

SELECT COUNT(*) AS rows_that_will_change FROM users WHERE status = 'INACTIVE' AND updated_at < NOW() - INTERVAL '180 days';

UPDATE users SET status = 'ARCHIVED', updated_at = NOW() WHERE status = 'INACTIVE' AND updated_at < NOW() - INTERVAL '180 days' RETURNING id, email, status;

COMMIT;