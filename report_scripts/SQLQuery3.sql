SELECT rs.*,
				  CASE WHEN rs.StepID = 1 THEN SR_Code END RepCode,
				  CASE WHEN rs.StepID = 1 THEN SenderUserName END SalesRep,
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
           DetailNo,
		   CurrentStepID,
		   StepID,
		   th.id TaskheadID,
		   td.Status,
		   SenderTime,
		   SenderUserName,
		   th.CreateDate,
		   th.CreateUser,
		   th.WorkFlowID,
		   th.STARTTIME,
           Rank() over (Partition BY c.Code
                        ORDER BY DetailNo DESC) AS Rank
   FROM [10.0.0.6].CCVN4.dbo.WF_TaskHead th
   JOIN [10.0.0.6].CCVN4.dbo.WF_TaskDetail td ON th.ID = td.TaskHeadID
   JOIN [10.0.0.6].CCVN4.dbo.Customers c ON th.parameterValue = c.Code
   JOIN [10.0.0.6].CCVN4.dbo.Users u ON u.ID = th.CreateUser
   WHERE th.ParameterValue = '0070010975'
   AND th.WorkFlowID = 10
   --AND th.id = '01B93676-6EAF-4306-97CB-3E477090260E'
   ) rs
--WHERE Rank <= rs.CurrentStepID
--OR Rank = 2
ORDER BY TaskheadID, Rank
