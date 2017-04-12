SELECT COUNT(distinct u.user_id), SUM(ol.Quantity_Confirmed_EC), o.OrgID, o.OrgName 
FROM USERS u jOIN organization o ON u.org_id = o.OrgID JOIN order_headers oh 
ON oh.user_id = u.user_id JOIN order_lines ol ON oh.order_no = ol.order_no
WHERE oh.confirmed_date > '30Apr16' GROUP BY  o.OrgID, o.OrgName ORDER BY 2

SELECT COUNT(distinct v.customer_id), org_id FROM VISITS v 
WHERE v.start_time > '30Apr16' AND org_id IN (81,80,82,139,140,141,183) GROUP BY org_id 
 
SELECT COUNT(distinct v.customer_id), org_id FROM ORDER_HEADERS v 
WHERE v.Confirmed_Date > '30Apr16' AND org_id IN (81,80,82,139,140,141,183) GROUP BY org_id 
 
SELECT org_id, AVG(StrikeRate) StrikeRate, AVG(SKUPerOrder) FROM Biz_UserdailyKPI kpi JOIN USERS u ON u.id = kpi.userid AND u.group_Id IN (2,3)
WHERE kpi.DAte > '30Apr16' AND u.org_id IN (81,80,82,139,140,141,183) AND SalesVolume IS NOT NULL
GROUP BY u.org_id
ORDER BY 1

SELECT COUNT(distinct u.manager_id), SUM(ol.Quantity_Confirmed_EC), o.OrgID, o.OrgName 
FROM USERS u jOIN organization o ON u.org_id = o.OrgID JOIN order_headers oh 
ON oh.user_id = u.user_id JOIN order_lines ol ON oh.order_no = ol.order_no
WHERE oh.confirmed_date > '30Apr16' AND OrgID IN (81,80,82,139,140,141,183)
GROUP BY  o.OrgID, o.OrgName ORDER BY 2

SELECT TOP 10 u.Code, AVG(Score) FROM Trans_MeasureTransactionSummary ts JOIN USERS u ON ts.userID = u.id WHERE MeasureProfileId IN (36,37,19,21) GROUP BY u.Code ORDER BY 2 

SELECT u.org_id, COUNT(*), SUM(CASE WHEN th.status = 1 THEN 1 ELSE 0 END) FROM USERS u JOIN WF_TASKHEAD th ON u.id = th.FirstSenderUserID   WHERE th.CreateDate >= '01-12-2016'
   AND th.WorkFlowID = 10
   AND th.CreateUser != 1947 
   AND u.org_id IN (81,80,82,139,140,141,183)
   GROUP BY u.org_id
  
SELECT COUNT(*) FROM cts_cooler_master cts JOIN customers c ON c.id = cts.customerid 
WHERE c.org_id IN (81,80,82,139,140,141,183) AND cts.valid = 1
  
SELECT th.IS_Normal, COUNT(distinct rfid)  FROM USERS u JOIN CTS_RESULT th ON u.id = th.USER_ID   WHERE u.org_id IN (81,80,82,139,140,141,183)
   GROUP BY th.IS_Normal
   ORDER BY 1
   
 SELECT cast(floor(cast(ls.Date AS float)) AS datetime), OrgId, COUNT(DISTINCT ls.UserCode) TotalTSM
FROM [dbo].[Log_Sync] ls
JOIN [dbo].[Mas_User] ms ON ls.UserCode = ms.UserCode 
WHERE ls.Date > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
AND ms.GroupCode IN ('TSM')
AND OrgId IN (SELECT ID FROM dbo.Mas_Organization WHERE Code LIKE 'V%')
AND ((DATEPART(dw, ls.Date) + @@DATEFIRST) % 7) NOT IN (1)
GROUP BY cast(floor(cast(ls.Date AS float)) AS datetime), OrgId
ORDER BY cast(floor(cast(ls.Date AS float)) AS datetime);

SELECT tt.START_TIME visit_date, u.org_id
     , SUM(CASE WHEN u.group_id IN (2,3) THEN 1 ELSE 0 END) SR
FROM 
     (SELECT DISTINCT cast(floor(cast(t.START_TIME AS float)) AS datetime) START_TIME, t.user_id FROM dbo.VISITS t
      WHERE t.START_TIME > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
		AND ((DATEPART(dw, t.START_TIME) + @@DATEFIRST) % 7) NOT IN (1)) tt 
  INNER JOIN dbo.USERS u ON u.id = tt.user_id
WHERE u.Org_Id IN (SELECT ID FROM dbo.ORGANIZATION WHERE Code LIKE 'V%')
GROUP BY tt.START_TIME, u.org_id
ORDER BY tt.START_TIME;

SELECT tt.START_TIME visit_date,tt.Device
     , SUM(CASE WHEN u.group_id IN (2,3) THEN 1 ELSE 0 END) SR
FROM 
     (SELECT DISTINCT cast(floor(cast(t.START_TIME AS float)) AS datetime) START_TIME, t.user_id, LEFT(t.MOBILE_PLATFORM,1) Device FROM dbo.VISITS t
      WHERE t.START_TIME > cast(floor(cast(GETDATE() AS float) - 30) AS datetime)
		AND ((DATEPART(dw, t.START_TIME) + @@DATEFIRST) % 7) NOT IN (1)) tt 
  INNER JOIN dbo.USERS u ON u.id = tt.user_id
WHERE u.Org_Id IN (SELECT ID FROM dbo.ORGANIZATION WHERE Code LIKE 'V%')
GROUP BY tt.START_TIME, tt.Device
ORDER BY tt.START_TIME;

SELECT c.org_id, COUNT(distinct c.code), AVG(TS.Score)
                                                    FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
											WHERE TranS.LastUpdate Between '22Apr16' AND '20May16') TS
                                                    INNER JOIN Users U ON TS.UserID=U.id
                                                    INNER JOIN Customers C ON TS.CustomerID=C.ID
                                                    INNER JOIN Biz_MeasureProfile MP ON TS.MeasureProfileId=MP.ID 
                                                    
WHERE MP.ID IN (36,37)
--AND TS.Ranking = 1
AND u.GROUP_ID IN (2,3)
AND c.org_id IN (81,80,82,139,140,141,183)
GROUP BY c.org_id