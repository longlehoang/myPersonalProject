SELECT p.country, p.countryID, p.company, p.companyID, p.salesOrg,
	   p.salesOrgID, p.RegionManager, p.SalesManager, p.salesOffice,
	   p.salesOfficeID, p.AreaCode, p.AreaManager, p.TerritorySalesManager,
	   p.salesRep, p.salesRepCode, p.salesRepID,
	   cc.CHAINS_CODE DistributorCode,
	   cc.CHAINS_NAME DistributorName,
	   CAST(v.START_TIME AS DATE) VisitDate,
	   MIN(START_TIME) StartTime,
	   MAX(STOP_TIME) EndTime
FROM CCVN4_Reporting.dbo.VIEW_POSITIONORG p
	 INNER JOIN  (SELECT * FROM CCVN4_Reporting.dbo.VISITS WHERE START_TIME BETWEEN '25FEB17' AND '1APR17') v
			ON v.user_id = p.salesRepID
	 INNER JOIN CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc ON cc.CUSTOMER_ID = V.CUSTOMER_ID
where p.COUNTRYID = 8 -- Vietnam
group by p.country, p.countryID, p.company, p.companyID, p.salesOrg,
		 p.salesOrgID, p.RegionManager, p.SalesManager, p.salesOffice,
		 p.salesOfficeID, p.AreaCode, p.AreaManager, p.TerritorySalesManager,
	     p.salesRep, p.salesRepCode, p.salesRepID,
		 CAST(v.START_TIME AS DATE),
		 cc.CHAINS_CODE,
		 cc.CHAINS_NAME
order by p.salesRepID,
		 p.salesRep,
		 CAST(v.START_TIME AS DATE)
;