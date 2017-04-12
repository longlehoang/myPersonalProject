SELECT * FROM (SELECT convert(varchar, TS.LastUpdate, 120) CreatedDate, po.*,u.Name CreatorName,U.Code CreatorCode, 'SR/DSR' CreatorRole,C.Name CustomerName,C.Code CustomerCode
                                                    ,MP.Name ProfileName,MG.Title GroupName, LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemTitle, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemName
                                                    ,LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemContent, CHAR(13), ''), CHAR(10), ''),',',';'))) ItemContent
                                                    ,LTRIM(RTRIM(replace(REPLACE(REPLACE(CCVN_iMentor.dbo.[GET_OPTIONVALUE](TD.ItemValue), CHAR(13), ''), CHAR(10), ''),',',';'))) ItemValue
                                                    ,TD.Score ItemScore,TS.Score TotalScore, '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' PictureLink
													,TS.Ranking
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM [10.0.0.6].CCVN4.dbo.Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate BETWEEN '21-Feb-2016' AND '28-Feb-2016') TS
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN CCVN4_Reporting.dbo.Users U ON TS.UserID=U.user_ID
                                                    INNER JOIN CCVN4_Reporting.dbo.Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN CCVN4_Reporting.dbo.Users U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureItem MI ON TD.ItemId=MI.ID
                                                    LEFT JOIN [10.0.0.6].CCVN4.dbo.Customer_Photo CP ON CP.MeasureItemId=MI.ID AND CP.MeasureProfileID = MP.id AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.user_id AND customer_id = c.id AND CP.visit_Id = ts.visit_id
JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = TS.UserID
AND MP.ID IN (27,28)
AND TS.Ranking = 1
AND u.MobileUser =1) res 
ORDER BY 3,5,7,11,19,23,22;
