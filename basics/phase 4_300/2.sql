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

