-- SR
SELECT p.country,COUNT(DISTINCT c.Code) FROM USERS c 
JOIN [10.0.0.7].CCVN4_REporting.dbo.view_positionorg p ON c.id = p.SalesrepID
JOIN order_headers oh ON oh.user_id = c.id
WHERE oh.confirmed_date > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
AND c.VALID = 1
--AND LEN(c.code) < 15
GROUP BY p.Country

-- SR
SELECT distinct p.*, c.Code, LEFT(v.Mobile_platform,5) FROM USERS c 
JOIN [10.0.0.7].CCVN4_REporting.dbo.view_positionorg p ON c.id = p.SalesrepID
JOIN order_headers oh ON oh.user_id = c.id JOIN Visits v ON oh.visit_id = v.id
WHERE oh.confirmed_date > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
AND c.VALID = 1
--AND LEN(c.code) < 15
--GROUP BY p.*, c.Code,  LEFT(v.Mobile_platform,5)


-- TSM, ASM
SELECT p.country, COUNT(DISTINCT ls.UserCode) TotalTSM
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
JOIN CCVN4_Reporting.dbo.view_positionorg p ON ms.orgid = p.SalesOfficeID
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 90) AS datetime)
AND ms.GroupCode IN ('ASM','TSM')
AND ms.IsActive = 1
GROUP BY p.country
