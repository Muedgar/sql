SELECT u.id, u.name, p.title FROM users u INNER JOIN posts p ON p.user_id = u.id;

SELECT u.id, u.name, p.title FROM users u LEFT JOIN posts p ON p.user_id = u.id;

SELECT u.id, u.name FROM users u LEFT JOIN posts p ON p.user_id = u.id, WHERE p.id IS NULL;

SELECT u.name AS post_author, p.title AS post_title, c.body AS comment_body FROM users u INNER JOIN posts p ON p.user_id = u.id INNER JOIN comments c ON c.post_id = p.id;

SELECT u.id, u.name, COUNT(p.id) AS total_posts FROM users u LEFT JOIN posts p ON p.user_id = u.id GROUP BY u.id, u.name ORDER BY total_posts DESC;

SELECT u.id, u.name, COUNT(p.id) AS total_posts FROM users u INNER JOIN posts p ON p.user_id = u.id GROUP BY u.id, u.name HAVING COUNT(p.id) > 3;

SELECT u.id, u.name FROM users u WHERE EXISTS (SELECT 1 FROM posts p WHERE p.user_id = u.id);

SELECT u.id, u.name FROM users u WHERE NOT EXISTS (SELECT 1 FROM posts p WHERE p.user_id = u.id);

SELECT email, COUNT(*) AS duplicate_count FROM users GROUP BY email HAVING COUNT(*) > 1;

WITH ranked_users AS (SELECT id, email, ROW_NUMBER() OVER (PARTITION BY email ORDER BY created_at ASC) AS row_number FROM users) DELETE FROM users WHERE id IN (SELECT id FROM ranked_users WHERE row_number > 1);
