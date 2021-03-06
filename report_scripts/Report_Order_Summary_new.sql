USE [CCVN4_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[Report_Order_Summary]    Script Date: 4/8/2016 10:40:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Kris He
-- Create date: 2011-02-16
-- Description:	Volume Target Tracking
-- =============================================
ALTER procedure [dbo].[Report_Order_Summary]
	@Date_From			datetime,
	@Date_To			datetime,
	@Country			nvarchar(20),
	@Company			nvarchar(20),
	@SalesOrg			nvarchar(20),
	@Salesoffice		nvarchar(20),
	@MDC				nvarchar(20),
	@Manager			nvarchar(20)
	
AS
BEGIN	
	declare @sql as nvarchar(max)
	
	set @sql='
	select	org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME+'' - (''+cc.CHAINS_CODE+'')'' as mdc_name
		,p.DESCRIPTION as product
		,c.name+'' - (''+c.code+'')'' as customer_name
		,users.Name+'' - (''+users.Code+'')'' as salesRep
		,(CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed),0)
			ELSE isnull(SUM(-ol.Quantity_Confirmed),0)
		END) as qty
		,ol.Promotion_TypeID as promotion_type
		--,isnull(SUM(ol.LINE_AMOUNT),0) as list_price
		,(CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.LINE_AMOUNT),0)
			ELSE isnull(SUM(-ol.LINE_AMOUNT),0)
		END) as list_price
		,(case ol.Promotion_TypeID 
			when 3 then cast(ol.LINE_DISC_RATE as nvarchar)+''%''
		else cast(ol.LINE_DISC_RATE as nvarchar)
		end) as discount
		--,sum(ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount)) as discount_value
		,(CASE oh.OrderType WHEN 0 THEN sum(ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount))
			ELSE sum(-(ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount)))
		END) as discount_value
		,(case oh.OrderTarget when 0 then
			isnull(SUM(ol.LINE_DISC_AMOUNT*(LINE_TAX*1.0/100)),0) 
		else
			isnull(Line_Tax_Amount,0)-isnull(Line_Disc_Amount,0)
		end) as vat
		--,SUM(isnull(ol.Line_Disc_Amount,ol.Line_Amount)) as net_price
		,(CASE oh.OrderType WHEN 0 THEN SUM(isnull(ol.Line_Disc_Amount,ol.Line_Amount))
			ELSE SUM(-isnull(ol.Line_Disc_Amount,ol.Line_Amount))
		END) as net_price
		,,p.code productcode
		,CHAINS.code chainscode
		,c.Cooler_Customer coolerCustomer
		,sd.codedesc RED
	from ORDER_LINES_Month ol 
	inner join order_headers oh on ol.order_no=oh.order_no 
	inner join Users on oh.USER_ID=users.User_ID 
	inner join View_PositionOrg org on users.User_ID=org.salesRepID 
	inner join PRODUCTS p on ol.PRODUCT_ID=p.ID 
	inner join customers c on oh.customer_id=c.id 
	left join CUSTOMER_CHAINS cc on c.id=cc.customer_id 
	left join CHAINS on cc.CHAINS_ID=CHAINS.id
	left join (select codevalue,codedesc from sfaCodeDesc where CodeCategory=''Customer_Type'') sd on c.customer_type=sd.codevalue 
	where isnull(ol.FREE_PRODUCTS,0)<>1 and (oh.STATUS in (5,6) or ol.OrderLineStatus=2)
		and substring(oh.order_no,0,1)<>''M''
		and oh.Confirmed_Date>='''+cast(@Date_From as nvarchar)+''' 
		and oh.Confirmed_Date<'''+cast(@Date_To+1 as nvarchar)+'''
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
		set @sql=@sql+' and CHAINS.id in (select uc.chains_id from dbo.GetUserByManager('+@Manager+') u 
											inner join USER_CHAINS uc on u.user_id=uc.user_id) '

	if ISNULL(@MDC,-1)<>-1 
		set @sql=@sql+' and cc.CHAINS_ID ='+@MDC
	
	set @sql=@sql+'
	group by org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME,cc.CHAINS_CODE,p.DESCRIPTION,c.name,c.code
		,oh.OrderType,users.Name,users.Code,ol.Promotion_TypeID,ol.LINE_DISC_RATE
		,oh.OrderTarget,ol.LINE_TAX_AMOUNT,ol.LINE_DISC_AMOUNT,p.code
	order by org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME,c.name,p.DESCRIPTION
	'
	print (@sql)
	exec (@sql)
	
END

