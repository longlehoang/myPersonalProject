SELECT po.countryid CountryID, po.country Country, po.salesOrgID SalesRegionID
	 , po.salesOrg SalesRegion, po.RegionManager, po.SalesManager, po.SalesOfficeID
	 , po.SalesOffice, po.AreaManager
	 , po.TSMCode, po.TerritorySalesManager, po.salesRepID RepID, po.salesRepCode RepCode, po.salesRep RepName, c.Code DistributorCode, c.Description DistributorName
FROM View_PositionOrg po
LEFT JOIN USER_CHAINS uc ON po.salesRepID = uc.user_id
LEFT JOIN CHAINS c ON uc.chains_id = c.id
WHERE 1=1 