SELECT DISTINCT po.*
     , c.Code CustomerCode
	 , LTRIM(RTRIM(replace(REPLACE(REPLACE(c.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
	 , LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) CustomerAddress
	 , c.DeliveryType
	 , c.Identity1 Longitude
	 , c.Identity2 Latitude
	 , c.TradeChannel TradeChannelCode
	 , trade.CodeDesc TradeChannel
	 , c.SubTradeChannel SubTradeChannelCode
	 , sub.CodeDesc SubTradeChannel
	 , co.*
FROM CUSTOMERS c
JOIN ROUTE_CUSTOMERS r ON r.customer_id = c.id
JOIN [10.0.0.6].CCVN4.dbo.CTS_COOLER_MASTER co ON co.customerid = c.id
LEFT JOIN (SELECT * FROM sfaCodeDesc WHERE CodeCategory = 'TradeChannel' AND DeleteFlag = 0 AND CountryID = 144) trade ON trade.codeValue = c.TradeChannel
LEFT JOIN (SELECT * FROM sfaCodeDesc WHERE CodeCategory = 'SubTradeChannel' AND DeleteFlag = 0 AND CountryID = 144) sub ON sub.codeValue = c.SubTradeChannel
JOIN View_PositionOrg po ON c.org_id = po.salesOfficeID AND po.salesRepID = r.user_id
WHERE po.countryid = '144'
AND c.CustomerCategory <> '04'
AND c.valid = 1
AND co.valid = 1
ORDER BY 2,4,6,8,10--,17,15,19