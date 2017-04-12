with source AS(
SELECT rs.*,
                  CASE WHEN 1 = 1 THEN SR_Code ELSE NULL END RepCode,
                  CASE WHEN 1 = 1 THEN rs.Salesrep ELSE NULL END SR,
                  CASE WHEN rs.StepID = 1 AND rs.Status > 0 THEN SenderTime ELSE NULL END SR_Request,
                  CASE WHEN rs.StepID = 2 THEN SenderUserName ELSE NULL END TSM,
                  CASE WHEN rs.StepID = 2 AND rs.Status > 0 THEN SenderTime ELSE NULL END TSM_Approve,
                  CASE WHEN rs.StepID = 3 THEN SenderUserName ELSE NULL END ASM,
                  CASE WHEN rs.StepID = 3 AND rs.Status > 0 THEN SenderTime ELSE NULL END ASM_Approve,
                  CASE WHEN rs.StepID = 4 THEN SenderUserName ELSE NULL END MasterData,
                  CASE WHEN rs.StepID = 4 AND rs.Status > 0 THEN SenderTime ELSE NULL END MasterData_Update,
				  CASE WHEN rs.StepID = 5 THEN SenderUserName ELSE NULL END CDE,
                  CASE WHEN rs.StepID = 5 AND rs.Status > 0 THEN SenderTime ELSE NULL END CDE_Approve,
				  CASE WHEN rs.StepID = 6 THEN SenderUserName ELSE NULL END CDE2,
                  CASE WHEN rs.StepID = 6 AND rs.Status > 0 THEN SenderTime ELSE NULL END CDE_Installed
FROM
  ( SELECT vp.*,
           c.Code,
           LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.name, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Name,
		   LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Address,
           u.Code SR_Code,
           CurrentStepID,
           StepID,
           td.Status,
            LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(th.Comment, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Comment,
           SenderTime,
           SenderUserName,
           th.id TaskHeadID,
           th.CreateDate,
           th.CreateUser,
           th.WorkFlowID,
           th.STARTTIME,
           Rank() over (Partition BY th.ID
                        ORDER BY DetailNo DESC) AS Rank
   FROM [10.0.0.6].CCVN4.dbo.WF_TaskHead th
   JOIN [10.0.0.6].CCVN4.dbo.WF_TaskDetail td ON th.ID = td.TaskHeadID
   LEFT JOIN [CCVNREPORTING].CCVN4_Reporting.dbo.Customers c ON convert(int,CASE WHEN LEN(th.ParameterValue) > 9 THEN 0 ELSE th.ParameterValue END)  = c.ID
   JOIN [CCVNREPORTING].CCVN4_Reporting.dbo.Users u ON u.user_id = th.CreateUser
   LEFT JOIN [CCVNREPORTING].CCVN4_Reporting.dbo.View_PositionOrg vp ON vp.salesRepID = u.user_id
   WHERE th.CreateDate >= '01-12-2016'
   AND th.WorkFlowID IN (27,28,29)
   AND th.CreateUser != 1947 
   ) rs
WHERE Rank <= 5
--OR Rank = 2
)
SELECT convert(varchar, cast(floor(cast(STARTTIME AS float)) AS datetime), 120) RequestedDate
, country, company
, salesOrg, RegionManager, SalesManager, SalesOffice, AreaManager, TerritorySalesManager
, convert(varchar, StartTime, 120) as RequestStartTime, CASE WHEN WorkFlowID = 28 THEN 'Cooler Return' ELSE 'Cooler Placement' END Workflow, Code CustomerCode, Name CustomerName, Address CustomerAddress
, MAX(RepCode) RepCode
, MAX(SR) SalesRep
, convert(varchar, MAX(SR_Request), 120) SRRequest
, MAX(TSM) TSM
, convert(varchar, MAX(TSM_Approve), 120) TSMApprove
, MAX(ASM) ASM
, convert(varchar, MAX(ASM_Approve), 120) ASMApprove
, MAX(MasterData) MasterData
, convert(varchar, MAX(MasterData_Update), 120) MasterDataUpdate
, MAX(CDE) CDE
, convert(varchar, MAX(CDE_Approve), 120) CDEApprove
, convert(varchar, MAX(CDE_Installed), 120) CDEInstalled
, '' InstalledDate
, DATEDIFF(day,MAX(SR_Request), MAX(CDE_Approve)) AS ApprovalDays
, '' SR2InstalledDays
, '' CDE2InstalledDays
, CASE WHEN MAX(SR_Request) IS NULL THEN 'Rejected request. Waiting redo!' ELSE '' END Remarks
, Comment, TaskHeadID WFID
FROM source
GROUP BY STARTTIME, WorkFlowID, Code, Name, Address, country, company
, salesOrg, RegionManager, SalesManager, SalesOffice, AreaManager, TerritorySalesManager, Comment, TaskHeadID
ORDER BY 2,3,4, RequestStartTime DESC;