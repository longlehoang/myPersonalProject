USE [CCVN4_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[export_data]    Script Date: 11/25/2016 3:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[export_data]
	@Table_Name nvarchar(200),
	@Date_From datetime,
	@Date_To datetime
as
/***********************************************************************************
    --Procedre Name:export_data
    --
    -- Purpose: Export Data
    --
    -- Modifiction History
    --------------------------------------------------------------------------------
    -- Author     Date           Version     Description(For Version Control)
    -- -------    -----------    --------    ---------------------------------
    -- Patty      2015-10-09     1.00        Create
**************************************************************************************/
begin
	declare @SQL nvarchar(max)

	if @Table_Name in('View_PositionOrg','PROMOTIONS')
	set @SQL ='Select * from '+ @Table_Name

	if @Table_Name in('ALERTS')
	set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name

	if @Table_Name in('CUSTOMER_CHAINS','MYPAQ_User_Summarys','Order_Promotion_MatrixValue')
	set @SQL ='Select * from ccvn4_reporting.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where rec_time_stamp between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end

	if @Table_Name in('ORDER_LINES_PROMO')
	set @SQL ='Select * from ccvn4_reporting.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where CALCULATE_TIME between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end	

	if @Table_Name in('ORDER_HEADERS','ORDER_LINES')
	set @SQL ='Select * from ccvn4_reporting.dbo.'+ @Table_Name+' (NOLOCK)'+case when @Date_From is not null and @Date_To is not null then ' where rec_time_stamp between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''' OR confirmed_date between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end

	if @Table_Name ='ATTENDANCE_RESULT'
	set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where attendance_date between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end

	if @Table_Name ='sfaCodeDesc'
	set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where changedatetime between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end
	--modify by patty 2015-12-03
	if @Table_Name in('User_Groups','CTS_Cooler_Master')
	set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where rec_time_stamp between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else  ' ' end

	if @Table_Name in('Biz_MeasureProfile','Biz_MeasureGroup','Biz_MeasureItem','Biz_MeasureItemOption','Biz_MeasureGroupDetail','Biz_MeasureProfileDetail')
	set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where lastupdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else  ' ' end

	if @Table_Name in('Mas_User','Mas_Customer','Mas_UserGroup','Mas_UserHierarchy')
	set @SQL ='Select * from ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where lastupdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end

	if @Table_Name in('Trans_MeasureTransactionSummary','Trans_MeasureTransactionDetail')
	set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where lastupdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end
				
	if @Table_Name = 'Trans_Visit'
	set @SQL ='Select * from ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where lastupdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''
													  else ' ' end
	Print @SQL
	exec (@SQL)
end