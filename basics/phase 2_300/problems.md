Use this practical schema:
users(id, name, email, created_at)
posts(id, user_id, title, status, created_at)
comments(id, post_id, user_id, body, created_at)
orders(id, user_id, total_amount, created_at)


1. Inner join: users who have posts
SELECT 
  u.id,
  u.name,
  p.title
FROM users u
INNER JOIN posts p 
  ON p.user_id = u.id;


2. Left join: users with or without posts
SELECT 
  u.id,
  u.name,
  p.title
FROM users u
LEFT JOIN posts p 
  ON p.user_id = u.id;

If p.title is NULL, it means that user has no post.

3. Find users with no posts
SELECT 
  u.id,
  u.name
FROM users u
LEFT JOIN posts p 
  ON p.user_id = u.id
WHERE p.id IS NULL;


4. Join 3 tables: users, posts, comments
SELECT 
  u.name AS post_author,
  p.title AS post_title,
  c.body AS comment_body
FROM users u
INNER JOIN posts p 
  ON p.user_id = u.id
INNER JOIN comments c 
  ON c.post_id = p.id;


5. Count posts per user
SELECT 
  u.id,
  u.name,
  COUNT(p.id) AS total_posts
FROM users u
LEFT JOIN posts p 
  ON p.user_id = u.id
GROUP BY u.id, u.name
ORDER BY total_posts DESC;


6. Users with more than 3 posts
SELECT 
  u.id,
  u.name,
  COUNT(p.id) AS total_posts
FROM users u
INNER JOIN posts p 
  ON p.user_id = u.id
GROUP BY u.id, u.name
HAVING COUNT(p.id) > 3;


7. Users who have posts using EXISTS
SELECT 
  u.id,
  u.name
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM posts p
  WHERE p.user_id = u.id
);


8. Users who have no posts using NOT EXISTS
SELECT 
  u.id,
  u.name
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM posts p
  WHERE p.user_id = u.id
);


9. Find duplicate emails
SELECT 
  email,
  COUNT(*) AS duplicate_count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;


10. Remove duplicate emails safely, keeping the oldest user
WITH ranked_users AS (
  SELECT 
    id,
    email,
    ROW_NUMBER() OVER (
      PARTITION BY email
      ORDER BY created_at ASC
    ) AS row_number
  FROM users
)
DELETE FROM users
WHERE id IN (
  SELECT id
  FROM ranked_users
  WHERE row_number > 1
);

Key idea: JOIN connects tables. GROUP BY summarizes. EXISTS checks if related rows exist. ROW_NUMBER() helps safely rank and remove duplicates.

