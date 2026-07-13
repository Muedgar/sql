Below are 10 intermediate → hard practical schema-design problems for Phase 1.
Using PostgreSQL style SQL.

1. Design a production users table
Problem: Create a users table with UUID, unique email, nullable names, status, user type, and timestamps.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_type_enum AS ENUM ('SYSTEM_USER', 'GUEST');

CREATE TABLE users (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    first_name VARCHAR(200),
    last_name VARCHAR(200),

    email VARCHAR(150) UNIQUE NOT NULL,
    phone_number VARCHAR(50) UNIQUE,

    password_hash TEXT NOT NULL,

    user_type user_type_enum NOT NULL DEFAULT 'GUEST',
    status BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);


2. Design posts linked to users
Problem: One user can create many posts.
CREATE TABLE posts (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,

    published BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_posts_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

One-to-many idea:
One user → many posts
One post → belongs to one user


3. Design comments linked to users and posts
Problem: A user can comment on many posts. A post can have many comments.
CREATE TABLE comments (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    post_id UUID NOT NULL,
    user_id UUID NOT NULL,

    body TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_comments_post
        FOREIGN KEY (post_id)
        REFERENCES posts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);


4. Design roles and user_roles junction table
Problem: A user can have many roles, and a role can belong to many users.
CREATE TABLE roles (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY (user_id, role_id),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE
);

Many-to-many idea:
One user → many roles
One role → many users


5. Add indexes for faster searching
Problem: Add indexes to commonly searched columns.
CREATE INDEX idx_users_email ON users(email);

CREATE INDEX idx_posts_user_id ON posts(user_id);

CREATE INDEX idx_posts_created_at ON posts(created_at);

CREATE INDEX idx_comments_post_id ON comments(post_id);

CREATE INDEX idx_comments_user_id ON comments(user_id);

Indexes matter because they help the database find rows faster without scanning the whole table.

6. Design a normalized school schema
Problem: Students, teachers, classes, and enrollments.
CREATE TABLE students (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    student_code VARCHAR(50) UNIQUE NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE teachers (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    email VARCHAR(150) UNIQUE NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE classes (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    teacher_id UUID NOT NULL,

    name VARCHAR(100) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_classes_teacher
        FOREIGN KEY (teacher_id)
        REFERENCES teachers(id)
);

CREATE TABLE student_classes (
    student_id UUID NOT NULL,
    class_id UUID NOT NULL,

    enrolled_at TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY (student_id, class_id),

    CONSTRAINT fk_student_classes_student
        FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_student_classes_class
        FOREIGN KEY (class_id)
        REFERENCES classes(id)
        ON DELETE CASCADE
);


7. Design a task management schema
Problem: Users create tasks. Tasks can have assignees and comments.
CREATE TYPE task_status_enum AS ENUM (
    'TODO',
    'IN_PROGRESS',
    'DONE',
    'CANCELLED'
);

CREATE TABLE tasks (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    created_by UUID NOT NULL,

    title VARCHAR(255) NOT NULL,
    description TEXT,

    status task_status_enum NOT NULL DEFAULT 'TODO',
    due_date DATE,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_tasks_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
);

CREATE TABLE task_assignees (
    task_id UUID NOT NULL,
    user_id UUID NOT NULL,

    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY (task_id, user_id),

    CONSTRAINT fk_task_assignees_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_task_assignees_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE task_comments (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    task_id UUID NOT NULL,
    user_id UUID NOT NULL,

    body TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_task_comments_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_task_comments_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);


8. Design a finance schema
Problem: Users have accounts. Accounts have transactions.
CREATE TYPE transaction_type_enum AS ENUM (
    'DEPOSIT',
    'WITHDRAWAL',
    'TRANSFER'
);

CREATE TABLE accounts (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    account_number VARCHAR(50) UNIQUE NOT NULL,
    balance NUMERIC(12, 2) NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_accounts_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);

CREATE TABLE transactions (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    account_id UUID NOT NULL,

    transaction_type transaction_type_enum NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,

    description TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(id),

    CONSTRAINT chk_transaction_amount_positive
        CHECK (amount > 0)
);


9. Add data integrity rules
Problem: Prevent bad finance data.
ALTER TABLE accounts
ADD CONSTRAINT chk_account_balance_not_negative
CHECK (balance >= 0);

ALTER TABLE transactions
ADD CONSTRAINT chk_transaction_amount_not_zero
CHECK (amount > 0);

ALTER TABLE users
ADD CONSTRAINT chk_email_format
CHECK (email LIKE '%@%');

Data integrity means the database protects itself from bad data.

10. Design a small normalized blog schema from scratch
Problem: Users can write posts. Posts can have many tags. Users can comment.
CREATE TABLE blog_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE blog_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    author_id UUID NOT NULL,

    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_blog_posts_author
        FOREIGN KEY (author_id)
        REFERENCES blog_users(id)
        ON DELETE CASCADE
);

CREATE TABLE blog_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    post_id UUID NOT NULL,
    user_id UUID NOT NULL,

    body TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_blog_comments_post
        FOREIGN KEY (post_id)
        REFERENCES blog_posts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_blog_comments_user
        FOREIGN KEY (user_id)
        REFERENCES blog_users(id)
        ON DELETE CASCADE
);

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE post_tags (
    post_id UUID NOT NULL,
    tag_id UUID NOT NULL,

    PRIMARY KEY (post_id, tag_id),

    CONSTRAINT fk_post_tags_post
        FOREIGN KEY (post_id)
        REFERENCES blog_posts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_post_tags_tag
        FOREIGN KEY (tag_id)
        REFERENCES tags(id)
        ON DELETE CASCADE
);

The real skill here: every table should represent one clear thing, and relationships should be handled using foreign keys or junction tables.


