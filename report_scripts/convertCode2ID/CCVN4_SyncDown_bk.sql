USE [PRD_CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[SyncDown_WF_TaskHead]    Script Date: 11/1/2016 3:16:52 PM ******/
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
		ParameterValue
	From WF_TaskHead
	WHERE FirstSenderUserID=@UserID AND( [UpdateDate] > @LastTime OR CreateDate>@LastTime)
End
