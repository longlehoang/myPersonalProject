with source AS(
SELECT rs.*,
			      CASE WHEN rs.WorkFlowID = 23 THEN 'Branding Request' WHEN rs.WorkFlowID = 24 THEN 'POSM Request' ELSE 'POP menu Request' END WFName,
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
           isnull(cc.CHAINS_NAME,'x') as Distributor,  isnull(cc.CHAINS_CODE,'x') as DistributorCode,
           Rank() over (Partition BY th.WorkFlowID,c.Code,th.CreateDate 
                        ORDER BY DetailNo DESC) AS Rank
   FROM WF_TaskHead th
   JOIN WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.Customers c ON th.parameterValue = c.Code
   JOIN Users u ON u.ID = th.CreateUser
   JOIN Users tsm ON tsm.id = u.managerid
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.salesRepID = u.id
   LEFT join  [10.0.0.7].CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id
) rs WHERE rs.Rank < 4)
SELECT convert(varchar, cast(floor(cast(STARTTIME AS float)) AS datetime), 120) RequestedDate, convert(varchar, StartTime, 120) as RequestStartTime,
SalesOrg,
		   RegionManager,
		   SalesManager,
		   AreaManager,
		   AreaCode,
		   TerritorySalesManager TSMName,
		   TSMCode,
 Code CustomerCode, Name CustomerName, Address CustomerAddress, Distributor, DistributorCode
, WFName WorkflowName
, MAX(RepCode) RepCode
, MAX(SalesRepName) SalesRep
, convert(varchar, MAX(SR_Request), 120) SRRequest
, MAX(TSM) ASM
, convert(varchar, MAX(TSM_Approve), 120) ASMApprove
, MAX(Admin) Marketing
, convert(varchar, MAX(Admin_Confirm), 120) MarketingConfirm
--, Address CustomerAddress
, CASE WHEN MAX(SR_Request) IS NULL THEN 'Rejected request. Waiting redo!' ELSE '' END Remarks
, MAX(ContentJsonFinal) RequestContent
FROM source
WHERE CreateDate >= '15Jun16'
AND WorkFlowID IN (23,24,25)
AND CreateUser != 1947 
--AND SalesOrg = 'Ho Chi Minh Region'
GROUP BY WFName, STARTTIME, Code, Name, CurrentStepID, SalesOrg,  RegionManager, SalesManager,AreaManager,AreaCode,TerritorySalesManager,TSMCode, Address, Distributor, DistributorCode--, ContentJsonFinal
ORDER BY 1, 3,4,5,6,7,8,12,13 DESC