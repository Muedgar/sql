CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_multiplier NUMERIC(5,2) NOT NULL DEFAULT 1.00
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL REFERENCES departments(id),
    monthly_salary NUMERIC(12,2) NOT NULL,
    monthly_target NUMERIC(12,2) NOT NULL
);

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(id),
    sale_amount NUMERIC(12,2) NOT NULL,
    returned BOOLEAN NOT NULL DEFAULT FALSE,
    sale_date DATE NOT NULL
);

CREATE TABLE employee_bonuses (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(id),
    bonus_month DATE NOT NULL,
    total_sales NUMERIC(12,2) NOT NULL,
    returned_amount NUMERIC(12,2) NOT NULL,
    target_percentage NUMERIC(8,2) NOT NULL,
    performance_level VARCHAR(30) NOT NULL,
    bonus_amount NUMERIC(12,2) NOT NULL,
    department_rank INT,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    UNIQUE (employee_id, bonus_month)
);

-- sample data
INSERT INTO departments (name, department_multiplier) VALUES ('Technology', 1.20), ('Marketing', 1.10), ('Retail', 1.00);

INSERT INTO employees (name, department_id, monthly_salary, monthly_target) VALUES ('Alice', 1, 1500000, 5000000), ('Bob', 1, 1200000, 4000000);

