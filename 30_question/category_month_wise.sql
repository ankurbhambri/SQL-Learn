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

