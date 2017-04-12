/*SELECT ls.UserCode, ms.GroupCode, COUNT(DISTINCT CONVERT (date, DATE) ) iMentorUsageCount
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
AND ms.GroupCode IN ('TSM')
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'V%')
AND ((DATEPART(dw, ls.Date) + @@DATEFIRST) % 7) NOT IN (1)
GROUP BY ls.UserCode, ms.GroupCode
*/
SELECT distinct po.country, po.company, po.salesOrg, po.salesOffice, ms.* FROM [Mas_User] ms JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON ms.orgID = po.salesOfficeID
WHERE 1=1
--AND ms.IsActive = 1
--AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'V%')
--AND ms.GroupCode IN ('TSM')
AND ms.UserCode IN (SELECT DISTINCT ls.UserCode
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
AND ms.GroupCode IN ('TSM')
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'V%')
AND ((DATEPART(dw, ls.Date) + @@DATEFIRST) % 7) NOT IN (1)
GROUP BY ls.UserCode)