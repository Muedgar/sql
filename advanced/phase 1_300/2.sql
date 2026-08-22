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

INSERT INTO sales (employee_id, sale_amount, returned, sale_date) VALUES (1, 3000000, FALSE, '2026-08-03'), (1, 2500000, FALSE, '2026-08-10'), (1, 5000000, TRUE, '2026-08-15'), (2, 2000000, FALSE, '2026-08-05'), (2, 1500000, FALSE, '2026-08-18');

CREATE OR REPLACE PROCEDURE calculate_monthly_bonuses(
    p_month DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    employee_record RECORD;
    v_month_start DATE;
    v_month_end DATE;
    v_successful_sales NUMERIC(12, 2);
    v_returned_amount NUMERIC(12, 2);
    v_net_sales NUMERIC(12, 2);
    v_target_percentage NUMERIC(8,2);

    v_performance_level VARCHAR(30);
    v_bonus_rate NUMERIC(5,4);
    v_base_bonus NUMERIC(12,2);
    v_return_penalty NUMERIC(12,2);
    v_final_bonus NUMERIC(12,2);
BEGIN
    v_month_start := DATE_TRUNC('month', p_month)::DATE;

    v_month_end := (v_month_start + INTERVAL '1 month - 1 day')::DATE;

    RAISE NOTICE 'Calculating bonuses from % to %',
        v_month_start,
        v_month_end;

    FOR employee_record IN
        SELECT
            e.id,
            e.name,
            e.monthly_salary,
            e.monthly_target,
            d.department_multiplier
        FROM employees e
        INNER JOIN departments d 
            ON d.id = e.department_id
    LOOP
        SELECT
            COALESCE(
                SUM(sale_amount) FILTER (WHERE returned = FALSE),
                0
            ),
            COALESCE(
                SUM(sale_amount) FILTER (WHERE returned = TRUE),
                0
            )
        INTO
            v_successful_sales,
            v_returned_amount
        FROM sales
        WHERE employee_id = employee_record.id
            AND sale_date BETWEEN v_month_start AND v_month_end;

        v_net_sales := v_successful_sales - v_returned_amount;

        IF employee_record.monthly_target <= 0 THEN
            RAISE WARNING
                'Employee % has an invalid target. Percentage set to zero.',
                employee_record.name;

            v_target_percentage := 0;
        ELSE
            v_target_percentage := ROUND(
                (v_net_sales / employee_record.monthly_target) * 100,
                2
            );
        END IF;