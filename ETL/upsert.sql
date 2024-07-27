/*
Upsert is a combination of "update" and "insert," allowing you to insert a row into a table or update it if it already exists. 
In PostgreSQL, this operation is achieved using the INSERT ... ON CONFLICT statement. Here's a step-by-step guide on how to use upsert in PostgreSQL:


INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...)
ON CONFLICT (conflict_column)
DO UPDATE SET column1 = value1, column2 = value2, ...;


*/


CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    last_login TIMESTAMP
);


INSERT INTO users (username, email, last_login)
VALUES ('john_doe', 'john@example.com', CURRENT_TIMESTAMP)
ON CONFLICT (username, email) 
DO UPDATE SET
    last_login = EXCLUDED.last_login;
WHERE users.last_login < EXCLUDED.last_login; -- This ensures that the last_login is updated only if the new value is more recent than the existing value.


