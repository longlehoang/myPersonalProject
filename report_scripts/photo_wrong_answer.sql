SELECT * FROM USERS WHERE CODE = '00053159'-- OR ID = 1920

SELECT TOP 10 * FROM VISITS WHERE USER_ID = 1920 ORDER BY start_time DESC

SELECT * FROM CUSTOMERS WHERE CODE = '0070002848'

SELECT * FROM Trans_MeasureTransactionSummary WHERE customerid = 41375 ORDER BY LASTUPDATE DESC
--DELETE FROM TRANS_MEASURETRANSACTIONSUMMARY WHERE TRANSACTIONID = '1B6DC0A8-070E-4BB9-9CB2-FE9B231346B9'

SELECT * FROM Customer_photo WHERE USER_ID = 1920 AND PHOTO_TYPE = 2 AND customer_id = 41375
--WHERE MeasureGroupID IN (78,79,80, 81) AND	MeasureItemID = 280
