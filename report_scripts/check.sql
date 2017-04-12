SELECT Country, count(*) FROM Order_headers oh JOIN ORGANIZATION_VIEW o ON o.rep_id = oh.user_id WHERE customer_id IN(

SELECT customer_id FROM ORDER_HEADERS WHERE order_date > '2017-02-15 15:35:14.380'
AND NOT Exists  (SELECT 1 FROM order_lines WHERE rec_Time_stamp > '2017-02-15 15:35:14.380' and order_lines.order_no = order_headers.order_no ) 
) AND order_date > '2017-02-15 16:35:14.380'
GROUP BY country