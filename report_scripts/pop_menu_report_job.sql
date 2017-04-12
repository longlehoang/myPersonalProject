EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'CCVN4 Reporting',
    @recipients = 'minhdoanw@gmail.com',
    @query = 
'SET NOCOUNT ON; 
with source AS(
SELECT rs.*,
				  CASE WHEN rs.StepID = 1 THEN SR_Code ELSE '''' END RepCode,
				  CASE WHEN rs.StepID = 1 THEN SenderUserName ELSE '''' END SalesRep,
				  CASE WHEN rs.StepID = 1 AND rs.Status > 0 THEN SenderTime ELSE NULL END SR_Request,
			      CASE WHEN rs.StepID = 2 THEN SenderUserName ELSE '''' END Designer,
				  CASE WHEN rs.StepID = 2 AND rs.Status > 0 THEN SenderTime ELSE NULL END DesignerProceed
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
   FROM [10.0.0.6].CCVN4.dbo.WF_TaskHead th
   JOIN [10.0.0.6].CCVN4.dbo.WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN CCVN4_Reporting.dbo.Customers c ON th.parameterValue = c.Code
   JOIN CCVN4_Reporting.dbo.Users u ON u.user_ID = th.CreateUser
   JOIN CCVN4_Reporting.dbo.Users tsm ON tsm.user_id = u.manager_id
   JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.salesRepID = u.user_id
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
, MAX(Designer) Designer
, convert(varchar, MAX(DesignerProceed), 120) DesignerProceed
, CASE WHEN MAX(SR_Request) IS NULL THEN ''Rejected request. Waiting redo!'' ELSE '''' END Remarks
FROM source
WHERE CreateDate >= ''01-12-2016''
AND WorkFlowID = 12
AND CreateUser != 1947 
GROUP BY STARTTIME, Code, Name, CurrentStepID, SalesOrg,  RegionManager, SalesManager,AreaManager,AreaCode,TSM,TSMCode
ORDER BY 1, 3,4,5,6,7,8,12,13 DESC
SET NOCOUNT OFF;' ,
    @subject = 'POP Menu daily report',
       @body = 
'Hi all,
       
Please see attached report for POP menu today.
       
Regards,
Minh',
    @attach_query_result_as_file = 1,
       @query_attachment_filename = 'POPMenuWFDaily.csv',
       @query_result_separator = ','
       ,@query_result_no_padding= 1
       ,@query_result_width= 5000
       ,@exclude_query_output =1
