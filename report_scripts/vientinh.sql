SELECT u.Code RepCode, u.Name RepName, c.Code CustomerCode, LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
, LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Address_Line, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerAddress
, p.code ProductCode, p.Description ProductName,oh.ORDER_NO, oh.Order_Date, ol.Quantity_Confirmed, ol.UNIT_PRICE, ol.LINE_TAX_AMOUNT ,ol.CANCELLED, ol.Confirmed_Date, ol.orderlinestatus
FROM ORDER_HEADERS oh JOIN ORDER_LINES ol ON oh.order_no = ol.order_no AND oh.Confirmed_Date > '1Aug16'
	JOIN Users u on oh.user_id = u.user_id
	JOIN Customers c ON oh.customer_id = c.id
	JOIN Products p ON p.id = ol.product_id
WHERE oh.CHAIN_ID IN (918,1754)


SELECT u.Code RepCode, COUNT(Distinct oh.CUSTOMER_ID)
FROM ORDER_HEADERS oh JOIN ORDER_LINES ol ON oh.order_no = ol.order_no
	JOIN Users u on oh.user_id = u.user_id
	JOIN Customers c ON oh.customer_id = c.id
	JOIN Products p ON p.id = ol.product_id
WHERE oh.CHAIN_ID IN (918,1754)
GROUP BY u.Code

--ORDER BY CHAIN_ID, Confirmed_Date DESC