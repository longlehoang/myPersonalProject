USE [PRD_CCVN_iMentor]
GO
/****** Object:  StoredProcedure [dbo].[SyncUpload_WF_TaskHead]    Script Date: 11/1/2016 3:36:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SyncUpload_WF_TaskHead]
	@ID  UNIQUEIDENTIFIER, 	
	@WorkFlowID  BIGINT, 	
	@CurrentStepID  INT, 	
	@CurrentSenderUserID  INT, 	
	@CurrentSenderUserName  NVARCHAR(500), 	
	@CurrentReceiveUserID  INT, 	
	@CurrentReceiveUserName  NVARCHAR(500), 	
	@CurrentReceiveTime  DATETIME, 	
	@FirstSenderUserID  INT, 	
	@StartTime  DATETIME, 	
	@EndTime  DATETIME, 	
	@Status  CHAR(1), 	
	@Comment  NVARCHAR(500), 	
	@CreateDate  DATETIME, 	
	@CreateUser  NVARCHAR(500), 	
	@UpdateDate  DATETIME, 	
	@UpdateUser  NVARCHAR(500),
	@ParameterType CHAR(1),
	@ParameterValue NVARCHAR(500),
	@LastSql NVARCHAR(max)
As
BEGIN
	----------------Get workflow next step user---------------------
	if @CurrentReceiveUserID=0
	begin
		declare @NextStepUser int
		declare @NextStepUserName nvarchar(50)
		declare @ActionUserGroup int
		declare @ActionUserSql nvarchar(max)

		select @ActionUserGroup=ActionUserGroup,@ActionUserSql=Script 
		from WF_Design where WorkFlowID=@WorkFlowID and StepID=@CurrentStepID-1

		if (@ActionUserGroup=2)
		begin
			select @NextStepUser=ParentUserId from Mas_UserHierarchy where UserID=@CurrentSenderUserID
			set @NextStepUserName=dbo.FN_GET_UserName(@NextStepUser)
		end
		else
		begin
			exec sp_executesql @ActionUserSql, N'@id int out,@name nvarchar(50) out,@user_id nvarchar(20)', @NextStepUser out,@NextStepUserName out,@CurrentSenderUserID
		end
	end
	else
		begin
			set @NextStepUser=@CurrentReceiveUserID
			set @NextStepUserName=dbo.FN_GET_UserName(@CurrentReceiveUserID)
		end
	-----------------------------------------------------------------

	DECLARE @icount int
	
	SELECT @icount=COUNT(1) FROM CCVN4_WF_TaskHead WHERE id=@ID
	IF @icount>0
	begin

		UPDATE CCVN4_WF_TaskHead
		SET WorkFlowID=@WorkFlowID
			,[CurrentStepID]=@CurrentStepID
			,[CurrentSenderUserID]=@CurrentSenderUserID
			,[CurrentSenderUserName]=@CurrentSenderUserName
			,[CurrentReceiveUserID]=@NextStepUser
			,[CurrentReceiveUserName]=@NextStepUserName
			,[CurrentReceiveTime]=@CurrentReceiveTime
			,[FirstSenderUserID]=@FirstSenderUserID
			,[StartTime]=@StartTime
			,[EndTime]=@EndTime
			,[Status]=@Status
			,[Comment]=@Comment
			,[UpdateDate]=@UpdateDate
			,[UpdateUser]=@UpdateUser
			,ParameterType=@PARAMETERTYPE
			,ParameterValue=@PARAMETERVALUE
		WHERE ID=@ID
	end
	ELSE
		Insert Into CCVN4_WF_TaskHead
			([ID],[WorkFlowID],[CurrentStepID],[CurrentSenderUserID],[CurrentSenderUserName],[CurrentReceiveUserID],[CurrentReceiveUserName],[CurrentReceiveTime],[FirstSenderUserID],[StartTime],[EndTime],[Status],[Comment],[CreateDate],[CreateUser],[UpdateDate],[UpdateUser],ParameterType,ParameterValue)
		Values
			(@ID,@WorkFlowID,@CurrentStepID,@CurrentSenderUserID,@CurrentSenderUserName,@NextStepUser,@NextStepUserName,@CurrentReceiveTime,@FirstSenderUserID,@StartTime,@EndTime,@Status,@Comment,@CreateDate,@CreateUser,GETDATE(),@UpdateUser,@PARAMETERTYPE,@PARAMETERVALUE)
	
	--IF @LastSql IS NOT NULL OR @LastSql<>''
	--BEGIN
	--	EXEC(@LastSql) 
	--END
	
	
End