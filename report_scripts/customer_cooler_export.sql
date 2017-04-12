SELECT distinct po.*
    -- , h.Code DistributorCode
	 --, h.Description DistributorName
	 , c.Code CustomerCode
	 , LTRIM(RTRIM(replace(REPLACE(REPLACE(c.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
	 , LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) CustomerAddress
	 , c.DeliveryType
	 , c.Identity1 Longitude
	 , c.Identity2 Latitude
	 , co.*
FROM CUSTOMERS c
JOIN [10.0.0.6].CCVN4.dbo.CTS_COOLER_MASTER co ON co.customerid = c.id
LEFT JOIN ROUTE_CUSTOMERS r ON r.customer_id = c.id
LEFT JOIN View_PositionOrg po ON po.salesRepID = r.user_id
WHERE c.CustomerCategory <> '04'
AND c.valid = 1
--AND h.valid = 1
--AND co.valid = 1
ORDER BY 2,4,6,8,10,17,15,19