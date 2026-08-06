DO $$
DECLARE
    v_email TEXT := 'edgar@example.com';
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM users WHERE email = v_email
    ) INTO v_exists;

    IF v_exists THEN
        RAISE EXCEPTION 'User with email % already exists', v_email;
    ELSE
        INSERT INTO users (id, email, status, created_at)
        VALUES (gen_random_uuid(), v_email, 'ACTIVE', NOW());
    END IF;
END $$;

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

    DELETE FROM users WHERE id = v_user_id;
END $$;

DO $$
DECLARE
    v_user_id UUID := 'USER_UUID_HERE';
    v_amount NUMERIC := -500;
BEGIN