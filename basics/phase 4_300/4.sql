-- VALIDATE EMAIL BEFORE INSERTING USER
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

-- COUNT POSTS BEFORE DELETING A USER
DO $$
DECLARE
    v_user_id UUID := 'user_uuid_here';
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

-- GUARD CLAUSE: STOP IF ORDER AMOUNT IS INVALID
DO $$
DECLARE
    v_user_id UUID := 'user_uuid_here';
    v_amount NUMERIC := -500;
BEGIN
    IF v_amount <= 0 THEN
        RAISE EXCEPTION 'Order amount must be greater than 0';
    END IF;

    INSERT INTO orders (id, user_id, total_amount, status, created_at)
    VALUES (gen_random_uuid(), v_user_id, v_amount, 'PENDING', NOW());
END $$;

