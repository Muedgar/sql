Use this practical schema:
users(id, name, email, status, created_at, updated_at)
posts(id, user_id, title, status, created_at, updated_at)
archived_users(id, name, email, archived_at)
orders(id, user_id, total_amount, status, created_at, updated_at)


1. Update one user safely
UPDATE users
SET 
  name = 'Edgar Mutangana',
  updated_at = NOW()
WHERE id = 'USER_UUID_HERE'
RETURNING id, name, updated_at;


2. Update many rows with conditions
UPDATE posts
SET 
  status = 'ARCHIVED',
  updated_at = NOW()
WHERE status = 'DRAFT'
  AND created_at < NOW() - INTERVAL '90 days'
RETURNING id, title, status;


3. Delete one row safely
DELETE FROM posts
WHERE id = 'POST_UUID_HERE'
RETURNING id, title;


4. Delete with safety checks
DELETE FROM posts
WHERE status = 'DRAFT'
  AND created_at < NOW() - INTERVAL '1 year'
RETURNING id, title, created_at;


5. Insert from another table
INSERT INTO archived_users (id, name, email, archived_at)
SELECT id, name, email, NOW()
FROM users
WHERE status = 'INACTIVE'
RETURNING id, email, archived_at;


6. Upsert user by email
INSERT INTO users (
  id,
  name,
  email,
  status,
  created_at,
  updated_at
)
VALUES (
  gen_random_uuid(),
  'Edgar',
  'edgar@example.com',
  'ACTIVE',
  NOW(),
  NOW()
)
ON CONFLICT (email)
DO UPDATE SET
  name = EXCLUDED.name,
  status = EXCLUDED.status,
  updated_at = NOW()
RETURNING id, name, email, status;


7. Bulk insert data
INSERT INTO users (id, name, email, status, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'Alice', 'alice@example.com', 'ACTIVE', NOW(), NOW()),
  (gen_random_uuid(), 'Bob', 'bob@example.com', 'ACTIVE', NOW(), NOW()),
  (gen_random_uuid(), 'Clara', 'clara@example.com', 'INACTIVE', NOW(), NOW())
RETURNING id, name, email;


8. Copy and modify data during insert
INSERT INTO archived_users (id, name, email, archived_at)
SELECT 
  id,
  UPPER(name) AS name,
  LOWER(email) AS email,
  NOW()
FROM users
WHERE status = 'INACTIVE'
RETURNING id, name, email;


9. Safe transaction with rollback option
BEGIN;

UPDATE orders
SET 
  status = 'CANCELLED',
  updated_at = NOW()
WHERE status = 'PENDING'
  AND created_at < NOW() - INTERVAL '30 days'
RETURNING id, status, updated_at;

-- If result looks wrong:
-- ROLLBACK;

-- If result looks correct:
COMMIT;


10. Production-safe update with pre-check
BEGIN;

SELECT COUNT(*) AS rows_that_will_change
FROM users
WHERE status = 'INACTIVE'
  AND updated_at < NOW() - INTERVAL '180 days';

UPDATE users
SET 
  status = 'ARCHIVED',
  updated_at = NOW()
WHERE status = 'INACTIVE'
  AND updated_at < NOW() - INTERVAL '180 days'
RETURNING id, email, status;

COMMIT;

Main safety rule: never run UPDATE or DELETE without a WHERE unless you truly mean the whole table.

