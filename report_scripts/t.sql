SELECT TOP 100 * FROM (SELECT convert(varchar, TS.LastUpdate, 120) CreatedDate,U.Code CreatorCode, 'SR/DSR' CreatorRole
													,LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
													,C.Code CustomerCode
                                                    ,MP.Name ProfileName,MG.Title GroupName, LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemTitle, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemName
                                                    ,LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemContent, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemContent
                                                    ,CCVN4.dbo.[GET_OPTIONVALUE](TD.ItemValue) ItemValue
                                                    ,TD.Score ItemScore,TS.Score TotalScore, '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' PictureLink
													,TS.Ranking
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate BETWEEN '03Mar2016' AND '04-Mar-2016') TS
                                                    INNER JOIN Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN Users U ON TS.UserID=U.ID
                                                    INNER JOIN Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN Users U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
                                                    INNER JOIN Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    INNER JOIN Biz_MeasureItem MI ON TD.ItemId=MI.ID
                                                    LEFT JOIN Customer_Photo CP ON CP.MeasureProfileID = MP.id AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.ID AND customer_id = c.id AND CP.visit_Id = ts.visit_id
WHERE 1=1
--AND MP.ID IN (19,21)
AND TS.Ranking = 1
--AND u.MobileUser =1
AND c.org_id = 141
AND cp.id IS NOT NULL
AND cp.photo_type = 2
) res 

ORDER BY 3,5,7;