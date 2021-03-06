SELECT convert(varchar, TS.LastUpdate, 120) CreatedDate, po.country, po.countryID, po.company, po.companyID, po.salesOrg, po.salesOrgID
, po.RegionManager, po.SalesManager, po.salesOffice, po.salesOfficeID, po.AreaCode, po.AreaManager, po.TerritorySalesManager, po.salesRep
, po.salesRepCode, po.salesRepID 
,po.salesRep CreatorName,U.Code CreatorCode, 'SR/DSR' CreatorRole
													,LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
													,C.Code CustomerCode
                                                    ,MP.Name ProfileName,MG.Title GroupName, LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemTitle, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemName
                                                    ,LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemContent, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemContent
                                                    ,CCVN4.dbo.[GET_OPTIONVALUE](TD.ItemValue) ItemValue
                                                    ,TD.Score ItemScore,TS.Score TotalScore, CASE WHEN CP.ID IS NULL THEN NULL ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' END PictureLink
													, CASE WHEN CP.ID IS NULL THEN NULL ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/PhotoView.aspx?id=' + CP.ID + '")' END PictureMetadataLink
													, CASE WHEN CP.ID IS NULL THEN NULL ELSE LTRIM(RTRIM(replace(REPLACE(REPLACE(CP.PHOTO_REMARK, CHAR(13), ''), CHAR(10), ''),',',';'))) END PhotoRemark
													, po.salesRepEmail, po.TSMCode, po.TSMEmail, po.ASMEmail, isnull(cc.CHAINS_NAME,'x') as Distributor,  isnull(cc.CHAINS_CODE,'x') as DistributorCode 
													, LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerAddress
                                                    , CASE WHEN c.customer_type = '07' THEN 'RED NEW' ELSE NULL END IsREDNew
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate > '2Sep16') TS
                                                    INNER JOIN Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN Users U ON TS.UserID=U.id
                                                    INNER JOIN (SELECT c.*, o.address_line FROM Customers c JOIN CONTACT_INFO o ON c.id = o.customer_id) C ON TS.CustomerID=C.ID
                                                    INNER JOIN Users U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID 
                                                    INNER JOIN Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    INNER JOIN Biz_MeasureItem MI ON TD.ItemId=MI.ID
													LEFT JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = TS.UserID
                                                    LEFT join  [10.0.0.7].CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id
													LEFT JOIN Customer_Photo CP 
														ON CP.MeasureItemId = MI.ID AND CP.MeasureProfileID = MP.id
														AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.id AND cp.customer_id = c.id AND CP.visit_Id = ts.visit_id
														AND CP.Photo_type = 2
WHERE MP.ID IN (60)
AND TS.Ranking = 1
AND u.GROUP_ID IN (2,3)
UNION ALL
SELECT DISTINCT convert(varchar, TS.LastUpdate, 120) CreatedDate, po.country, po.countryID, po.company, po.companyID, po.salesOrg, po.salesOrgID
, po.RegionManager, po.SalesManager, po.salesOffice, po.salesOfficeID, po.AreaCode, po.AreaManager, po.TerritorySalesManager, po.salesRep
, po.salesRepCode, po.salesRepID
, po.salesRep CreatorName,U.Code CreatorCode, 'SR/DSR' CreatorRole
													,LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
													,C.Code CustomerCode
                                                    ,MP.Name ProfileName,MG.Title GroupName, NULL ItemName
                                                    ,NULL ItemContent
                                                    ,NULL ItemValue
                                                    ,NULL ItemScore,TS.Score TotalScore, CASE WHEN CP.ID IS NULL THEN NULL ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' END PictureLink
													, CASE WHEN CP.ID IS NULL THEN NULL ELSE '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/PhotoView.aspx?id=' + CP.ID + '")' END PictureMetadataLink
													, CASE WHEN CP.ID IS NULL THEN NULL ELSE LTRIM(RTRIM(replace(REPLACE(REPLACE(CP.PHOTO_REMARK, CHAR(13), ''), CHAR(10), ''),',',';'))) END PhotoRemark
													, po.salesRepEmail, po.TSMCode, po.TSMEmail, po.ASMEmail
													,isnull(cc.CHAINS_NAME,'x') as Distributor,  isnull(cc.CHAINS_CODE,'x') as DistributorCode
													,LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerAddress
                                                    , CASE WHEN c.customer_type = '07' THEN 'RED NEW' ELSE NULL END IsREDNew
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate > '2Sep16') TS
                                                    INNER JOIN Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN Users U ON TS.UserID=U.id
                                                    INNER JOIN (SELECT c.*, o.address_line FROM Customers c JOIN CONTACT_INFO o ON c.id = o.customer_id) C ON TS.CustomerID=C.ID
                                                    INNER JOIN Users U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
                                                    INNER JOIN Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    INNER JOIN Customer_Photo CP 
														ON CP.MeasureProfileID = MP.id
														AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.id AND cp.customer_id = c.id AND CP.visit_Id = ts.visit_id
														AND CP.Photo_type = 2 --AND CP.MeasureItemId IS NULL
													LEFT JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = TS.UserID
                                                    LEFT join  [10.0.0.7].CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id
													
WHERE MP.ID IN (60)
AND TS.Ranking = 1
AND u.GROUP_ID IN (2,3)
ORDER BY 3,5,7,11,19,23,22,24,25;