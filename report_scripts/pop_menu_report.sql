with source AS(
SELECT rs.*,
				  CASE WHEN rs.StepID = 1 THEN SR_Code ELSE '' END RepCode,
				  CASE WHEN rs.StepID = 1 THEN SenderUserName ELSE '' END SR,
				  CASE WHEN rs.StepID = 1 AND rs.Status > 0 THEN SenderTime ELSE NULL END SR_Request,
			      CASE WHEN rs.StepID = 2 THEN SenderUserName ELSE '' END Designer,
				  CASE WHEN rs.StepID = 2 AND rs.Status > 0 THEN SenderTime ELSE NULL END DesignerProceed
FROM
  ( SELECT po.*,
           c.Code,
           LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.name, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Name,
		   LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Address,
            LTRIM(RTRIM(replace(replace(REPLACE(REPLACE(th.Comment, CHAR(13), ''), CHAR(10), ''),',',';'),'"',''))) Comment,
		   u.Code SR_Code,
           CurrentStepID,
		   tsm.Code TSM,
		   StepID,
		   td.Status,
		   SenderTime,
		   SenderUserName,
		   th.CreateDate,
		   th.CreateUser,
		   th.WorkFlowID,
		   th.STARTTIME,
		   isnull(cc.CHAINS_NAME,'x') as Distributor,  isnull(cc.CHAINS_CODE,'x') as DistributorCode,
           Rank() over (Partition BY c.Code,th.CreateDate 
                        ORDER BY DetailNo DESC) AS Rank
   FROM WF_TaskHead th
   JOIN WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.Customers c ON convert(int,CASE WHEN LEN(th.ParameterValue) > 9 THEN 0 ELSE th.ParameterValue END) = c.ID
   JOIN Users u ON u.ID = th.CreateUser
   JOIN Users tsm ON tsm.id = u.managerid
   JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.salesRepID = u.id
   LEFT join  [10.0.0.7].CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id
) rs WHERE rs.Rank < 3)
SELECT convert(varchar, cast(floor(cast(STARTTIME AS float)) AS datetime), 120) RequestedDate, convert(varchar, StartTime, 120) as RequestStartTime,
SalesOrg,
		   RegionManager,
		   SalesManager,
		   AreaManager,
		   AreaCode,
		   TerritorySalesManager,
		   TSMCode,
 Code CustomerCode, Name CustomerName
, MAX(RepCode) RepCode
, MAX(SR) SalesRep
, convert(varchar, MAX(SR_Request), 120) SRRequest
, MAX(Designer) Designer
, convert(varchar, MAX(DesignerProceed), 120) DesignerProceed
, CASE WHEN MAX(SR_Request) IS NULL THEN 'Rejected request. Waiting redo!' ELSE '' END Remarks, Address CustomerAddress, Distributor, DistributorCode
FROM source
WHERE CreateDate >= '01-12-2016'
AND WorkFlowID IN (12,21)
AND CreateUser != 1947 
GROUP BY STARTTIME, Code, Name, CurrentStepID, SalesOrg,  RegionManager, SalesManager,AreaManager,AreaCode,TerritorySalesManager,TSMCode, Address, Distributor, DistributorCode
ORDER BY 1, 3,4,5,6,7,8,12,13 DESC