-- https://platform.stratascratch.com/coding/2088-seat-availability?code_type=1

with cte as (
    select seat_left as left_seat, seat_number as right_seat from theater_seatmap
    union
    select seat_number as left_seat, seat_right as right_seat from theater_seatmap
)
select a.* from cte a
join theater_availability b
on a.left_seat = b.seat_number 
join theater_availability c
on a.right_seat = c.seat_number
where b.is_available = True and c.is_available = True
