 /*

 The following schema is a subset of a relational database of a grocery store
 chain. This chain sells many products of different product classes to its
 customers across its different stores. It also conducts many different
 promotion campaigns.
 
 The relationship between the four tables we want to analyze is depicted below:
 
       # sales                                # products
       +------------------+---------+         +---------------------+---------+
       | product_id       | INTEGER |>--------| product_id          | INTEGER |
       | store_id         | INTEGER |    +---<| product_class_id    | INTEGER |
       | customer_id      | INTEGER |    |    | brand_name          | VARCHAR |
  +---<| promotion_id     | INTEGER |    |    | product_name        | VARCHAR |
  |    | store_sales      | DECIMAL |    |    | is_low_fat_flg      | TINYINT |
  |    | store_cost       | DECIMAL |    |    | is_recyclable_flg   | TINYINT |
  |    | units_sold       | DECIMAL |    |    | gross_weight        | DECIMAL |
  |    | transaction_date | DATE    |    |    | net_weight          | DECIMAL |
  |    +------------------+---------+    |    +---------------------+---------+
  |                                      |
  |    # promotions                      |    # product_classes
  |    +------------------+---------+    |    +---------------------+---------+
  +----| promotion_id     | INTEGER |    +----| product_class_id    | INTEGER |
       | promotion_name   | VARCHAR |         | product_subcategory | VARCHAR |
       | media_type       | VARCHAR |         | product_category    | VARCHAR |
       | cost             | DECIMAL |         | product_department  | VARCHAR |
       | start_date       | DATE    |         | product_family      | VARCHAR |
       | end_date         | DATE    |         +---------------------+---------+
       +------------------+---------+

 Question 1

 -- What percent of all products in the grocery chain's catalog
 -- are both low fat and recyclable?
 

 EXPECTED OUTPUT:
 Note: Please use the column name(s) specified in the expected output in your solution.
 +----------------------------+
 | pct_low_fat_and_recyclable |
 +----------------------------+
 |         15.384615384615385 |
 +----------------------------+

Question 2

 -- What are the top five (ranked in decreasing order)
 -- single-channel media types that correspond to the most money
 -- the grocery chain had spent on its promotional campaigns?

 Single Media Channel Types are promotions that contain only one media type.

 EXPECTED OUPTUT:
 Note: Please use the column name(s) specified in the expected output in your solution.
 +---------------------------+------------+
 | single_channel_media_type | total_cost |
 +---------------------------+------------+
 | In-Store Coupon           | 70800.0000 |
 | Street Handout            | 70627.0000 |
 | Radio                     | 60192.0000 |
 | Sunday Paper              | 56994.0000 |
 | Product Attachment        | 50815.0000 |
 +---------------------------+------------+

Question 3

  -- Of sales that had a valid promotion, the VP of marketing
 -- wants to know what % of transactions occur on either
 -- the very first day or the very last day of a promotion campaign.
 
 
 EXPECTED OUTPUT:
 Note: Please use the column name(s) specified in the expected output in your solution.
 +-------------------------------------------------------------+
 | pct_of_transactions_on_first_or_last_day_of_valid_promotion |
 +-------------------------------------------------------------+
 |                                         41.9047619047619048 |
 +-------------------------------------------------------------+


Question 4

-- The CMO is interested in understanding how the sales of different
 -- product families are affected by promotional campaigns.
 -- To do so, for each of the available product families,
 -- show the total number of units sold,
 -- as well as the ratio of units sold that had a valid promotion
 -- to units sold without a promotion,
 -- ordered by increasing order of total units sold.
 
 
 EXPECTED OUTPUT
 Note: Please use the column name(s) specified in the expected output in your solution.
 +----------------+------------------+--------------------------------------------------+
 | product_family | total_units_sold | ratio_units_sold_with_promo_to_sold_without_promo|
 +----------------+------------------+--------------------------------------------------+
 | Drink          |          43.0000 |                           0.79166666666666666667 |
 | Non-Consumable |         176.0000 |                           0.76000000000000000000 |
 | Food           |         564.0000 |                           0.75155279503105590062 |
 +----------------+------------------+--------------------------------------------------+


Question 5

-- The VP of Sales feels that some product categories don't sell
-- and can be completely removed from the inventory.
-- As a first pass analysis, they want you to find what percentage
-- of product categories have never been sold.
 
 EXPECTED OUTPUT:
 Note: Please use the column name(s) specified in the expected output in your solution.
 +-----------------------------------+
 | pct_product_categories_never_sold |
 +-----------------------------------+
 |               13.8888888888888889 |
 +-----------------------------------+

 */


1.

select count(case when is_low_fat_flg = 1 and is_recyclable_flg = 1 then 1 end) * 100.0 / count(*) from products

2. 

select media_type as single_channel_media_type, sum(cost) total_cost 
from promotions where media_type not like '%,%'
group by media_type 
order by 2 desc 
limit 5

3.

select 
      count(case when transaction_date=start_date or transaction_date=end_date then 1 end) * 100.0 / count(*) pct_of_transactions_on_first_or_last_day_of_valid_promotion 
from sales s join promotions p on s.promotion_id=p.promotion_id


4. 

select product_family, sum(units_sold) as total_units_sold,
sum(case when s.promotion_id != 0 then units_sold end) * 1.0 / sum(case when s.promotion_id = 0 then units_sold end) * 1.0 ratio_units_sold_with_promo_to_sold_without_promo 
from sales s join products p on s.product_id=p.product_id
join product_classes pc on pc.product_class_id=p.product_class_id
group by product_family


5.

select
      (tc - count(distinct pc.product_category)) * 100.0 / tc  
from 
      (select count(distinct product_category) tc from product_classes), -- tc
      sales s
join 
      products p on s.product_id=p.product_id 
join 
      product_classes pc on pc.product_class_id=p.product_class_id
