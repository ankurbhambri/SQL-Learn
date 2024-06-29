# By default (range between unbounded preceding and current row):
- This specifies that the window frame includes all rows from the start of the partition up to and including the current row.

# Explicitly stated (range between unbounded preceding and unbounded following):
- This specifies that the window frame includes all rows from the start of the partition up to the end of the partition, regardless of the current row.