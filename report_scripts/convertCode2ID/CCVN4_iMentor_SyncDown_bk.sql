USE [PRD_CCVN_iMentor]
GO
/****** Object:  StoredProcedure [dbo].[SyncDown_WF_TaskHead]    Script Date: 11/1/2016 3:35:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SyncDown_WF_TaskHead]
	@LastTime DATETIME,
	@UserID INT
As
Begin
	Select 
		[ID],
		[WorkFlowID],
		[CurrentStepID],
		[CurrentSenderUserID],
		[CurrentSenderUserName],
		[CurrentReceiveUserID],
		[CurrentReceiveUserName],
		[CurrentReceiveTime],
		[FirstSenderUserID],
		[StartTime],
		[EndTime],
		[Status],
		[Comment],
		[CreateDate],
		[CreateUser],
		[UpdateDate],
		[UpdateUser],
		ParameterType,
		ParameterValue,
		'' LastSql 
	From WF_TaskHead
	WHERE (FirstSenderUserID=@UserID OR CurrentSenderUserID=@UserID OR ID IN (
    	                                        SELECT wt1.TaskHeadID
    	                                        FROM WF_TaskDetail wt1
    		                                        INNER JOIN (
					                                        SELECT TaskHeadID,MAX(detailno) DetailNo 
					                                        FROM WF_TaskDetail
					                                        WHERE  SenderUserID=@UserID AND Status=0
					                                        GROUP BY TaskHeadID
    		                                        ) wt2 ON wt1.TaskHeadID=wt2.TaskHeadID AND wt1.DetailNo=wt2.DetailNo	
    	
                                            ))
	AND ID IN (SELECT id FROM dbo.WF_TaskHead WHERE FirstSenderUserID IN(select UserID from dbo.FN_Get_UserIDWithParentUser(@UserID)))
	
End
