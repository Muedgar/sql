-- inner join: users who have posts
SELECT u.id, u.name, p.title FROM users u INNER JOIN posts p ON p.user_id = u.id;

-- users with or without posts
SELECT u.id, u.name, p.title FROM users u LEFT JOIN posts p ON p.user_id = u.id;

-- find users with no posts
SELECT u.id, u.name FROM users u LEFT JOIN posts p ON p.user_id = u.id. WHERE p.id IS NULL;

-- join 3 tables: users, posts, comments
SELECT u.name AS post_author, p.title AS post_title, c.body AS comment_body FROM users u INNER JOIN posts p ON p.user_id = u.id INNER JOIN comments c ON c.post_id = p.id;

-- count posts per user
SELECT u.id, u.name, COUNT(p.id) AS total_posts FROM users u LEFT JOIN posts p ON p.user_id = u.id GROUP BY u.id, u.name ORDER BY total_posts DESC;