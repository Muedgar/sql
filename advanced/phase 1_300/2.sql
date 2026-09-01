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

        CASE
            WHEN v_target_percentage >= 150 THEN
                v_performance_level := 'EXCEPTIONAL';
                v_bonus_rate := 0.20;
            
            WHEN v_target_percentage >= 120 THEN
                v_performance_level := 'EXCELLENT';
                v_bonus_rate := 0.15;
            
            WHEN v_target_percentage >= 100 THEN
                v_performance_level := 'GOOD';
                v_bonus_rate := 0.10;
            
            WHEN v_target_percentage >= 80 THEN
                v_performance_level := 'AVERAGE';
                v_bonus_rate := 0.3;
            
            ELSE
                v_performance_level := 'POOR';
                v_bonus_rate := 0;
        END CASE;
        

        -- Mathematical operation 3
        v_base_bonus := employee_record.monthly_salary * v_bonus_rate * employee_record.department_multiplier;

        -- Mathematical operation 4
        v_return_penalty := v_return_amount * 0.05;

        -- GREATEST prevents a negative bonus.
        v_final_bonus := GREATEST(ROUND(v_base_bonus - v_return_penalty, 2), 0);

        -- insert the result. If this employee already has a bonus for the month, update the existing record.
        INSERT INTO employee_bonuses (
            employee_id,
            bonus_month,
            total_sales,
            returned_amount,
            target_percentage,
            performance_level,
            bonus_amount
        )
        VALUES (
            employee_record.id,
            v_month_start,
            v_net_sales,
            v_returned_amount,
            v_target_percentage,
            v_performance_level,
            v_final_bonus
        )
        ON CONFLICT (employee_id, bonus_month)
        DO UPDATE SET
            total_sales = EXCLUDED.total_sales,
            returned_amount = EXCLUDED.returned_amount,
            target_percentage = EXCLUDED.target_percentage,
            performance_level = EXCLUDED.performance_level,
            bonus_amount = EXCLUDED.bonus_amount,
            calculated_at = CURRENT_TIMESTAMP;
        
        RAISE NOTICE
            'Employee: %, sales: %, target: %, performance: %, bonus: %',
            employee_record.name,
            v_net_sales,
            v_target_percentage,
            v_performance_level,
            v_final_bonus;
    END LOOP;

    -- RANK EMPLOYEES INSIDE EACH DEPARTMENT. DENSE_RANK GIVES EQUAL RANKS TO EMPLOYEES WITH EQUAL SALES.
    WITH employee_ranking AS (
        SELECT
            eb.id AS bonus_id,
            DENSE_RANK() OVER (
                PARTITION BY e.department_id
                ORDER BY eb.total_sales DESC
            ) AS calculated_rank
        FROM employee_bonuses eb
        INNER JOIN employees e
            ON e.id = eb.employee_id
        WHERE eb.bonus_month = v_month_start
    )
    UPDATE employee_bonuses eb
    SET department_rank = er.calculated_rank
    FROM employee_ranking er
    WHERE eb.id = er.bonus_id;

    RAISE NOTICE 'Monthly bonus calculation completed.';
END;
$$;

-- CALL THE PROCEDURE
CALL calculate_monthly_bonuses('2026-08-01');