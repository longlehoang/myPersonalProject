USE [CCVN4_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[Export_Data_IoT]    Script Date: 1/11/2017 8:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Export_Data_IoT]
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

	if @Table_Name in('Mas_Organization')
		set @SQL ='Select * from ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where LastUpdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  ' ' end

	if @Table_Name in('Mas_User')
		set @SQL ='Select ID,UserCode,FirstName,LastName,OrgId,IsActive,LastUpdate from ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where LastUpdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+'''' else ' ' end

	if @Table_Name in('Mas_Customer')
		set @SQL ='Select ID,Code,Name,Longitude,Latitude,OrgId,PostalCode,TradeChannel,SubTradeChannel,CustomerType,Valid,LastUpdate from ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where LastUpdate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+'''' else ' ' end

	if @Table_Name in('CTS_cooler_master')
		set @SQL ='Select EquipmentId,Barcode,SerialNo,EquipmentModel,CustomerId,Valid,REC_TIME_STAMP from ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where rec_time_stamp between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  ' ' end
	
	if @Table_Name in('Products')
		set @SQL ='Select * from dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where REC_TIME_STAMP between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  '' end
	
	if @Table_Name in('ORDER_HEADERS')
		set @SQL ='Select * from dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where REC_TIME_STAMP between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  '' end
	
	if @Table_Name in('ORDER_LINES')
		set @SQL ='Select ordln.*,Denominator from dbo.'+ @Table_Name+' ordln  inner join dbo.PRODUCT_UOMS prduom on ordln.PRODUCT_ID=prduom.PRODUCT_ID '+case when @Date_From is not null and @Date_To is not null then ' where ordln.REC_TIME_STAMP between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  '' end
	
	if @Table_Name in('Alerts')
		set @SQL ='Select AlertID,StatusId,AcknowledgeComment,UpdateDate from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where StatusId!=1 and UpdateDate between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  ' where StatusId!=1 ' end
	
	if @Table_Name in('sapCustomer')
		set @SQL ='Select * from [10.0.0.6].ccvn4.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' where ChangeDateTime between '''+cast(@Date_From as nvarchar)+''' and '''+cast(@Date_To as nvarchar)+''''  else  '' end
	
	if @Table_Name in('Mas_RouteCustomer')
		set @SQL ='WITH Mas_RouteCustomer_Range(UserID,CustomerId,Valid,LastUpdate)
	as
	(
	SELECT   [UserID],[CustomerId],[Valid],[LastUpdate]
	FROM ccvn_iMentor.dbo.'+ @Table_Name+case when @Date_From is not null and @Date_To is not null then ' WHERE LastUpdate BETWEEN '''+cast(@Date_From as nvarchar)+''' AND '''+cast(@Date_To as nvarchar)+''''  else  '' end+'
	GROUP BY UserID,CustomerId,Valid,LastUpdate
	),
	Mas_RouteCustomer_All(UserID,CustomerId,Valid,LastUpdate)
AS
(
SELECT   [UserID],[CustomerId],[Valid],[LastUpdate]
	FROM ccvn_iMentor.dbo.'+ @Table_Name+'  rc WHERE EXISTS(SELECT 1 FROM Mas_RouteCustomer_Range WHERE rc.UserID=Mas_RouteCustomer_Range.UserID) 
	GROUP BY UserID,CustomerId,Valid,LastUpdate 

)
SELECT * FROM Mas_RouteCustomer_All ORDER BY UserID'

	--Print @SQL
	exec (@SQL)
end