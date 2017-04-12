SELECT * FROM (SELECT convert(varchar, TS.LastUpdate, 120) CreatedDate, country.name AS country, country.id AS countryID, company.Name AS company, company.id AS companyID, salesOrg.Name AS salesOrg, 
                      salesOrg.id AS salesOrgID, rm.Name AS RegionManager, sm.Name AS SalesManager
                      , salesOffice.Name AS salesOffice, salesOffice.ID AS salesOfficeID
                      , asm.Code as ASMCode,asm.Name AS ASM,tsm.Name as TSM,u.Name CreatorName,U.Code CreatorCode, u.group_id CreatorRole,C.Name CustomerName,C.Code CustomerCode
                                                    ,MP.Name ProfileName, TS.Score TotalScore
													,TS.Ranking
											FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.MeasureProfileId IN (19,21)) TS
                                                    --INNER JOIN Trans_MeasureTransactionDetail TD ON TS.TransactionId=TD.TransactionId
                                                    INNER JOIN (SELECT Users.*, Persons.Name FROM Users JOIN Persons ON Users.id = Persons.id) U ON TS.UserID=U.ID
                                                    INNER JOIN Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN (SELECT Users.*, Persons.Name FROM Users JOIN Persons ON Users.id = Persons.id)  U2 ON TS.LastUpdateBy=U2.Code
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID
                                                    --INNER JOIN Biz_MeasureGroup MG ON TD.MeasureGroupId=MG.Id
                                                    --INNER JOIN Biz_MeasureItem MI ON TD.ItemId=MI.ID
                                                    --LEFT JOIN Customer_Photo CP ON CP.MeasureItemId=MI.ID AND CP.MeasureProfileID = MP.id AND CP.MeasureGroupId = MG.ID AND CP.User_Id = u.id AND customer_id = c.id AND CP.visit_Id = ts.visit_id
INNER JOIN (SELECT Users.*, Persons.Name FROM Users JOIN Persons ON Users.id = Persons.id) tsm ON u.ManagerId = tsm.id LEFT JOIN
                      (SELECT Users.*, Persons.Name FROM Users JOIN Persons ON Users.id = Persons.id) asm ON tsm.ManagerId = asm.id LEFT JOIN
                      (SELECT Users.*, Persons.Name FROM Users JOIN Persons ON Users.id = Persons.id) sm ON asm.ManagerId = sm.id LEFT JOIN
                      (SELECT Users.*, Persons.Name FROM Users JOIN Persons ON Users.id = Persons.id) rm ON sm.ManagerId = rm.id LEFT JOIN
                      Organization AS salesOffice ON u.org_id = salesOffice.id INNER JOIN
                      Organization AS salesOrg ON salesOrg.id = salesOffice.ParentID AND salesOffice.Org_Level = 4 INNER JOIN
                      Organization AS company ON company.id = salesOrg.ParentID AND salesOrg.Org_Level = 3 INNER JOIN
                      Organization AS country ON country.id = company.ParentID AND company.Org_Level = 2
where EXISTS (SELECT 1 FROM MObile_Users WHERE MObile_Users.user_id = u.id)
AND TS.Ranking = 1
AND u.Group_id IN (2,3)) res 
ORDER BY 3,5,7,11,19,21,20;
