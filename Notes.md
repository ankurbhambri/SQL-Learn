# By default (range between unbounded preceding and current row):
- This means that the frame includes all rows from the beginning of the partition up to the current row, based on the order of the rows by the specified value..

# ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
- This means that the frame includes the current row and the six preceding rows, making a total of 7 rows

# ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
- Includes the current row and the previous row.

# ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
- Includes the current row and the two preceding rows.

# ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
- Includes all rows from the start up to the current row.