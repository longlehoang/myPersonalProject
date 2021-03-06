USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetWorkFlowExcelData]    Script Date: 2/6/2017 2:57:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[sp_GetWorkFlowExcelData]
	@wfname NVARCHAR(MAX),
	@start NVARCHAR(20),
	@end NVARCHAR(20),
	@senduserName NVARCHAR(50),
	@flag CHAR(1),
	@userID decimal,
	@WorkFlowType BIGINT,
	@countryID INT,
	@CustomerCode NVARCHAR(50),
	@CustomerName NVARCHAR(50),
	@SaleSepCode NVARCHAR(50),
	@SaleSepName NVARCHAR(50),
	@OrgId NVARCHAR(max),
	@DistributorId NVARCHAR(10) ,
	@TaskHeadID NVARCHAR(36)
As
BEGIN
	DECLARE @SQL NVARCHAR(MAX),@where NVARCHAR(MAX), @userGroup INT

	SET @where=''
		IF @flag='0'
			SET @where = @where + '  AND WFTD.Status IN (''0'',''1'',''2'') '
		ELSE IF @flag='1'
			SET @where = @where + '  AND WFTD.Status IN (''0'') '
		ELSE IF @flag='2'
			SET @where = @where + '  AND WFTD.Status IN (''1'',''2'') '

		IF ISNULL(@wfname,'')<>''
			SET @where = @where + ' and WFM.Name like ''%'+@wfname+'%'' '
		
		IF ISNULL(@start,'')<>''
			SET @where = @where + ' and WFTH.StartTime >='''+@start+''' '

		IF ISNULL(@end,'')<>''
			SET @where = @where + ' and WFTH.StartTime <= dateadd(day,datediff(day,0,'''+@end+'''),1) '

		IF ISNULL(@senduserName,'') <> ''
			SET @where = @where + ' and WFTH.CurrentSenderUserName like ''%'+@senduserName+'%''  '

		IF ISNULL(@WorkFlowType,0) <> 0
			SET @where = @where + ' and WFTH.WorkFlowID='+CAST(@WorkFlowType AS NVARCHAR)+' and org.countryID='+CAST(@countryID AS NVARCHAR)

		IF ISNULL(@CustomerCode,'')<>''
			SET @where = @where + ' and c.CODE like ''%'+@CustomerCode+'%'' '

		IF ISNULL(@CustomerName,'')<>''
			SET @where = @where + 'and c.NAME like ''%'+@CustomerName+'%'' '

		IF ISNULL(@SaleSepCode,'')<>''
			SET @where = @where + ' and USERS.CODE like ''%'+@SaleSepCode+'%'' '

		IF ISNULL(@SaleSepName,'')<>''
			SET @where = @where + ' and PERSONS.NAME like ''%'+@SaleSepName+'%'' '

		IF ISNULL(@OrgId,'')<>''
			SET @where = @where + ' and c.org_id in('+@OrgId+')'

		IF ISNULL(@DistributorId,'')<>''
			SET @where = @where + ' and cc.CHAINS_ID='+CAST(@DistributorId AS NVARCHAR)

		IF ISNULL(@TaskHeadID,'')<>''
			SET @where = @where + ' and CAST(WFTH.Id AS VARCHAR(36)) LIKE ''%'+@TaskHeadID+'%'''


	SET @SQL='SELECT t.*
				,wd.StepName
				,wd.SenderUserName
				,wd.ReceiveUserName
				,wd.ReceiveTime
				,wd.Comment
				,case wd.Status when 0 then ''Pending'' when 1 then ''Complete'' when 2 then ''Reject'' else ''N/A'' end as Status
				,CASE WHEN wd1.DetailNo=wd.DetailNo THEN wd.ContentJson ELSE '''' END AS ContentJson
				,CASE WHEN wd1.DetailNo=wd.DetailNo THEN wf.FieldJosn ELSE '''' END AS FieldJosn
				 FROM (
				SELECT DISTINCT 
				WFTH.Id AS TaskHeadID
				,org.salesOrg
				,org.rm as RegionManager
				,org.sm as SalesManager
				,org.asm as AreaManager
				,org.asm_code as AreaCode
				,org.tsm as TSM
				,org.tsm_code as TSMCode
				,org.rep as salesRep
				,org.rep_code as salesRepCode
				,CHAINS.DESCRIPTION as Distributor
				,CHAINS.CODE as DistributorCode
				,WFM.Name as WorkflowName
				,c.NAME as CustomerName
				,c.CODE as CustomerCode
				,trade.CodeDesc as TradeChannel
				,subTrade.CodeDesc as SubTradeChannel
				,custtype.CodeDesc as CustomerType
				,c.DeliveryType
				,WFTD.DetailNo
				,WFTH.CurrentReceiveTime
				FROM WF_TaskHead WFTH
				LEFT JOIN dbo.CUSTOMERS c ON CAST(c.ID AS VARCHAR)=WFTH.ParameterValue AND WFTH.ParameterType=''1''
				LEFT JOIN CUSTOMER_CHAINS as cc ON c.ID=cc.CUSTOMER_ID
				left join CHAINS on cc.CHAINS_ID=CHAINS.ID
				LEFT JOIN USERS ON USERS.ID=WFTH.CreateUser
				LEFT JOIN PERSONS ON USERS.PERSON_ID=PERSONS.ID
				left join ORGANIZATION_VIEW org on WFTH.CreateUser=org.rep_id
				left join sfaCodeDesc trade on trade.CodeCategory=''TradeChannel'' AND c.TradeChannel=trade.CodeValue
				and trade.CountryId=org.countryID
				left join sfaCodeDesc subTrade on subTrade.CodeCategory=''SubTradeChannel'' AND c.SubTradeChannel=subTrade.CodeValue
				and subTrade.CountryId=org.countryID
				left join sfaCodeDesc custtype on custtype.CodeCategory=''Customer_Type'' AND c.customer_type=custtype.CodeValue
				INNER JOIN WF_Master WFM ON WFTH.WorkFlowID = WFM.ID
				INNER JOIN 
					(
    					SELECT wt1.TaskHeadID,wt1.[Status] ,wt1.SenderUserID,wt2.Comment AS Comments,wt1.DetailNo
    					FROM WF_TaskDetail wt1
    						INNER JOIN (
									SELECT wtd.TaskHeadID,wtd.DetailNo,wtd.Comment FROM (
										SELECT TaskHeadID,MAX(detailno) DetailNo
										FROM WF_TaskDetail
										WHERE  SenderUserID='+CAST(@userID AS NVARCHAR)+'
										GROUP BY TaskHeadID
										)t 
						INNER JOIN WF_TaskDetail wtd ON wtd.TaskHeadID=t.TaskHeadID 
										AND t.DetailNo=wtd.DetailNo
										AND wtd.SenderUserID='+CAST(@userID AS NVARCHAR)+'
    						) wt2 ON wt1.TaskHeadID=wt2.TaskHeadID AND wt1.DetailNo=wt2.DetailNo	
    	
					) WFTD ON WFTH.ID = WFTD.TaskHeadID
				WHERE WFTD.SenderUserID='+CAST(@userID AS NVARCHAR)+'  '+@where+'
				) t
				INNER JOIN WF_TaskDetail wd ON t.TaskHeadID=wd.TaskHeadID
				left JOIN (SELECT MAX(DetailNo) AS DetailNo,TaskHeadID FROM dbo.WF_TaskDetail GROUP BY TaskHeadID)wd1
							ON t.TaskHeadID=wd1.TaskHeadID
				inner join WF_TaskForm wf on wf.TaskHeadID=wd.TaskHeadID
				and wf.StepID=wd.StepID and wf.FormID=wd.FormID
				ORDER BY t.CurrentReceiveTime Desc,t.DetailNo'

	SELECT @userGroup=GROUP_ID FROM users WHERE ID = @userID
	IF ISNULL(@userGroup,0) IN (1,22,6,85,86,89,90,16)
		SET @SQL='SELECT t.*
				,wd.StepName
				,wd.SenderUserName
				,wd.ReceiveUserName
				,wd.ReceiveTime
				,wd.Comment
				,case wd.Status when 0 then ''Pending'' when 1 then ''Complete'' when 2 then ''Reject'' else ''N/A'' end as Status
				,CASE WHEN wd1.DetailNo=wd.DetailNo THEN wd.ContentJson ELSE '''' END AS ContentJson
				,CASE WHEN wd1.DetailNo=wd.DetailNo THEN wf.FieldJosn ELSE '''' END AS FieldJosn
				 FROM (
				SELECT DISTINCT 
				WFTH.Id AS TaskHeadID
				,org.salesOrg
				,org.rm as RegionManager
				,org.sm as SalesManager
				,org.asm as AreaManager
				,org.asm_code as AreaCode
				,org.tsm as TSM
				,org.tsm_code as TSMCode
				,org.rep as salesRep
				,org.rep_code as salesRepCode
				,CHAINS.DESCRIPTION as Distributor
				,CHAINS.CODE as DistributorCode
				,WFM.Name as WorkflowName
				,c.NAME as CustomerName
				,c.CODE as CustomerCode
				,trade.CodeDesc as TradeChannel
				,subTrade.CodeDesc as SubTradeChannel
				,custtype.CodeDesc as CustomerType
				,c.DeliveryType
				,WFTD.DetailNo
				,WFTH.CurrentReceiveTime
				FROM WF_TaskHead WFTH
				LEFT JOIN dbo.CUSTOMERS c ON CAST(c.ID AS VARCHAR)=WFTH.ParameterValue AND WFTH.ParameterType=''1''
				LEFT JOIN CUSTOMER_CHAINS as cc ON c.ID=cc.CUSTOMER_ID
				left join CHAINS on cc.CHAINS_ID=CHAINS.ID
				LEFT JOIN USERS ON USERS.ID=WFTH.CreateUser
				LEFT JOIN PERSONS ON USERS.PERSON_ID=PERSONS.ID
				left join ORGANIZATION_VIEW org on WFTH.CreateUser=org.rep_id
				left join sfaCodeDesc trade on trade.CodeCategory=''TradeChannel'' AND c.TradeChannel=trade.CodeValue
				and trade.CountryId=org.countryID
				left join sfaCodeDesc subTrade on subTrade.CodeCategory=''SubTradeChannel'' AND c.SubTradeChannel=subTrade.CodeValue
				and subTrade.CountryId=org.countryID
				left join sfaCodeDesc custtype on custtype.CodeCategory=''Customer_Type'' AND c.customer_type=custtype.CodeValue
				INNER JOIN WF_Master WFM ON WFTH.WorkFlowID = WFM.ID
				INNER JOIN 
					(
    					SELECT wt1.TaskHeadID,wt1.[Status] ,wt1.SenderUserID,wt2.Comment AS Comments,wt1.DetailNo
    					FROM WF_TaskDetail wt1
    						INNER JOIN (
									SELECT wtd.TaskHeadID,wtd.DetailNo,wtd.Comment FROM (
										SELECT TaskHeadID,MAX(detailno) DetailNo
										FROM WF_TaskDetail
										GROUP BY TaskHeadID
										)t 
						INNER JOIN WF_TaskDetail wtd ON wtd.TaskHeadID=t.TaskHeadID 
										AND t.DetailNo=wtd.DetailNo
						) wt2 ON wt1.TaskHeadID=wt2.TaskHeadID AND wt1.DetailNo=wt2.DetailNo	
    	
					) WFTD ON WFTH.ID = WFTD.TaskHeadID
				WHERE 1=1  '+@where+'
				) t
				INNER JOIN WF_TaskDetail wd ON t.TaskHeadID=wd.TaskHeadID
				left JOIN (SELECT MAX(DetailNo) AS DetailNo,TaskHeadID FROM dbo.WF_TaskDetail GROUP BY TaskHeadID)wd1
							ON t.TaskHeadID=wd1.TaskHeadID
				inner join WF_TaskForm wf on wf.TaskHeadID=wd.TaskHeadID
				and wf.StepID=wd.StepID and wf.FormID=wd.FormID
				ORDER BY t.CurrentReceiveTime Desc,t.DetailNo'

	PRINT (@SQL)
	EXEC (@SQL)
End
