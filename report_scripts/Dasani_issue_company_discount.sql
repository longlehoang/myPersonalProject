SELECT * FROM ORDER_HEADERS WHERE ORDER_NO IN ( '29781602151536301','7681602151538411')
SELECT * FROM ORDER_LINES WHERE ORDER_NO IN ( '29781602151536301','7681602151538411')
SELECT * FROM ORDER_LINES_PROMO WHERE  ORDER_NO = '29781602151536301'-- WHERE ID = 130
SELECT * FROM ORDER_PROMOTION_Matrixvalue WHERE  ORDER_NO = '29781602151536301'-- WHERE ID = 130


--UPDATE ORDER_LINES SET SKU_DISC_AMOUNT = -700000.0000 WHERE ORDER_NO IN ('29781602151536301') ---700000.0000
--SELECT TOP 10 * FROM Error_Log ORDER BY CrtDat DESC

SELECT * FROM USERS WHERE ID IN ( 2978,768) OR Managerid = 1347 OR ID = 1947