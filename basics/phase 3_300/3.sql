-- update one user safely
UPDATE users SET name = 'Edgar Mutangana', updated_at = NOW() WHERE id = 'uuid' RETURNING id, name, updated_at;

-- 
UPDATE posts SET status = 'ARCHIVED', updated_at = NOW() WHERE status = 'DRAFT' AND created_at < NOW() - INTERVAL '90 days' RETURNING id, title, status;

DELETE FROM posts WHERE id = 'post_uuid' RETURNING id, title;

-- delete with safety checks
DELETE FROM posts WHERE status = 'DRAFT' AND created_at < NOW() - INTERVAL '1 year' RETURNING id, title, created_at;

-- BULK INSERT DATA
INSERT INTO users (id, name, email, status, created_at, updated_at) VALUES 
(gen_random_uuid(), 'Alice', 'alice@example.com', 'ACTIVE', NOW(), NOW()),
(gen_random_uuid(), 'Bob', 'bob@example.com', 'ACTIVE', NOW(), NOW()),
(gen_random_uuid(), 'Clara', 'clara@example.com', 'INACTIVE', NOW(), NOW()) RETURNING id, name, email;

INSERT INTO archived_users (id, name, email, archived_at) SELECT id, UPPER(name) AS name, LOWER(email) AS email, NOW FROM users WHERE status = 'INACTIVE' RETURNING id, name, email;

BEGIN;
UPDATE orders
SET
    status = 'CANCELLED',
    updated_at = NOW()
WHERE status = 'PENDING'
    AND created_at < NOW() - INTERVAL '30 days'
RETURNING id, status, updated_at;

COMMIT;

BEGIN;

SELECT COUNT(*) AS rows_that_will_change FROM users WHERE status = 'INACTIVE' AND updated_at < NOW() - INTERVAL '100 days';

UPDATE users SET status = 'ARCHIVED', updated_at = NOW() WHERE status = 'INACTIVE' AND updated_at < NOW() - INTERVAL '100 days' RETURNING id, email, status;

COMMIT;