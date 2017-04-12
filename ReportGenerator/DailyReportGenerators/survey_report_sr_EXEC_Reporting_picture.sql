USE CCVN_iMentor;

DELETE [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_REDSurvey];

INSERT INTO [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_REDSurvey]
SELECT 	CONVERT(VARCHAR, TS.LastUpdate, 120) CreatedDate, ISNULL(po.country,'NULL') country, ISNULL(po.countryID,'NULL') countryID, ISNULL(po.company,'NULL') company, ISNULL(po.companyID,'NULL') companyID, ISNULL(po.salesOrg,'NULL') salesOrg, ISNULL(po.salesOrgID,'NULL') salesOrgID
		, ISNULL(po.RegionManager,'NULL') RegionManager, ISNULL(po.SalesManager,'NULL') SalesManager, ISNULL(po.salesOffice,'NULL') salesOffice, ISNULL(po.salesOfficeID,'NULL') salesOfficeID, ISNULL(po.AreaCode,'NULL') AreaCode, ISNULL(po.AreaManager,'NULL') AreaManager, ISNULL(po.TerritorySalesManager,'NULL') TerritorySalesManager, ISNULL(po.salesRep,'NULL') salesRep
		, ISNULL(po.salesRepCode,'NULL') salesRepCode, ISNULL(po.salesRepID,'NULL') salesRepID, ISNULL(po.salesRep,'NULL') CreatorName, ISNULL(U.Code,'NULL') CreatorCode, 'SR/DSR' CreatorRole
		, LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
		, ISNULL(C.Code,'NULL') CustomerCode
		, ISNULL(MP.Name,'NULL') ProfileName, ISNULL(MG.Title,'NULL') GroupName, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(MI.ItemTitle, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemName
		, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(MI.ItemContent, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemContent
		, CCVN4_Reporting.dbo.[GET_OPTIONVALUE](TD.ItemValue) ItemValue, CAST(TD.Score AS VARCHAR) ItemScore, CAST(TS.Score AS VARCHAR) TotalScore
		, CASE WHEN CP.ID IS NULL THEN 'NULL' ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' END PictureLink
		, CASE WHEN CP.ID IS NULL THEN 'NULL' ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/PhotoView.aspx?id=' + CP.ID + '")' END PictureMetadataLink
		, CASE WHEN CP.ID IS NULL THEN 'NULL' ELSE LTRIM(RTRIM(replace(REPLACE(REPLACE(CP.PHOTO_REMARK, CHAR(13), ''), CHAR(10), ''),',',';'))) END PhotoRemark
		, ISNULL(po.salesRepEmail,'NULL') salesRepEmail, ISNULL(po.TSMCode,'NULL') TSMCode, ISNULL(po.TSMEmail,'NULL') TSMEmail, ISNULL(po.ASMEmail,'NULL'), ISNULL(cc.CHAINS_NAME,'x') AS Distributor,  ISNULL(cc.CHAINS_CODE,'x') as DistributorCode 
		, LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerAddress
		, CASE WHEN c.customer_type = '07' THEN 'RED NEW' ELSE 'NULL' END IsREDNew
FROM (
		SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking
		FROM Trans_MeasureTransactionSummary TranS
		WHERE  (
				(DATENAME(dw,GETDATE())='Monday' AND TranS.LastUpdate >= CAST(GETDATE() - 2 AS DATE))
				OR (DATENAME(dw,GETDATE())<>'Monday' AND TranS.LastUpdate >= CAST(GETDATE() - 1 AS DATE))
		  )
		  AND TranS.LastUpdate < CAST(GETDATE() AS DATE)
	) TS
	INNER JOIN Trans_MeasureTransactionDetail TD 			ON TS.TransactionId=TD.TransactionId
	INNER JOIN [10.0.0.6].CCVN4.dbo.Users U 				ON TS.UserID=U.id
	INNER JOIN CCVN4_Reporting.dbo.Customers C 				ON TS.CustomerID=C.ID
	INNER JOIN [10.0.0.6].CCVN4.dbo.Users U2 				ON TS.LastUpdateBy=U2.Code
	INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureProfile MP 	ON TS.MeasureProfileId=MP.ID 
	INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureGroup MG 	ON TD.MeasureGroupId=MG.Id
	INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureItem MI 		ON TD.ItemId=MI.ID
	LEFT JOIN CCVN4_Reporting.dbo.View_PositionOrg po 		ON po.SalesRepID = TS.UserID
	LEFT JOIN CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc 		ON c.id=cc.customer_id
	LEFT JOIN CCVN4_Reporting.dbo.Customer_Photo CP 		ON CP.MeasureItemId = MI.ID
																AND CP.MeasureProfileID = MP.id
																AND CP.MeasureGroupId = MG.ID
																AND CP.User_Id = u.id
																AND CP.customer_id = c.id
																AND CP.visit_Id = ts.visit_id
																AND CP.Photo_type = 2
WHERE MP.ID IN (90,91,92)
	AND TS.Ranking = 1
	AND u.GROUP_ID IN (2,3)
UNION ALL
SELECT DISTINCT	CONVERT(VARCHAR, TS.LastUpdate, 120) CreatedDate, ISNULL(po.country,'NULL') country, ISNULL(po.countryID,'NULL') countryID, ISNULL(po.company,'NULL') company, ISNULL(po.companyID,'NULL') companyID, ISNULL(po.salesOrg,'NULL') salesOrg, ISNULL(po.salesOrgID,'NULL') salesOrgID
		, ISNULL(po.RegionManager,'NULL') RegionManager, ISNULL(po.SalesManager,'NULL') SalesManager, ISNULL(po.salesOffice,'NULL') salesOffice, ISNULL(po.salesOfficeID,'NULL') salesOfficeID, ISNULL(po.AreaCode,'NULL') AreaCode, ISNULL(po.AreaManager,'NULL') AreaManager, ISNULL(po.TerritorySalesManager,'NULL') TerritorySalesManager, ISNULL(po.salesRep,'NULL') salesRep
		, ISNULL(po.salesRepCode,'NULL') salesRepCode, ISNULL(po.salesRepID,'NULL') salesRepID, ISNULL(po.salesRep,'NULL') CreatorName, ISNULL(U.Code,'NULL') CreatorCode, 'SR/DSR' CreatorRole
		, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
		, ISNULL(C.Code,'NULL') CustomerCode, ISNULL(MP.Name,'NULL') ProfileName, ISNULL(MG.Title,'NULL') GroupName
		, 'NULL' ItemName , 'NULL' ItemContent ,'NULL' ItemValue ,'NULL' ItemScore,TS.Score TotalScore
		, CASE WHEN CP.ID IS NULL THEN 'NULL' ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' END PictureLink
		, CASE WHEN CP.ID IS NULL THEN 'NULL' ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/PhotoView.aspx?id=' + CP.ID + '")' END PictureMetadataLink
		, CASE WHEN CP.ID IS NULL THEN 'NULL' ELSE LTRIM(RTRIM(replace(REPLACE(REPLACE(CP.PHOTO_REMARK, CHAR(13), ''), CHAR(10), ''),',',';'))) END PhotoRemark
		, ISNULL(po.salesRepEmail,'NULL') salesRepEmail, ISNULL(po.TSMCode,'NULL') TSMCode, ISNULL(po.TSMEmail,'NULL') TSMEmail, ISNULL(po.ASMEmail,'NULL'), ISNULL(cc.CHAINS_NAME,'x') AS Distributor,  ISNULL(cc.CHAINS_CODE,'x') as DistributorCode 
		, LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerAddress
		, CASE WHEN c.customer_type = '07' THEN 'RED NEW' ELSE 'NULL' END IsREDNew
FROM (	SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking
		FROM Trans_MeasureTransactionSummary TranS
		WHERE (
				(DATENAME(dw,GETDATE())='Monday' AND TranS.LastUpdate >= CAST(GETDATE() - 2 AS DATE))
				OR (DATENAME(dw,GETDATE())<>'Monday' AND TranS.LastUpdate >= CAST(GETDATE() - 1 AS DATE))
		  )
		  AND TranS.LastUpdate < CAST(GETDATE() AS DATE)
		) TS
		INNER JOIN Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
		INNER JOIN [10.0.0.6].CCVN4.dbo.Users U ON TS.UserID=U.id
		INNER JOIN CCVN4_Reporting.dbo.Customers C ON TS.CustomerID=C.ID
		INNER JOIN [10.0.0.6].CCVN4.dbo.Users U2 ON TS.LastUpdateBy=U2.Code
		INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
		INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
		INNER JOIN CCVN4_Reporting.dbo.Customer_Photo CP 
			ON CP.MeasureProfileID = MP.id
			AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.id AND cp.customer_id = c.id AND CP.visit_Id = ts.visit_id
			AND CP.Photo_type = 2 --AND CP.MeasureItemId IS NULL
		LEFT JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = TS.UserID
		LEFT join  CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id													
WHERE MP.ID IN (90,91,92)
AND TS.Ranking = 1
AND u.GROUP_ID IN (2,3)
ORDER BY 3,5,7,11,19,23,22,24,25