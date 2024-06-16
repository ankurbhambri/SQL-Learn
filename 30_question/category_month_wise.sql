/*
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    category VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_date DATE NOT NULL
);

INSERT INTO transactions (category, amount, transaction_date) VALUES
('Electronics', 150.00, '2024-01-15'),
('Groceries', 50.00, '2024-01-20'),
('Electronics', 200.00, '2024-02-10'),
('Clothing', 75.00, '2024-02-15'),
('Groceries', 100.00, '2024-03-05'),
('Clothing', 125.00, '2024-03-10');

*/

-- In this query, we are using the CASE statement to sum the amount for each month wise.

SELECT 
    category,
    SUM(CASE WHEN Extract(month from transaction_date) = 1 THEN amount ELSE 0 END) AS January,
    SUM(CASE WHEN Extract(month from transaction_date) = 2 THEN amount ELSE 0 END) AS Feburary,
    SUM(CASE WHEN Extract(month from transaction_date) = 3 THEN amount ELSE 0 END) AS March,
    SUM(CASE WHEN Extract(month from transaction_date) = 4 THEN amount ELSE 0 END) AS April,
    SUM(CASE WHEN Extract(month from transaction_date) = 5 THEN amount ELSE 0 END) AS May,
    SUM(CASE WHEN Extract(month from transaction_date) = 6 THEN amount ELSE 0 END) AS June,
    SUM(CASE WHEN Extract(month from transaction_date) = 7 THEN amount ELSE 0 END) AS July,
    SUM(CASE WHEN Extract(month from transaction_date) = 8 THEN amount ELSE 0 END) AS August,
    SUM(CASE WHEN Extract(month from transaction_date) = 9 THEN amount ELSE 0 END) AS September,
    SUM(CASE WHEN Extract(month from transaction_date) = 10 THEN amount ELSE 0 END) AS October,
    SUM(CASE WHEN Extract(month from transaction_date) = 11 THEN amount ELSE 0 END) AS November,
    SUM(CASE WHEN Extract(month from transaction_date) = 12 THEN amount ELSE 0 END) AS December
FROM 
    transactions
GROUP BY 
    category
ORDER BY 
    category;



/*
CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    movie_genre VARCHAR(255) NOT NULL
);

INSERT INTO movies (name, movie_genre) VALUES
('Movie1', 'Action,Drama'),
('Movie2', 'Comedy,Action'),
('Movie3', 'Drama,Romance'),
('Movie4', 'Action,Comedy,Drama'),
('Movie5', 'Horror,Thriller'),
('Movie6', 'Comedy,Romance'),
('Movie7', 'Action,Thriller');
*/

-- Here, we are using the unnest() function to split the movie_genre column into multiple rows and then counting the number of movies for each genre.

SELECT 
    unnest(string_to_array(movie_genre, ',')) AS genre, 
    COUNT(1) AS movie_count 
FROM 
    movies 
GROUP BY 
    1 
ORDER BY 
    2 DESC;
