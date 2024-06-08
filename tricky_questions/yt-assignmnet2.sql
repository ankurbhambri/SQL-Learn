/*
Table 1: student_list - List of students who attended the Olympiad exam from Google Public School.
Table 2: student_response - The Learn Basics Olympiad is an objective exam, student response for every question was recorded in this table.
5 options ("A', 'B', 'C, 'D' and 'E') are provided for each question
Out of 5 options only "A', 'B', 'C' and D' are the valid options, students can pick E' option when they think they haven't learnt the concept yet.
Table 3: correct_answers - This table has the correct answer for all the questions in math and science.
Table 4: question_paper_code - Since we are dealing with 3 classes and 2 subjects, we are maintaining a separate question paper code for each class and each subject.

OUTPUT_TABLE_COLUMN_NAMES
	Roll_number
	Student_name
	Class
	Section
	School_name
	Math_correct
	Math_wrong
	Math_yet_to_learn
	Math_score
	Math_percentage
	Science_correct
	Science_wrong
	Science_yet_learn
	Science_score
	Science_percentage
*/

with cte as (select
	s.roll_number, 
	x.question_paper_code,
	Sum(case when s.option_marked = c.correct_option then 1 else 0 end),
	Sum(case when s.option_marked = 'e' then 1 else 0 end) yet_to_learn,
	max(x.tc) - (Sum(case when s.option_marked = c.correct_option then 1 else 0 end) + Sum(case when s.option_marked = 'e' then 1 else 0 end)) as wrong,
	ROUND(Sum(case when s.option_marked = c.correct_option then 1 else 0 end) * 100.0 / max(x.tc),2)
	from 
	student_response s 
	join correct_answers c 
	on s.question_paper_code=c.question_paper_code and s.question_number=c.question_number
	join (select question_paper_code, count(question_number) tc from correct_answers group by question_paper_code) x 
	on x.question_paper_code=c.question_paper_code
	where roll_number = 10159
	group by 1, 2
)

-- TODO