with source AS(
SELECT rs.*,
				  CASE WHEN 1 = 1 THEN rs.SalesRepCode ELSE '' END RepCode,
				  CASE WHEN 1 = 1 THEN rs.SalesRep ELSE '' END SalesRepName,
				  CASE WHEN rs.StepID = 1 AND rs.Status > 0 THEN SenderTime ELSE NULL END SR_Request,
			      CASE WHEN rs.StepID = 2 THEN SenderUserName ELSE '' END TSM,
				  CASE WHEN rs.StepID = 2 AND rs.Status > 0 THEN SenderTime ELSE NULL END TSM_Approve,
				  CASE WHEN rs.StepID = 3 THEN SenderUserName ELSE '' END Admin,
				  CASE WHEN rs.StepID = 3 AND rs.Status > 0 THEN SenderTime ELSE NULL END Admin_Confirm,
				  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(ContentJson, '"$id":', ''), '"ControlName":', ''),
				  '"ControlValue":',''),'},{','LINEBRK'))),'"1",',''),'"2",',''),'"3",',''),'"4",',''),'"5",',''),'"6",',''),'"7",',''),'"8",',''),'"9",',''),'"10",',''),'"11",','')
				  
				   ContentJsonFinal

FROM
  ( SELECT po.SalesOrg,
		   po.RegionManager,
		   po.SalesManager,
		   po.AreaManager,
		   po.AreaCode,
		   po.TerritorySalesManager,
		   po.SalesRepCode,
		   po.SalesRep,
		   tsm.Code TSMCode,
		   c.Code,
  		   LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.name, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Name,
		   LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Address,
           LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(th.Comment, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Comment,
		   u.Code SR_Code,
           CurrentStepID,
		   StepID,
		   td.Status,
		   td.ContentJson,
		   SenderTime,
		   SenderUserName,
		   th.CreateDate,
		   th.CreateUser,
		   th.WorkFlowID,
		   th.STARTTIME,
           Rank() over (Partition BY th.WorkFlowID,c.Code,th.CreateDate 
                        ORDER BY DetailNo DESC) AS Rank
   FROM WF_TaskHead th
   JOIN WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.Customers c ON convert(int,CASE WHEN LEN(th.ParameterValue) > 9 THEN 0 ELSE th.ParameterValue END) = c.ID
   JOIN Users u ON u.ID = th.CreateUser
   JOIN Users tsm ON tsm.id = u.managerid
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.salesRepID = u.id
   ) rs WHERE rs.Rank < 3 AND rs.StepID < 3)
SELECT convert(varchar, cast(floor(cast(STARTTIME AS float)) AS datetime), 120) RequestedDate, convert(varchar, StartTime, 120) as RequestStartTime,
SalesOrg,
		   RegionManager,
		   SalesManager,
		   AreaManager,
		   AreaCode,
		   TerritorySalesManager TSMName,
		   TSMCode,
 Code CustomerCode, Name CustomerName
, MAX(RepCode) RepCode
, MAX(SalesRepName) SalesRep
, convert(varchar, MAX(SR_Request), 120) SRRequest
, MAX(TSM) TSM
, convert(varchar, MAX(TSM_Approve), 120) TSMApprove
, MAX(Admin) Admin
, CASE WHEN MAX(SR_Request) IS NULL THEN 'Rejected request. Waiting redo!' ELSE '' END Remarks
, Address CustomerAddress
--
, MAX(ContentJsonFinal) RequestContent

--, DATEDIFF(day,MAX(SR_Request), MAX(Admin_Confirm)) AS ApprovalDays	
FROM source
WHERE CreateDate >= '1July16'
AND WorkFlowID IN (24,31,32)
AND CreateUser != 1947 
--AND SalesOrg = 'Ho Chi Minh Region'
GROUP BY STARTTIME, Code, Name, CurrentStepID, SalesOrg,  RegionManager, SalesManager,AreaManager,AreaCode,TerritorySalesManager,TSMCode, Address--, ContentJsonFinal
ORDER BY 1, 3,4,5,6,7,8,12,13 DESC