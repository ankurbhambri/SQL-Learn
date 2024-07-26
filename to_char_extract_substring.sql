-- To_Char and Extract

SELECT
  TO_CHAR(TO_DATE('2024-05-27', 'YYYY-MM-DD'), 'Day, DD Month YYYY') AS formatted_date,
  TO_CHAR(TO_DATE('2024-05-27', 'YYYY-MM-DD'), 'Month') AS month_name,
  EXTRACT(YEAR FROM TO_DATE('2024-05-27', 'YYYY-MM-DD')) AS year,
  EXTRACT(MONTH FROM TO_DATE('2024-05-27', 'YYYY-MM-DD')) AS month_number,
  EXTRACT(DAY FROM TO_DATE('2024-05-27', 'YYYY-MM-DD')) AS day


-- To_Char usecases

SELECT
  TO_CHAR(12345.678, '99999.99') AS formatted_number,
  TO_CHAR(12345.678, '$99999.99') AS formatted_currency,
  TO_CHAR(0.678, '99.99%') AS formatted_percentage,
  TO_CHAR(7, '0000') AS formatted_leading_zeros

-- Substring

SELECT
  SUBSTR('example_string', 1, 3) AS first_three_chars,
  SUBSTR('example_string', 12, 3) AS last_three_chars

-- LEFT, RIGHT

SELECT
  LEFT('example_string', 3) AS first_three_chars,
  RIGHT('example_string', 3) AS last_three_chars

