with source AS(
SELECT rs.*,
				  CASE WHEN rs.StepID = 1 THEN SR_Code ELSE '' END RepCode,
				  CASE WHEN rs.StepID = 1 THEN SenderUserName ELSE '' END SalesRep,
				  CASE WHEN rs.StepID = 1 AND rs.Status > 0 THEN SenderTime ELSE NULL END SR_Request,
			      CASE WHEN rs.StepID = 2 THEN SenderUserName ELSE '' END TSMName,
				  CASE WHEN rs.StepID = 2 AND rs.Status > 0 THEN SenderTime ELSE NULL END TSM_Approve
FROM
  ( SELECT po.SalesOrg,
		   po.RegionManager,
		   po.SalesManager,
		   po.AreaManager,
		   po.AreaCode,
		   po.TerritorySalesManager TSM,
		   tsm.Code TSMCode,
  		   c.Code,
           c.Name,
		   u.Code SR_Code,
           CurrentStepID,
		   StepID,
		   td.Status,
		   SenderTime,
		   SenderUserName,
		   th.CreateDate,
		   th.CreateUser,
		   th.WorkFlowID,
		   th.STARTTIME,
           Rank() over (Partition BY c.Code,th.CreateDate 
                        ORDER BY DetailNo DESC) AS Rank
   FROM WF_TaskHead th
   JOIN WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN Customers c ON convert(int,CASE WHEN LEN(th.ParameterValue) > 9 THEN 0 ELSE th.ParameterValue END) = c.ID
   JOIN Users u ON u.ID = th.CreateUser
   JOIN Users tsm ON tsm.id = u.managerid
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.salesRepID = u.id
   ) rs WHERE rs.Rank < 3)
SELECT convert(varchar, cast(floor(cast(STARTTIME AS float)) AS datetime), 120) RequestedDate, convert(varchar, StartTime, 120) as RequestStartTime,
SalesOrg,
		   RegionManager,
		   SalesManager,
		   AreaManager,
		   AreaCode,
		   TSM,
		   TSMCode,
 Code CustomerCode, Name CustomerName
, MAX(RepCode) RepCode
, MAX(SalesRep) SalesRep
, convert(varchar, MAX(SR_Request), 120) SRRequest
, MAX(TSMName) TSM
, convert(varchar, MAX(TSM_Approve), 120) TSM_Approve
, CASE WHEN MAX(SR_Request) IS NULL THEN 'Rejected request. Waiting redo!' ELSE '' END Remarks
FROM source
WHERE CreateDate >= '01-12-2016'
AND WorkFlowID = 14
AND CreateUser != 1947 
GROUP BY STARTTIME, Code, Name, CurrentStepID, SalesOrg,  RegionManager, SalesManager,AreaManager,AreaCode,TSM,TSMCode
ORDER BY 1, 3,4,5,6,7,8,12,13 DESC