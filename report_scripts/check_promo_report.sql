with ol as (
		select t.*,p.qtyDiscounted,p.qtyDiscounted_CS,p.qtyDiscounted_EA,p.qtyDiscounted_EC
		from (
		select	oh.customer_id,oh.Confirmed_Date as oh_comfirmed,oh.OrderType,oh.user_id,oh.chain_id,ol.*
						,case when isnull(ol.Quantity_Confirmed,0)=0 then null else ol.LINE_DISC_RATE end as discountPerCase
						,ol.LINE_DISC_RATE * ol.Quantity_Confirmed as totalDiscount
						,(CASE oh.OrderType WHEN 0 THEN isnull(ol.Quantity_Confirmed,0)
							ELSE -isnull(ol.Quantity_Confirmed,0)
						END) as qtySold
						,(CASE oh.OrderType WHEN 0 THEN isnull(ol.Quantity_Confirmed_EC,0)
						ELSE -isnull(ol.Quantity_Confirmed_EC,0)
						END) as qtySold_ec
						,(CASE ol.FREE_PRODUCTS WHEN 2 THEN 'Y' ELSE 'N' END) AS isFreeProduct
				from order_headers oh  with(index = [IDX_Order_Header_Comfirmed_Date])
					inner join ORDER_lines ol  with(index = [idx_orderNo]) 
						on ol.ORDER_NO=oh.ORDER_NO 
					and ol.OrderLineStatus=2 and (isnull(ol.FREE_PRODUCTS,0)=0 or ol.FREE_PRODUCTS=2)
					and ol.Promotion_id is not null
					where oh.Confirmed_Date>='Jan 11 2017 00:00' 
			--and oh.Confirmed_Date<'Jan 14 2017 00:00'
			--AND oh.order_no = '5241701131051211'
		) t 
		left join (
		select	ol.order_no,ol.own_pro_id,sum(Quantity_Confirmed) as qtyDiscounted
			,case when ol.[UOM_CODE] = 'CS' then sum(Quantity_Confirmed) else null end as qtyDiscounted_CS
			,case when ol.[UOM_CODE] = 'EA' then sum(Quantity_Confirmed) else null end as qtyDiscounted_EA
			,sum(Quantity_Confirmed_EC) as qtyDiscounted_EC
		from order_headers oh  with(index = [IDX_Order_Header_Comfirmed_Date])
			inner join ORDER_lines ol  with(index = [idx_orderNo]) on ol.ORDER_NO=oh.ORDER_NO 
		where oh.Confirmed_Date>='Jan 11 2017 00:00' 
			--and oh.Confirmed_Date<'Jan 14 2017 00:00'
			and ol.FREE_PRODUCTS=2
			--AND oh.order_no = '5241701131051211'
		group by ol.order_no,own_pro_id,ol.[UOM_CODE]
		) p
		on t.order_no =p.order_no
		and t.product_id=isnull(p.own_pro_id,1)
	)
		select u.countryID,u.companyID, u.salesOrgID,
		u.AreaCode
				,u.AreaManager
				,u.salesRep
				,u.salesRepCode
				,chains.DESCRIPTION as distributor
				,chains.code as distributor_code
				,c.name as customer
				,c.code as customer_code
				,brand.CodeDesc as brand
				,pack.CodeDesc as pack
				,p.DESCRIPTION as product
				,p.code as product_code
				,ol.ORDER_NO,ol.oh_comfirmed
				,ol.qtySold
				,ol.qtySold_ec
				,ol.isFreeProduct
				,isnull(ol.Line_Disc_Amount,ol.Line_Amount) as salesValue
				,case when isnull(ol.promotion_ID,'')<>'' then (SELECT DISTINCT STUFF((SELECT ',' + TypeID FROM (select distinct case cast(TypeID as varchar) when '1' then 'Free cases'
																																									 when '2' then 'Value Discount'
																																									 when '3' then 'Percentage Discount'
																																									 when '4' then 'Free Case (By Pack)'
																																									 when '5' then 'Value Discount (By Pack)'
																																									 when '6' then 'Percentage Discount(By Pack)'
																																									 else '' end as TypeID
				from [dbo].[FN_SPLIT](ol.promotion_ID,',') t
				inner join order_promotion op on op.id=t.a) subTitle FOR XML PATH('')),1, 1, '') AS TypeID
				 FROM (select distinct cast(op.TypeID as varchar) as TypeID from [dbo].[FN_SPLIT](ol.promotion_ID,',') t
				inner join order_promotion op on op.id=t.a)t)
				else '' end as Promotion_TypeID
				--,op.name as promotion_name
				,case when isnull(ol.promotion_ID,'')<>'' then (SELECT DISTINCT STUFF((SELECT ',' + NAME FROM (select distinct NAME
				from [dbo].[FN_SPLIT](ol.promotion_ID,',') t
				inner join order_promotion op on op.id=t.a) subTitle FOR XML PATH('')),1, 1, '') AS NAME
				 FROM (select distinct cast(op.NAME as varchar) as NAME from [dbo].[FN_SPLIT](ol.promotion_ID,',') t
				inner join order_promotion op on op.id=t.a)t)
				else '' end as promotion_name
				,ol.qtyDiscounted
				,ol.discountPerCase
				,ol.totalDiscount
				,ol.promotion_ID as promotionid
				,ol.qtyDiscounted_CS
				,ol.qtyDiscounted_EA
				,ol.qtyDiscounted_EC
				,channel.CodeValue channelcode
				,channel.CodeDesc channelname
				,ol.Confirmed_Date
				,CASE WHEN ol.Promotion_TypeID IN (3,6) THEN cast(ol.LINE_DISC_RATE as nvarchar)+'%' ELSE cast(ol.LINE_DISC_RATE as nvarchar) END as discount
		from ol
			inner join CUSTOMERS c  with(nolock) on ol.CUSTOMER_ID=c.ID
			inner join View_PositionOrg u with(nolock) on ol.USER_ID=u.salesRepID
			inner join PRODUCTS p with(nolock) on ol.PRODUCT_ID=p.ID
			left join ORDER_PROMOTION op  with(nolock) on ol.promotion_id=op.id
			left join CHAINS  with(nolock) on ol.CHAIN_ID=chains.ID
			left join sfaCodeDesc brand  with(nolock) on p.BRAND_CODE=brand.CodeValue
				and brand.CodeCategory='ProductBrand'
				and brand.CountryId = '8'
				and brand.SalesOrg = '136'
			left join sfaCodeDesc pack  with(nolock) on p.ProductGroupId=pack.CodeValue
				and pack.CodeCategory='ProductGroup'
				and pack.CountryId = '8'
				and pack.SalesOrg = '136'
			left join sfaCodeDesc channel  with(nolock) on c.TradeChannel=channel.CodeValue
				and channel.CodeCategory='TradeChannel'
				and channel.CountryId = '8'
				and channel.SalesOrg = '136'
		where 1=1
	 and u.countryID=8 AND u.salesOrgID=136
	 --AND ol.Promotion_TypeID = 4
	 --AND ol.order_no = '5241701131051211'
	 AND promotion_id IN ('1533','1532','1523','1522')