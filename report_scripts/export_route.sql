SELECT po.SalesOrg,
  po.RegionManager,
  po.SalesManager,
  po.AreaManager,
  po.AreaCode,
  po.TerritorySalesManager TSM,
  po.salesRep,
  po.salesRepCode, c.Code CustomerCode
	 , LTRIM(RTRIM(replace(REPLACE(REPLACE(c.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
	 , LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) CustomerAddress
	 , c.DeliveryType
	 , c.Identity1 Longitude
	 , c.Identity2 Latitude
	 , c.TradeChannel TradeChannelCode
	 , trade.CodeDesc TradeChannel
	 , c.SubTradeChannel SubTradeChannelCode
	 , sub.CodeDesc SubTradeChannel
	 , r.route_number
	 , r.sequence
	 , r.frequence
FROM CUSTOMERS c
JOIN ROUTE_CUSTOMERS r ON r.customer_id = c.id
LEFT JOIN (SELECT * FROM sfaCodeDesc WHERE CodeCategory = 'TradeChannel' AND DeleteFlag = 0 AND CountryID = 144) trade ON trade.codeValue = c.TradeChannel
LEFT JOIN (SELECT * FROM sfaCodeDesc WHERE CodeCategory = 'SubTradeChannel' AND DeleteFlag = 0 AND CountryID = 144) sub ON sub.codeValue = c.SubTradeChannel
JOIN View_PositionOrg po ON c.org_id = po.salesOfficeID AND po.salesRepID = r.user_id
WHERE po.countryid = '8'
AND c.CustomerCategory <> '04'
AND c.valid = 1
AND r.valid = 1
AND r.route_number > 0
ORDER BY 1,2,3,4,5,6,7,8, r.route_number
	 , r.sequence
	 , r.frequence--,17,15,19