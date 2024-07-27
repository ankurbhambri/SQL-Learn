-- Agregate table data on a daily basis

-- Question:

-- You have to write a query that functions as the SELECT portion of a daily load job into an aggregate table. 

-- You have to use both the demoralised and prior snapshots from aggregate table to solve this. 

-- Hint: full outer join.


/*

-- Create the transactions table
CREATE TABLE transactions (
    row_id SERIAL PRIMARY KEY,
    user_id INT,
    transaction_amount DECIMAL(10, 2),
    transaction_date DATE
);

-- Create the user_activity table
CREATE TABLE user_activity (
    row_id SERIAL PRIMARY KEY,
    user_id INT,
    activity_type VARCHAR(50),
    activity_date DATE
);

-- Create the daily_user_metrics table
CREATE TABLE daily_user_metrics (
    date DATE PRIMARY KEY,
    total_transactions INT,
    total_amount DECIMAL(10, 2),
    activity_count INT
);


-- Insert sample data into transactions
INSERT INTO transactions (user_id, transaction_amount, transaction_date)
VALUES
    (1, 100.00, CURRENT_DATE - INTERVAL '1 day'),
    (2, 150.00, CURRENT_DATE),
    (1, 200.00, CURRENT_DATE),
    (3, 50.00, CURRENT_DATE);

-- Insert sample data into user_activity
INSERT INTO user_activity (user_id, activity_type, activity_date)
VALUES
    (1, 'login', CURRENT_DATE - INTERVAL '1 day'),
    (2, 'post', CURRENT_DATE),
    (1, 'comment', CURRENT_DATE),
    (3, 'like', CURRENT_DATE),
    (2, 'login', CURRENT_DATE);

*/


WITH transaction_summary AS (
    SELECT
        transaction_date AS date,
        COUNT(*) AS total_transactions,
        SUM(transaction_amount) AS total_amount
    FROM
        transactions
    WHERE
        transaction_date = CURRENT_DATE
    GROUP BY
        transaction_date
),
activity_summary AS (
    SELECT
        activity_date AS date,
        COUNT(*) AS activity_count
    FROM
        user_activity
    WHERE
        activity_date = CURRENT_DATE
    GROUP BY
        activity_date
)
INSERT INTO daily_user_metrics (date, total_transactions, total_amount, activity_count)
SELECT
    COALESCE(t.date, a.date) AS date,
    COALESCE(total_transactions, 0) AS total_transactions,
    COALESCE(total_amount, 0) AS total_amount,
    COALESCE(activity_count, 0) AS activity_count
FROM
    transaction_summary t
FULL OUTER JOIN
    activity_summary a ON t.date = a.date;