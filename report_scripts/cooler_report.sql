with source AS(
SELECT rs.*,
				  CASE WHEN rs.StepID = 1 THEN SR_Code ELSE '' END RepCode,
				  CASE WHEN rs.StepID = 1 THEN SenderUserName ELSE '' END SalesRep,
				  CASE WHEN rs.StepID = 1 AND rs.Status > 0 THEN SenderTime ELSE NULL END SR_Request,
			      CASE WHEN rs.StepID = 2 THEN SenderUserName ELSE '' END TSM,
				  CASE WHEN rs.StepID = 2 AND rs.Status > 0 THEN SenderTime ELSE NULL END TSM_Approve,
			      CASE WHEN rs.StepID = 3 THEN SenderUserName ELSE '' END ASM,
				  CASE WHEN rs.StepID = 3 AND rs.Status > 0 THEN SenderTime ELSE NULL END ASM_Approve,
			      CASE WHEN rs.StepID = 4 THEN SenderUserName ELSE '' END CDE,
				  CASE WHEN rs.StepID = 4 AND rs.Status > 0 THEN SenderTime ELSE NULL END CDE_Approve
FROM
  ( SELECT c.Code,
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
           Rank() over (Partition BY c.Code
                        ORDER BY DetailNo DESC) AS Rank
   FROM WF_TaskHead th
   JOIN WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN Customers c ON th.parameterValue = c.Code
   JOIN Users u ON u.ID = th.CreateUser
   ) rs
WHERE Rank <= rs.CurrentStepID
OR Rank = 2)
SELECT convert(varchar, cast(floor(cast(STARTTIME AS float)) AS datetime), 120) RequestedDate, convert(varchar, StartTime, 120) as RequestStartTime, Code CustomerCode, Name CustomerName
, MAX(RepCode) RepCode
, MAX(SalesRep) SalesRep
, convert(varchar, MAX(SR_Request), 120) SRRequest
, MAX(TSM) TSM
, convert(varchar, MAX(TSM_Approve), 120) TSMApprove
, MAX(ASM) ASM
, convert(varchar, MAX(ASM_Approve), 120) ASMApprove
, MAX(CDE) CDE
, convert(varchar, MAX(CDE_Approve), 120) CDEApprove
, '' InstalledDate
, DATEDIFF(day,MAX(SR_Request), MAX(CDE_Approve)) AS ApprovalDays
, '' SR2InstalledDays
, '' CDE2InstalledDays
, CASE WHEN MAX(SR_Request) IS NULL THEN 'Rejected request. Waiting redo!' ELSE '' END Remarks
FROM source
WHERE CreateDate >= '01-12-2016'
AND WorkFlowID = 10
AND CreateUser != 1947 
GROUP BY STARTTIME, Code, Name, CurrentStepID
ORDER BY 2 DESC