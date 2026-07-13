Use PostgreSQL procedural SQL style: DO $$ ... $$.
Assume tables:
users(id, email, status, created_at)
posts(id, user_id, title, status, created_at)
orders(id, user_id, total_amount, status, created_at)


1. Validate email before inserting user
DO $$
DECLARE
    v_email TEXT := 'edgar@example.com';
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM users WHERE email = v_email
    )
    INTO v_exists;

    IF v_exists THEN
        RAISE EXCEPTION 'User with email % already exists', v_email;
    ELSE
        INSERT INTO users (id, email, status, created_at)
        VALUES (gen_random_uuid(), v_email, 'ACTIVE', NOW());
    END IF;
END $$;


2. Count posts before deleting a user
DO $$
DECLARE
    v_user_id UUID := 'USER_UUID_HERE';
    v_post_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_post_count
    FROM posts
    WHERE user_id = v_user_id;

    IF v_post_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete user. User has % posts', v_post_count;
    END IF;

    DELETE FROM users
    WHERE id = v_user_id;
END $$;


3. Guard clause: stop if order amount is invalid
DO $$
DECLARE
    v_user_id UUID := 'USER_UUID_HERE';
    v_amount NUMERIC := -500;
BEGIN
    IF v_amount <= 0 THEN
        RAISE EXCEPTION 'Order amount must be greater than 0';
    END IF;

    INSERT INTO orders (id, user_id, total_amount, status, created_at)
    VALUES (gen_random_uuid(), v_user_id, v_amount, 'PENDING', NOW());
END $$;


4. IF / ELSE: activate or deactivate user
DO $$
DECLARE
    v_user_id UUID := 'USER_UUID_HERE';
    v_current_status TEXT;
BEGIN
    SELECT status
    INTO v_current_status
    FROM users
    WHERE id = v_user_id;

    IF v_current_status = 'ACTIVE' THEN
        UPDATE users
        SET status = 'INACTIVE'
        WHERE id = v_user_id;
    ELSE
        UPDATE users
        SET status = 'ACTIVE'
        WHERE id = v_user_id;
    END IF;
END $$;


5. Loop through inactive users
DO $$
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN
        SELECT id, email
        FROM users
        WHERE status = 'INACTIVE'
    LOOP
        RAISE NOTICE 'Inactive user: % - %', user_record.id, user_record.email;
    END LOOP;
END $$;


6. Archive old pending orders
DO $$
DECLARE
    v_updated_count INT;
BEGIN
    UPDATE orders
    SET status = 'ARCHIVED'
    WHERE status = 'PENDING'
      AND created_at < NOW() - INTERVAL '90 days';

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RAISE NOTICE '% orders archived', v_updated_count;
END $$;


7. Validate user exists before creating post
DO $$
DECLARE
    v_user_id UUID := 'USER_UUID_HERE';
    v_user_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM users WHERE id = v_user_id
    )
    INTO v_user_exists;

    IF NOT v_user_exists THEN
        RAISE EXCEPTION 'Cannot create post. User does not exist';
    END IF;

    INSERT INTO posts (id, user_id, title, status, created_at)
    VALUES (
        gen_random_uuid(),
        v_user_id,
        'My first post',
        'DRAFT',
        NOW()
    );
END $$;


8. Loop and update many posts safely
DO $$
DECLARE
    post_record RECORD;
BEGIN
    FOR post_record IN
        SELECT id, title
        FROM posts
        WHERE status = 'DRAFT'
          AND created_at < NOW() - INTERVAL '30 days'
    LOOP
        UPDATE posts
        SET status = 'ARCHIVED'
        WHERE id = post_record.id;

        RAISE NOTICE 'Archived post: %', post_record.title;
    END LOOP;
END $$;


9. Raise exception if too many rows will be updated
DO $$
DECLARE
    v_rows_to_update INT;
BEGIN
    SELECT COUNT(*)
    INTO v_rows_to_update
    FROM posts
    WHERE status = 'DRAFT';

    IF v_rows_to_update > 100 THEN
        RAISE EXCEPTION 'Too many rows will be updated: %', v_rows_to_update;
    END IF;

    UPDATE posts
    SET status = 'ARCHIVED'
    WHERE status = 'DRAFT';
END $$;


10. Full validation script before inserting order
DO $$
DECLARE
    v_user_id UUID := 'USER_UUID_HERE';
    v_amount NUMERIC := 25000;
    v_user_exists BOOLEAN;
    v_user_status TEXT;
BEGIN
    IF v_amount <= 0 THEN
        RAISE EXCEPTION 'Amount must be greater than zero';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM users WHERE id = v_user_id
    )
    INTO v_user_exists;

    IF NOT v_user_exists THEN
        RAISE EXCEPTION 'User does not exist';
    END IF;

    SELECT status
    INTO v_user_status
    FROM users
    WHERE id = v_user_id;

    IF v_user_status != 'ACTIVE' THEN
        RAISE EXCEPTION 'User is not active. Current status: %', v_user_status;
    END IF;

    INSERT INTO orders (
        id,
        user_id,
        total_amount,
        status,
        created_at
    )
    VALUES (
        gen_random_uuid(),
        v_user_id,
        v_amount,
        'PENDING',
        NOW()
    );

    RAISE NOTICE 'Order created successfully';
END $$;

This phase is where SQL starts feeling like backend logic inside the database: validate first, then act.

