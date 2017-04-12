EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'CCVN4 Reporting',
    @recipients = 'minhdoanw@gmail.com',
    @query = 
'SET NOCOUNT ON; 
SELECT  country.name AS country, country.id AS countryID, company.Name AS company, company.id AS companyID, salesOrg.Name AS salesOrg, 
                      salesOrg.id AS salesOrgID, rm.Name AS RegionManager, sm.Name AS SalesManager
                      , salesOffice.Name AS salesOffice, salesOffice.ID AS salesOfficeID
                      , asm.Code as ASMCode,asm.Name AS ASM,tsm.Name as TSM,u.Name SalesRep,U.Code RepCode,C.Name CustomerName,C.Code CustomerCode,U2.Name LastUpdateBy,convert(varchar, TS.LastUpdate, 120) LastUpdate
		                                            ,MP.Name ProfileName,MG.Title GroupName,MI.ItemTitle ItemName,MI.ItemContent ItemContent,CCVN_iMentor.dbo.[GET_OPTIONVALUE](TD.ItemValue) ItemValue,TD.Score ItemScore,TS.Score TotalScore, ''=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id='' + CP.ID + ''")'' PictureLink
                                            FROM [10.0.0.6].CCVN4.dbo.Trans_MeasureTransactionSummary TS 
		                                            INNER JOIN [10.0.0.6].CCVN4.dbo.Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
		                                            INNER JOIN (SELECT Users.*, Persons.Name FROM [10.0.0.6].CCVN4.dbo.Users JOIN [10.0.0.6].CCVN4.dbo.Persons ON Users.id = Persons.id) U ON TS.UserID=U.ID
		                                            INNER JOIN [10.0.0.6].CCVN4.dbo.Customers C ON TS.CustomerID=C.ID
		                                            INNER JOIN (SELECT Users.*, Persons.Name FROM [10.0.0.6].CCVN4.dbo.Users JOIN [10.0.0.6].CCVN4.dbo.Persons ON Users.id = Persons.id)  U2 ON TS.LastUpdateBy=U2.Code
		                                            INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
		                                            INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
		                                            INNER JOIN [10.0.0.6].CCVN4.dbo.Biz_MeasureItem MI ON TD.ItemId=MI.ID
		                                            LEFT JOIN [10.0.0.6].CCVN4.dbo.Customer_Photo CP ON CP.MeasureItemId=MI.ID AND CP.MeasureProfileID = MP.id AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.id AND customer_id = c.id AND CP.visit_Id = ts.visit_id
INNER JOIN (SELECT Users.*, Persons.Name FROM [10.0.0.6].CCVN4.dbo.Users JOIN [10.0.0.6].CCVN4.dbo.Persons ON Users.id = Persons.id) tsm ON u.ManagerId = tsm.id LEFT JOIN
                      (SELECT Users.*, Persons.Name FROM [10.0.0.6].CCVN4.dbo.Users JOIN [10.0.0.6].CCVN4.dbo.Persons ON Users.id = Persons.id) asm ON tsm.ManagerId = asm.id LEFT JOIN
                      (SELECT Users.*, Persons.Name FROM [10.0.0.6].CCVN4.dbo.Users JOIN [10.0.0.6].CCVN4.dbo.Persons ON Users.id = Persons.id) sm ON asm.ManagerId = sm.id LEFT JOIN
                      (SELECT Users.*, Persons.Name FROM [10.0.0.6].CCVN4.dbo.Users JOIN [10.0.0.6].CCVN4.dbo.Persons ON Users.id = Persons.id) rm ON sm.ManagerId = rm.id LEFT JOIN
                      [10.0.0.6].CCVN4.dbo.Organization AS salesOffice ON u.org_id = salesOffice.id INNER JOIN
                      [10.0.0.6].CCVN4.dbo.Organization AS salesOrg ON salesOrg.id = salesOffice.ParentID AND salesOffice.Org_Level = 4 INNER JOIN
                      [10.0.0.6].CCVN4.dbo.Organization AS company ON company.id = salesOrg.ParentID AND salesOrg.Org_Level = 3 INNER JOIN
                      [10.0.0.6].CCVN4.dbo.Organization AS country ON country.id = company.ParentID AND company.Org_Level = 2
where EXISTS (SELECT 1 FROM [10.0.0.6].CCVN4.dbo.MObile_Users WHERE MObile_Users.user_id = u.id)

AND TS.LastUpdate>=convert(date, getdate())

ORDER BY 2,4,6,10
SET NOCOUNT OFF;' ,
    @subject = 'Survey Transaction daily report',
       @body = 
'Hi all,
       
Please see attached report for Survey Transaction today.
       
Regards,
Minh',
    @attach_query_result_as_file = 1,
       @query_attachment_filename = 'SurveyTransactionDaily.csv',
       @query_result_separator = ','
       ,@query_result_no_padding= 1
       ,@query_result_width= 5000
       ,@exclude_query_output =1
