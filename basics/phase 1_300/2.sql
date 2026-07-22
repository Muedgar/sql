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

CREATE TABLE posts (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    published BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE comments (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL,
    user_id UUID NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

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
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user);

CREATE TABLE students (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    student_code VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE teachers (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE classes (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_classes_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

CREATE TABLE student_classes (
    student_id UUID NOT NULL,
    class_id UUID NOT NULL,
    enrolled_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (student_id, class_id),
    CONSTRAINT fk_student_classes_student FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_student_classes_class FOREIGN KEY (class_id) REFERENCES classes(id)
);

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
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_tasks_created_by FOREIGN KEY (created_by) REFERENCES users(id)
)

CREATE TABLE task_assignees (
    task_id UUID NOT NULL,
    user_id UUID NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (task_id, user_id),
    CONSTRAINT fk_task_assignees_task FOREIGN KEY (task_id) REFERENCES tasks(id),
    CONSTRAINT fk_task_assignees_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE task_comments (
    pkid SERIAL PRIMARY KEY,
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL,
    user_id UUID NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT 
);