

Dim_Date
- date_id
- date
- day
- week
- month
- quarter
- year

Dim_Location
- location_id
- location_name
- location_city
- location_state
- location_country
- location_zip
- location_latitude
- location_longitude



Dim_Store
- store_id
- store_name
- location_id
- store_established_date (date_id)
- store_status (active, inactive)
- store_sqrt_size


Dim_Product
- prd_id
- prd_name
- prd_des
- prd_category
- prd_sub_category
- prd_price
- prd_manufacturer
- prd_brand
- prd_weight


Dim_promotion
- promotion_id
- promotion_name
- promotion_des
- promotion_start_date
- promotion_end_date
- promotion_discount
- promotion_status


Dim_Customer
- cust_id
- cust_name
- cust_email
- cust_phone
- cust_address
- location_id


Fact_Sales
- sales_id
- date_id
- store_id
- prd_id
- cust_id
- promotion_id
- sales_discount
- sales_tax
- sales_total_amount
- sales_payment_type
- sales_payment_status
- sales_payment_gateway
- sales_qty
- sales_amount




