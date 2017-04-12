--SELECT * FROM order_lines WHERE promotion_ID is not null AND confirmed_date > '1Aug16'
EXEC sp_Calc_Confirm_Promo_Standard '19471609261301081', 82, 523
EXEC sp_Calc_Confirm_Promo_Vietnam '19471609261301081', 82, 523
SELECT * FROM order_headers WHERE order_no = '19471609261301081'
SELECT * FROM order_lines WHERE order_no = '19471609261301081'
SELECT * FROM order_lines_promo WHERE order_no = '19471609261301081'
SELECT * FROM order_promotion_matrixvalue WHERE order_no = '19471609261301081'



