
with ol as (
		select t.*,p.qtyDiscounted,p.qtyDiscounted_CS,p.qtyDiscounted_EA,p.qtyDiscounted_EC
		from (
		select	oh.customer_id,oh.Confirmed_Date as oh_comfirmed,oh.user_id,oh.chain_id,ol.*
						--	,case when ol.Promotion_TypeID<>1
						--	--then (ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount))/ol.Quantity_Confirmed
						--	THEN (case when isnull(ol.Quantity_Confirmed,0)=0 then null else ol.SKU_DISC_AMOUNT/ol.Quantity_Confirmed end)
						--	when ol.Promotion_TypeID<>4
						--	THEN (case when isnull(ol.Quantity_Confirmed,0)=0 then null else ol.SKU_DISC_AMOUNT/ol.Quantity_Confirmed end)
						--	else null
						--end as discountPerCase
						,case when isnull(ol.Quantity_Confirmed,0)=0 then null else ol.SKU_DISC_AMOUNT/ol.Quantity_Confirmed end as discountPerCase
						--,case when ol.Promotion_TypeID<>1 
						--	--then ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount) 
						--	THEN ol.SKU_DISC_AMOUNT
						--	when ol.Promotion_TypeID<>4
						--	THEN ol.SKU_DISC_AMOUNT
						--	else null
						--end as totalDiscount
						,ol.SKU_DISC_AMOUNT as totalDiscount
						,(CASE oh.OrderType WHEN 0 THEN isnull(ol.Quantity_Confirmed,0)
							ELSE -isnull(ol.Quantity_Confirmed,0)
						END) as qtySold
						,(CASE oh.OrderType WHEN 0 THEN isnull(ol.Quantity_Confirmed_EC,0)
						ELSE -isnull(ol.Quantity_Confirmed_EC,0)
						END) as qtySold_ec
						--,case when ol.Promotion_TypeID = 4 then row_number()over(partition by ol.order_no,Promotion_id order by product_id desc) else 0 end as num
				from order_headers oh  with(index = [IDX_Order_Header_Comfirmed_Date])
					inner join ORDER_lines ol  with(index = [idx_orderNo]) 
						on ol.ORDER_NO=oh.ORDER_NO 
					and ol.OrderLineStatus=2 and isnull(ol.FREE_PRODUCTS,0)=0 and ol.Promotion_TypeID is not null
					where oh.Confirmed_Date>='Mar  1 2016 12:00AM' 
					and oh.Confirmed_Date<'Mar  3 2016 12:00AM'
		) t 
		left join (
		select	ol.order_no
		--,ol.promotion_id
		,ol.own_pro_id,sum(Quantity_Confirmed) as qtyDiscounted
			,case when ol.[UOM_CODE] = 'CS' then sum(Quantity_Confirmed) else null end as qtyDiscounted_CS
			,case when ol.[UOM_CODE] = 'EA' then sum(Quantity_Confirmed) else null end as qtyDiscounted_EA
			,sum(Quantity_Confirmed_EC) as qtyDiscounted_EC
					from order_headers oh  with(index = [IDX_Order_Header_Comfirmed_Date])
					inner join ORDER_lines ol  with(index = [idx_orderNo]) 
						on ol.ORDER_NO=oh.ORDER_NO 
					where oh.Confirmed_Date>='Mar  1 2016 12:00AM' 
					and oh.Confirmed_Date<'Mar  3 2016 12:00AM'
					and ol.FREE_PRODUCTS=2
		group by ol.order_no
		--,ol.promotion_id
		,own_pro_id,ol.[UOM_CODE]) p
		on t.order_no =p.order_no
		and t.product_id=isnull(p.own_pro_id,1)
		--and t.promotion_id = p.promotion_id
		--and case when t.Promotion_TypeID = 4 then num else t.product_id end = isnull(p.own_pro_id,1)
	)
		select      u.AreaCode
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
				,isnull(ol.Line_Disc_Amount,ol.Line_Amount) as salesValue
				--,ol.Promotion_TypeID
				,isnull(ol.Line_Disc_Amount,ol.Line_Amount) as salesValue
				,case when isnull(ol.promotion_ID,'')<>'' then (SELECT DISTINCT STUFF((SELECT ',' + TypeID FROM (select distinct case cast(TypeID as varchar) when '1' then 'Free cases'
																																									 when '2' then 'Percentage'
																																									 when '3' then 'Value discount'
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
				--,op.id promotionid
				,ol.promotion_ID as promotionid
				,ol.qtyDiscounted_CS
				,ol.qtyDiscounted_EA
				,ol.qtyDiscounted_EC
				,channel.CodeValue channelcode
				,channel.CodeDesc channelname
				,ol.Confirmed_Date
				--,(case ol.Promotion_TypeID 
				--	   when 3 then cast(ol.LINE_DISC_RATE as nvarchar)+'%'
				--	   when 6 then cast(ol.LINE_DISC_RATE as nvarchar)+'%'
				--  else ''
				--  end) as discount
				,cast(ol.LINE_DISC_RATE as nvarchar)+'%' as discount
		from ol
			inner join CUSTOMERS c  with(nolock) on ol.CUSTOMER_ID=c.ID
			inner join View_PositionOrg u with(nolock) on ol.USER_ID=u.salesRepID
			inner join PRODUCTS p with(nolock) on ol.PRODUCT_ID=p.ID
			left join ORDER_PROMOTION op  with(nolock) on ol.promotion_id=op.id
			left join CHAINS  with(nolock) on ol.CHAIN_ID=chains.ID
			left join sfaCodeDesc brand  with(nolock) on p.BRAND_CODE=brand.CodeValue
				and brand.CodeCategory='ProductBrand'
				and brand.CountryId = case when brand.CountryId='*' then brand.CountryId else cast(dbo.FN_GETParentID(c.org_id,1) as nvarchar) end
				and brand.SalesOrg = case when brand.SalesOrg='*' then brand.SalesOrg else cast(dbo.FN_GETParentID(c.org_id,3) as nvarchar) end
			left join sfaCodeDesc pack  with(nolock) on p.ProductGroupId=pack.CodeValue
				and pack.CodeCategory='ProductGroup'
				and pack.CountryId = case when pack.CountryId='*' then pack.CountryId else cast(dbo.FN_GETParentID(c.org_id,1) as nvarchar) end
				and pack.SalesOrg = case when pack.SalesOrg='*' then pack.SalesOrg else cast(dbo.FN_GETParentID(c.org_id,3) as nvarchar) end
			left join sfaCodeDesc channel  with(nolock) on c.TradeChannel=channel.CodeValue
				and channel.CodeCategory='TradeChannel'
				and channel.CountryId = case when channel.CountryId	= '*' then channel.CountryId else cast(dbo.FN_GETParentID(c.org_id,1) as nvarchar) end
				and channel.SalesOrg = case when channel.SalesOrg = '*' then channel.SalesOrg else cast(dbo.FN_GETParentID(c.org_id,3) as nvarchar) end			
		where 1=1
	 and u.countryID=8 and u.companyID=35 and u.salesOrgID=54 and u.salesOfficeID=80 and ol.CHAIN_ID in (922)
	 --AND ORDER_NO = '14421603010907061'
	 ORDER BY ORDER_NO