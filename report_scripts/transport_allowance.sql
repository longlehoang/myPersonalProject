WITH visit AS (SELECT ID
					, START_TIME
					, longitude
					, latitude
					, user_id
					, Rank() over (Partition BY CONVERT(date, START_TIME), user_id ORDER BY START_TIME) AS Rank
FROM VISITS WHERE 1=1-- USER_ID IN (933,1947,1236)
AND LONGITUDE + LATITUDE <> 0
AND LONGITUDE <> 106.6828
AND LATITUDE <> 10.7754
AND START_TIME BETWEEN '1-Oct-2015' AND '29-Jan-2016')

SELECT po.country, po.countryID, po.company, po.companyID, po.salesOrg, po.salesOrgID, po.RegionManager, po.SalesManager, po.salesOffice, po.salesOfficeID, po.AreaCode, po.AreaManager, po.TerritorySalesManager, po.salesRep, po.salesRepCode, po.salesRepID 
	 , SUM((rs.DailyDistance * rs.TotalVisit)/rs.TotalGoodVisit )/COUNT(*) AverageDistance
FROM (
	SELECT res.VISIT_DATE
		 , res.USER_ID
		 , SUM(res.Distance) DailyDistance
		 , COUNT(*) + 1 TotalGoodVisit
		 , v.TotalVisit FROM (
		SELECT CONVERT(date, v1.START_TIME) VISIT_DATE
			 , v1.USER_ID
			 , CASE WHEN v1.latitude IS NULL THEN 0 ELSE geography::Point(v1.latitude,v1.LONGITUDE, 4326).STDistance(geography::Point(v2.latitude,v2.LONGITUDE, 4326)) END Distance
		FROM visit v1 JOIN visit v2 ON v1.USER_ID = v2.USER_ID AND CONVERT(date, v1.START_TIME) = CONVERT(date, v2.START_TIME) AND v1.Rank + 1 = v2.Rank
		) res JOIN (SELECT CONVERT(date, START_TIME) VISIT_DATE, USER_ID, COUNT(*) TotalVisit FROM VISITS WHERE START_TIME BETWEEN '1-Oct-2015' AND '29-Jan-2016' GROUP BY CONVERT(date, START_TIME), USER_ID) v ON  v.USER_ID = res.USER_ID AND v.VISIT_DATE = res.VISIT_DATE
	WHERE res.Distance < 2000 --max_distance
	AND res.Distance > 0
	GROUP BY res.USER_ID, res.VISIT_DATE, v.TotalVisit
	HAVING COUNT(*) > 10
	) rs
	JOIN View_PositionOrg po ON rs.USER_ID = po.salesRepID
	GROUP BY po.country, po.countryID, po.company, po.companyID, po.salesOrg, po.salesOrgID, po.RegionManager, po.SalesManager, po.salesOffice, po.salesOfficeID, po.AreaCode, po.AreaManager, po.TerritorySalesManager, po.salesRep, po.salesRepCode, po.salesRepID 
	ORDER BY po.country, po.countryID, po.company, po.companyID, po.salesOrg, po.salesOrgID, po.RegionManager, po.SalesManager, po.salesOffice, po.salesOfficeID, po.AreaCode, po.AreaManager, po.TerritorySalesManager, po.salesRep, po.salesRepCode, po.salesRepID 