SELECT DISTINCT ls.UserCode
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
AND ms.GroupCode IN ('ASM')
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'K%' OR Code LIKE 'H%')
AND ((DATEPART(dw, ls.Date) + @@DATEFIRST) % 7) NOT IN (1)

SELECT * FROM [Mas_User] ms 
WHERE 1=1
AND ms.IsActive = 1
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'K%' OR Code LIKE 'H%')
AND ms.GroupCode IN ('ASM')
AND ms.UserCode NOT IN (SELECT DISTINCT ls.UserCode
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 7) AS datetime)
AND ms.GroupCode IN ('ASM')
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'K%' OR Code LIKE 'H%')
AND ((DATEPART(dw, ls.Date) + @@DATEFIRST) % 7) NOT IN (1))