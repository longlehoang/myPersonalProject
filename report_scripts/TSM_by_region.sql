SELECT DISTINCT cast(floor(cast(ls.Date AS float)) AS datetime) UsageDate, og.Name Region, ms.GroupCode, ms.UserCode, ms.FirstName, ms.LastName
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
JOIN Mas_Organization og ON og.id = ms.OrgId
--JOIN [CCVN4_Reporting].dbo.View_PositionOrg po ON po.TSMCode = ms.UserCode
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 7) AS datetime)
AND ms.GroupCode IN ('TSM', 'ASM')
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'V%')
AND ((DATEPART(dw, ls.Date) + @@DATEFIRST) % 7) NOT IN (1)