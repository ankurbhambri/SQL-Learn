CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product VARCHAR(255),
    region VARCHAR(255),
    amount INT
);

INSERT INTO sales (product, region, amount) VALUES
('Product A', 'North', 100),
('Product A', 'South', 150),
('Product B', 'North', 200),
('Product B', 'South', 250),
('Product C', 'North', 300),
('Product C', 'South', 350);



SELECT *
FROM crosstab(
    'SELECT product, region, amount FROM sales ORDER BY product, region',
    'SELECT DISTINCT region FROM sales ORDER BY region'
) AS ct (product VARCHAR, north INT, south INT);
