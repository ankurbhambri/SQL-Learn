/*

https://platform.stratascratch.com/coding/2089-cookbook-recipes/discussion?code_type=1

pairs cte will give this

First_number  Second_number
    0	         1
    2	         3
    4	         5
    6	         7
    8	         9
    10	         11
    12	         13
    14	         15

*/

WITH pairs as (
    select 
        (ROW_NUMBER() OVER (ORDER BY page_number) - 1 ) * 2  AS first_number,
        (ROW_NUMBER() OVER (ORDER BY page_number) - 1 ) * 2 + 1 AS second_number
    from cookbook_titles
)
SELECT
    p.first_number AS left_page_number,
    a.title AS left_title,
    b.title AS right_title
FROM
    pairs p
LEFT JOIN
    cookbook_titles a ON a.page_number = p.first_number
LEFT JOIN
    cookbook_titles b ON b.page_number = p.second_number
ORDER BY
    p.first_number;
