execute as login = 'sa'
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'CCVN4 Reporting',
    @recipients = 'minhdoanw@gmail.com',
    @query = 
'SET NOCOUNT ON; 
SELECT * FROM (SELECT convert(varchar, TS.LastUpdate, 120) CreatedDate, po.*,u.Name CreatorName,U.Code CreatorCode, ''SR/DSR'' CreatorRole,C.Name CustomerName,C.Code CustomerCode
                                                    ,MP.Name ProfileName,MG.Title GroupName, LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemTitle, CHAR(13), ''''), CHAR(10), ''''),'','','';''))) ItemName
                                                    ,LTRIM(RTRIM(replace(REPLACE(REPLACE(MI.ItemContent, CHAR(13), ''''), CHAR(10), ''''),'','','';''))) ItemContent
                                                    ,CCVN_iMentor.dbo.[GET_OPTIONVALUE](TD.ItemValue) ItemValue
                                                    ,TD.Score ItemScore,TS.Score TotalScore, ''=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id='' + CP.ID + ''")'' PictureLink
													,TS.Ranking
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM [10.0.0.6].CCVN4.dbo.Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate > ''01-Feb-2016'') TS
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN CCVN4_Reporting.dbo.Users U ON TS.UserID=U.user_ID
                                                    INNER JOIN CCVN4_Reporting.dbo.Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN CCVN4_Reporting.dbo.Users U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureItem MI ON TD.ItemId=MI.ID
                                                    LEFT JOIN [10.0.0.6].CCVN4.dbo.Customer_Photo CP ON CP.MeasureItemId=MI.ID AND CP.MeasureProfileID = MP.id AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.user_id AND customer_id = c.id AND CP.visit_Id = ts.visit_id
JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = TS.UserID
AND MP.ID IN (25)
AND TS.Ranking = 1
AND u.MobileUser =1) res 
ORDER BY 3,5,7,11,19,23,22,24;

SET NOCOUNT OFF;' ,
    @subject = 'Coke Best Fresh Program survey weekly report',
       @body = 
'Hi all,
       
Please see attached report for Coke Best Fresh Program from 01/02/2016.
       
Regards,
Minh',
	   @attach_query_result_as_file = 1,
       @query_attachment_filename = 'CokeBestFreshProgramDaily.csv',
       @query_result_separator = '	',
       @query_result_no_padding= 1,
       @query_result_width= 10000,
       @exclude_query_output =1
revert