/*

In the given input table, some of the invoice are missing, write a sal query to identify the missing serial no.
As an assumption, consider the serial no with the lowest value to be the first generated invoice and the highest serial
no value to be the last generated

-- Create the table
CREATE TABLE invoices (
    SERIAL_NO INTEGER PRIMARY KEY,
    INVOICE_DATE DATE
);

-- Insert data into the table
INSERT INTO invoices (SERIAL_NO, INVOICE_DATE)
VALUES
    (330115, '2024-03-01'),
    (330120, '2024-03-01'),
    (330121, '2024-03-01'),
    (330122, '2024-03-02'),
    (330125, '2024-03-02');
*/

-- one way using except

select generate_series(min(SERIAL_NO), max(SERIAL_NO)) SERIAL_NO from invoices
except
select SERIAL_NO from invoices order by 1


-- another left join

with cte as (
	select generate_series(min(SERIAL_NO), max(SERIAL_NO)) serial_number, invoice_date from invoices group by invoice_date order by 1
)
select 
	c.serial_number missing_serial_number 
from cte c 
left join invoices i 
on c.serial_number=i.SERIAL_NO 
where i.SERIAL_NO is null
order by 1


-- using recursive method

with recursive cte as(
	select min(SERIAL_NO) n from invoices
	union 
	select (n + 1) as n from cte where n < (select max(SERIAL_NO) from invoices)
)
select * from cte
except
select SERIAL_NO from invoices