SELECT * FROM (SELECT convert(varchar, TS.LastUpdate, 120) CreatedDate, po.*,po.salesRep CreatorName,U.Code CreatorCode, 'SR/DSR' CreatorRole
													,LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
													,C.Code CustomerCode
                                                    ,MP.Name ProfileName,MG.Title GroupName, LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemTitle, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemName
                                                    ,LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemContent, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemContent
                                                    ,CCVN4.dbo.[GET_OPTIONVALUE](TD.ItemValue) ItemValue
                                                    ,TD.Score ItemScore,TS.Score TotalScore, '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' PictureLink
													,TS.Ranking
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate BETWEEN '27Feb16' AND '05Mar16' ) TS
                                                    INNER JOIN Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN Users U ON TS.UserID=U.id
                                                    INNER JOIN Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN Users U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
                                                    INNER JOIN Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    INNER JOIN Biz_MeasureItem MI ON TD.ItemId=MI.ID
                                                    LEFT JOIN Customer_Photo CP ON CP.MeasureProfileID = MP.id AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.id AND customer_id = c.id AND CP.visit_Id = ts.visit_id
JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = TS.UserID
AND MP.ID IN (19,21)
AND CP.Photo_type = 2
AND TS.Ranking = 1
AND u.GROUP_ID IN (2,3)) res 
ORDER BY 3,5,7,11,19,23,22,24;