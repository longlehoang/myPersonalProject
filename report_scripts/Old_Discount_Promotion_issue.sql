SELECT * FROM ORDER_LINES WHERE ORDER_NO IN ('10471602121647151','19471602152001021')
SELECT * FROM ORDER_PROMOTION_DiscValue WHERE  ORDER_NO IN ( '10471602121647151', '19471602152001021')-- WHERE ID = 130

--UPDATE ORDER_LINES SET LINE_DISC_AMOUNT = 780000.0000, LINE_DISC_RATE = 5500.00 WHERE ORDER_NO IN ('10471602121647151')
--UPDATE ORDER_PROMOTION SET END_TIME = '15-Feb-2016', VALID = 0 WHERE ID = 130