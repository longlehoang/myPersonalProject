SELECT DISTINCT vp.*, c.Code CustomerCode
, LTRIM(RTRIM(replace(REPLACE(REPLACE(c.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
, LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerAddress
, c.TradeChannel, c.SubTradeChannel, DeliveryType, customer_type
, Cooler_Customer, c.REC_USER_CODE, c.REC_TIME_STAMP, c.Last_Update, c.CreateDataTime, rc.frequence RouteFrequence
FROM CUSTOMERS c LEFT JOIN ROUTE_CUSTOMERS rc ON rc.customer_id = c.id
LEFT JOIN View_PositionOrg vp ON vp.SalesRepId = rc.user_id
WHERE c.valid = 1
AND rc.valid = 1
AND rc.frequence = 7
AND vp.countryID = 8
ORDER BY 2,4,6,10
