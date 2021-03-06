USE [CCVN4_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[Report_Order_Summary_SRI]    Script Date: 4/8/2016 10:39:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Kris He
-- Create date: 2011-02-16
-- Description:	Volume Target Tracking
-- modify by kevin.dai 2014-06-30 add ordertype
-- =============================================
ALTER PROCEDURE [dbo].[Report_Order_Summary_SRI]
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
	select	org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME as mdc_name
		,cc.CHAINS_CODE as mdc_code
		,p.DESCRIPTION as product
		,c.name as customer_name
		,c.code as customer_code
		,users.Name as salesRep
		,users.Code as salesRepCode
		,oh.order_no AS OrderNumber
		,charindex('';'',oh.PURCHASE_ORDER,1) AS PoNumber
		,MAX(oh.ORDER_date) AS order_date
		,oh.Additional_info AS DriverMessage
		,(CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed),0)
			ELSE isnull(SUM(-ol.Quantity_Confirmed),0)
		END) as qty
		,(CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed_ec),0)
			ELSE isnull(SUM(-ol.Quantity_Confirmed_ec),0)
		END) as qty_ec
		,ol.Promotion_Detail as promotion_type
		,ol.ReasonCode
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
		,p.code productcode
		,tc.codedesc chainscode
		,c.Cooler_Customer coolerCustomer
		,sd.codedesc RED
		,(case oh.ordertype when 0 then ''orders'' else ''trade returns'' end ) ordertype
	from 
		(select ORDER_date,PURCHASE_ORDER,Additional_info,order_no,OrderType,OrderTarget,USER_ID,customer_id,STATUS
		from order_headers (nolock)
		where substring(order_no,0,1)<>''M''
		and Confirmed_Date>='''+cast(@Date_From as nvarchar)+''' 
		and Confirmed_Date<'''+cast(@Date_To+1 as nvarchar)+'''
		)oh
		inner join order_lines ol with(nolock)
		on ol.order_no=oh.order_no inner join Users with(nolock)
		on oh.USER_ID=users.User_ID inner join View_PositionOrg org with(nolock)
		on users.User_ID=org.salesRepID inner join PRODUCTS p with(nolock)
		on ol.PRODUCT_ID=p.ID inner join customers c with(nolock)
		on oh.customer_id=c.id left join CUSTOMER_CHAINS cc with(nolock)
		on c.id=cc.customer_id left join CHAINS with(nolock)
		on cc.CHAINS_ID=CHAINS.id
		left join (select codevalue,codedesc from sfaCodeDesc  with(nolock)where CodeCategory=''Customer_Type'') sd on c.customer_type=sd.codevalue 
		left join (select codevalue,codedesc,countryID from sfaCodeDesc  with(nolock)where CodeCategory=''TradeChannel'') tc on ORG.countryID=TC.countryID AND c.TradeChannel=tc.codevalue 
	where isnull(ol.FREE_PRODUCTS,0)<>1 and (oh.STATUS = 6 or ol.OrderLineStatus=2)
		and ol.OrderLineStatus<>3	
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
	
	set @sql=@sql+'
	group by org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME,cc.CHAINS_CODE,p.DESCRIPTION,c.name,c.code,oh.order_no,oh.PURCHASE_ORDER,oh.Additional_info,ol.Promotion_Detail,ol.ReasonCode
		,oh.OrderType,users.Name,users.Code,ol.Promotion_TypeID,ol.LINE_DISC_RATE
		,oh.OrderTarget,ol.LINE_TAX_AMOUNT,ol.LINE_DISC_AMOUNT,p.code,CHAINS.code,c.Cooler_Customer,sd.codedesc,tc.codedesc
	order by org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME,c.name,p.DESCRIPTION
	'
	print (@sql)
	exec (@sql)
	
END