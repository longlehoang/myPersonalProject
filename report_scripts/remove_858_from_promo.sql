SELECT customer_ID FROM customer_chains WHERE chains_id = 858

UPDATE ORDER_PROMOTION_CUSTOMER SET VAlid = 0, rec_user_code = 'Minh 858' WHERE promotion_id NOT IN 
(SELECT ID FROM ORDER_PROMOTION WHERE REC_USER_CODE = 'BOS Interface')
AND customer_id IN (SELECT customer_ID FROM customer_chains WHERE chains_id = 858)
AND valid = 1