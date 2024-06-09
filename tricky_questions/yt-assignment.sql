/*
select * from users
select * from batches
select * from student_batch_maps
select * from instructor_batch_maps
select * from sessions
select * from attendances
select * from tests
select * from test_scores

** Using the above table schema, please write the following queries. To test your queries, you can use some dummy data.

1.Calculate the average rating given by students to each teacher for each session created. Also, provide the batch name for which session was conducted.

2.Find the attendance percentage  for each session for each batch. Also mention the batch name and users name who has conduct that session

3.What is the average marks scored by each student in all the tests the student had appeared?

4.A student is passed when he scores 40 percent of total marks in a test. Find out how many students passed in each test. Also mention the batch name for that test.

5.A student can be transferred from one batch to another batch. If he is transferred from batch a to batch b. batch b’s active=true and batch a’s active=false in student_batch_maps.
 At a time, one student can be active in one batch only. One Student cannot be transferred more than four times. Calculate each students attendance percentage for all the sessions created for his past batch. Consider only those sessions for which he was active in that past batch.

Note - Data is not provided for these tables, you can insert some dummy data if required.

6. What is the average percentage of marks scored by each student in all the tests the student had appeared?

7. A student is passed when he scores 40 percent of total marks in a test. Find out how many percentage of students have passed in each test. Also mention the batch name for that test.

8. A student can be transferred from one batch to another batch. If he is transferred from batch a to batch b. batch b’s active=true and batch a’s active=false in student_batch_maps.
    At a time, one student can be active in one batch only. One Student can not be transferred more than four times.
    Calculate each students attendance percentage for all the sessions.

*/

-- TODO