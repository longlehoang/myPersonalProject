SELECT TS.LastUpdate SurveyDate,  U.Code CreatorCode
													,LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName
													,C.Code CustomerCode
                                                    FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate > '25Feb17') TS
                                                    INNER JOIN Users U ON TS.UserID=U.id
                                                    INNER JOIN Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID 
                                                    
WHERE MP.ID IN (36,37,53,54,90,91,92)
AND TS.Ranking = 1
AND u.GROUP_ID IN (2,3)