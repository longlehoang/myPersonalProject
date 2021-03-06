USE [CCVN4_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[Report_Volume_Range_Discount]    Script Date: 12/27/2016 11:20:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		lumi
-- Create date: 2015-08-25
-- Description:	Volume Range Discount Report
-- =============================================
ALTER PROCEDURE [dbo].[Report_Volume_Range_Discount]
	@Date_From			datetime,
	@Date_To			datetime,
	@Country			nvarchar(20),
	@Company			nvarchar(20),
	@SalesOrg			nvarchar(20),
	@Salesoffice		nvarchar(20),
	@MDC				nvarchar(100),
	@Manager			nvarchar(20),
	@OrderType			NVARCHAR(20)
	
AS
BEGIN	
	declare @sql as nvarchar(max)
	
	set @sql='
		select	org.country
		,org.company
		,org.salesOrg
		,org.RegionManager
		,org.SalesManager
		,org.salesOffice
		,org.AreaManager
		,org.TerritorySalesManager
		,cc.CHAINS_NAME as mdc_name
		,cc.CHAINS_CODE as mdc_code
		,c.name as customer_name
		,c.code as customer_code
		,users.Name as salesRep
		,users.Code as salesRepCode
		,oh.order_no AS OrderNumber
		,opmv.VOLUME_EC as Qty_EC
		,opmv.VOLUME_DISCOUNT as VolumeDiscount
		,opmv.SKU_NUMBER as SkuNumber
		,opmv.SKU_DISCOUNT as SKUDiscount
		,cast(isnull(oh.TOTAL_AMOUNT,0) as int) as Amount
		,oh.ORDER_date
		,(case oh.ordertype when 0 then ''orders'' else ''trade returns'' end ) ordertype
		,ISNULL(oh.DISC_1,0) as TotalStdDiscount
		,(SELECT ISNULL(SUM(DISCOUNT_VALUE),0) FROM dbo.ORDER_LINES_PROMO WHERE PROMO_CLASS=1 AND ORDER_NO=oh.ORDER_NO) as TotalWindowDiscount
		,(SELECT ISNULL(SUM(DISCOUNT_VALUE),0) FROM dbo.ORDER_LINES_PROMO WHERE PROMO_CLASS=2 AND ORDER_NO=oh.ORDER_NO) as TotalPricingScheme	
		,(SELECT ISNULL(SUM(DISCOUNT_VALUE),0) FROM dbo.ORDER_LINES_PROMO WHERE PROMO_CLASS=3 AND ORDER_NO=oh.ORDER_NO) as TotalTacticalProgram
	from order_headers oh
		left join Order_Promotion_MatrixValue opmv on oh.ORDER_NO=opmv.ORDER_NO
		inner join Users on oh.USER_ID=users.User_ID
		inner join View_PositionOrg org on users.User_ID=org.salesRepID 
		inner join customers c on oh.customer_id=c.id 
		left join CUSTOMER_CHAINS cc on c.id=cc.customer_id left join CHAINS
		on cc.CHAINS_ID=CHAINS.id
		where (opmv.ORDER_NO is not null or exists (select 1 from ORDER_LINES_PROMO where order_no=oh.order_no group by order_no))
			and Confirmed_Date>='''+cast(@Date_From as nvarchar)+''' 
			and Confirmed_Date<'''+cast(@Date_To+1 as nvarchar)+'''
	'
	
	if ISNULL(@Country,-1)<>-1
		set @sql=@sql+' and org.countryID='+@Country
	if ISNULL(@Company,-1)<>-1
		set @sql=@sql+' and org.companyID='+@Company
	if ISNULL(@SalesOrg,-1)<>-1
		set @sql=@sql+' and org.salesOrgID='+@SalesOrg
	if ISNULL(@Salesoffice,-1)<>-1
		set @sql=@sql+' and org.salesOfficeID='+@Salesoffice
	if (ISNULL(@Manager,-1)<>-1 and exists (select user_id from users where manager_id=@Manager))
		set @sql=@sql+' and CHAINS.id in (select cc.chains_id from dbo.GetUserByManager('+@Manager+') u 
											inner join ROUTE_CUSTOMERS(nolock) rc on u.user_id=rc.user_id and rc.route_number=0 and valid=1
											inner join customer_chains(nolock) cc on rc.customer_id=cc.customer_id)
						and oh.USER_ID in(select * from dbo.GetUserByManager('+@Manager+'))'

	if ISNULL(@MDC,'-1')<>'-1'
		set @sql=@sql+' and cc.CHAINS_ID in ('+@MDC+')'

	IF ISNULL(@OrderType,-1)<>-1
		SET @sql=@sql+' and oh.OrderType='+@OrderType

	print (@sql)
	exec (@sql)
	
END