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
		,(case oh.ordertype when 0 then 'orders' else 'trade returns' end ) ordertype
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
			and Confirmed_Date BETWEEN '29Sep16' AND '30Sep16'