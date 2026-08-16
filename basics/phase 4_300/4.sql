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

DO $$
DECLARE
 v_user_id UUID := 'USER_UUID_HERE';
 v_amount NUMERIC := -500;
BEGIN
    IF v_amount <=0 THEN
        RAISE EXCEPTION 'Order amount must be greater than 0';
    END IF;

    INSERT INTO orders (id, user_id, total_amount, status, created_at)
    VALUES (gen_random_uuid(), v_user_id, v_amount, 'PENDING', NOW());
END $$;

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
        SET status = 'ACTIVE'
        WHERE id = v_user_id;
    END IF;
END $$;

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