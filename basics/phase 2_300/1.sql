-- INNER JOIN: USERS WHO HAVE POSTS
SELECT u.id, u.name, p.title FROM users u INNER JOIN posts p ON p.user_id = u.id;

-- LEFT JOIN: USERS WITH OR WITHOUT POSTS
SELECT u.id, u.name, p.title FROM users u LEFT JOIN posts p ON p.user_id = u.id;

-- FIND USERS WITH NO POSTS
SELECT u.id, u.name FROM users u LEFT JOIN posts p ON p.user_id = u.id WHERE p.id IS NULL;

-- JOIN 3 TABLES: USERS, POSTS, COMMENTS

SELECT u.name AS post_author, p.title AS post_title, c.body AS comment_body FROM users u INNER JOIN posts p ON p.user_id = u.id INNER JOIN comments c ON c.post_id = p.id;

-- COUNT POSTS PER USER
SELECT u.id, u.name, COUNT(p.id) AS total_posts FROM users u LEFT JOIN posts p ON p.user_id = u.id GROUP BY u.id, u.name ORDER BY total_posts DESC;

-- USERS WITH MORE THAN 3 POSTS
SELECT u.id, u.name, COUNT(p.id) AS total_posts FROM users u INNER JOIN posts p ON p.user_id = u.id GROUP BY u.id, u.name HAVING COUNT(p.id) > 3;

-- USERS WHO HAVE POSTS USING EXISTS
SELECT u.id, u.name FROM users u WHERE EXISTS (SELECT 1 FROM posts p WHERE p.user_id = u.id);