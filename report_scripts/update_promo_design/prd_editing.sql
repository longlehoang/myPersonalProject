USE [CCVN4_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_syn_visit_data]    Script Date: 10/13/2016 4:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Procedure
ALTER PROCEDURE [dbo].[sp_syn_visit_data]
AS
    DECLARE @lasttime DATETIME ,
        @newlasttime DATETIME ,
        @error_number INT ,
        @error_code INT ,
        @error_message NVARCHAR(2000)
    BEGIN
        BEGIN TRY
            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
            BEGIN TRAN sp_visitdata_int

            SET @error_number = 100100
            SET @lasttime = GETDATE()
            SET @newlasttime = CONVERT(VARCHAR(10), GETDATE(), 120) + ' '
                + CAST(DATEPART(hour, GETDATE()) AS VARCHAR) + ':'
                + ( CASE WHEN DATEPART(minute, GETDATE()) >= 30 THEN '30:00'
                         ELSE '00:00'
                    END )
            SET @error_number = 100120
            SELECT  @lasttime = lasttime
            FROM    interfacetime
            WHERE   tablename = 'visits'

            SET @error_number = 100130
            IF ( DATEDIFF(n, @lasttime, GETDATE()) = 0 )
                BEGIN
                    SET @error_number = 100140
                    INSERT  INTO visits
                            SELECT  *
                            FROM    [10.0.0.6].CCVN4.dbo.visits v WITH ( NOLOCK )
                            WHERE   v.rec_time_stamp < @newlasttime

                    SET @error_number = 100150
                    INSERT  INTO interfacetime
                            ( tablename, lasttime )
                    VALUES  ( 'visits', @newlasttime )
                END
            ELSE
                BEGIN
                    SET @error_number = 100160
                    INSERT  INTO visits
                            SELECT  *
                            FROM    [10.0.0.6].CCVN4.dbo.visits v WITH ( NOLOCK )
                            WHERE   v.rec_time_stamp BETWEEN @lasttime
                                                     AND     @newlasttime
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   visits oh
                                                     WHERE  v.id = oh.id
                                                            --AND DATEDIFF(day,
                                                            --  oh.rec_time_stamp,
                                                            --  GETDATE()) <= 7 
															  )

                    SET @error_number = 100170
                    UPDATE  interfacetime
                    SET     lasttime = @newlasttime
                    WHERE   tablename = 'visits'
                END

            SET @error_number = 100400
            SET @lasttime = GETDATE()
            SET @newlasttime = CAST(SUBSTRING(CONVERT(VARCHAR(20), GETDATE(), 20),
                                              1,
                                              CHARINDEX(':',
                                                        CONVERT(VARCHAR(20), GETDATE(), 20)))
                + '00:00' AS DATETIME)
            SET @error_number = 100420
            SELECT  @lasttime = lasttime
            FROM    interfacetime
            WHERE   tablename = 'measure_transactions'

            SET @error_number = 100430
            IF ( DATEDIFF(n, @lasttime, GETDATE()) = 0 )
                BEGIN
                    SET @error_number = 100440
                    INSERT  INTO measure_transactions
                            SELECT  *
                            FROM    [10.0.0.6].CCVN4.dbo.measure_transactions v
                                    WITH ( NOLOCK )
                            WHERE   v.rec_time_stamp < @newlasttime

                    SET @error_number = 100450
                    INSERT  INTO interfacetime
                            ( tablename ,
                              lasttime
                            )
                    VALUES  ( 'measure_transactions' ,
                              @newlasttime
                            )
                END
            ELSE
                BEGIN
                    SET @error_number = 100460
                    INSERT  INTO measure_transactions
                            SELECT  *
                            FROM    [10.0.0.6].CCVN4.dbo.measure_transactions v
                                    WITH ( NOLOCK )
                            WHERE   v.rec_time_stamp BETWEEN @lasttime
                                                     AND     @newlasttime
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   measure_transactions oh
                                                     WHERE  v.id = oh.id
                                                            AND DATEDIFF(day,
                                                              oh.rec_time_stamp,
                                                              GETDATE()) <= 7 )

                    SET @error_number = 100470
                    UPDATE  interfacetime
                    SET     lasttime = @newlasttime
                    WHERE   tablename = 'measure_transactions'
                END
	/*--拜访客户库存
	set @error_number=100500
    set @lasttime=getdate()
    set @newlasttime=cast(substring(convert(varchar(20),getdate(),20),1,CHARINDEX(':',convert(varchar(20),getdate(),20)))+'00:00' as datetime)
	set @error_number=100510
	select @lasttime=lasttime 
	from interfacetime
	where tablename='customer_stock_check'

	set @error_number=100520
	if(datediff(n,@lasttime,getdate())=0)
	begin
		set @error_number=100530
		insert into customer_stock_check
		select * from [10.0.0.6].CCVN4.dbo.customer_stock_check v with (nolock)
		where v.rec_time_stamp<@newlasttime

		set @error_number=100540
		insert into interfacetime(tablename,lasttime)
		values('customer_stock_check',@newlasttime)
    end
	else
	begin
		set @error_number=100550
		insert into customer_stock_check
        select * from [10.0.0.6].CCVN4.dbo.customer_stock_check v with (nolock)
		where v.rec_time_stamp between @lasttime and @newlasttime
		and not exists (select 'X' from customer_stock_check oh
						where v.visit_id=oh.visit_id
						and v.product_id=oh.product_id
						and datediff(day,oh.rec_time_stamp,getdate())<=7)

		set @error_number=100560
		update interfacetime set lasttime=@newlasttime
		where tablename='customer_stock_check'
	end*/

            SET @error_number = 100180
            SET @lasttime = GETDATE()
            SELECT  @lasttime = lasttime
            FROM    interfacetime
            WHERE   tablename = 'order_headers'


            SET @error_number = 100190
            IF ( DATEDIFF(n, @lasttime, GETDATE()) = 0 )
                BEGIN
                    SET @error_number = 100200
                    UPDATE  order_headers
                    SET     req_delivery_date = so.req_delivery_date
								 --,dlv_block=so.dlv_block
                            ,
                            ordertype = so.ordertype ,
                            total_amount = so.total_amount ,
                            total_quantity = so.total_quantity ,
                            confirmed_Date = so.confirmed_date ,
                            status = so.status ,
                            Confirm_user_code = so.Confirm_user_code ,
                            orderTarget = so.orderTarget ,
                            OrderStatusText = so.OrderStatusText ,
                            sapcustomerid = so.sapcustomerid ,
                            rec_time_stamp = so.rec_time_stamp ,
                            rec_user_code = so.rec_user_code
                    FROM    [10.0.0.6].CCVN4.dbo.order_headers so WITH ( NOLOCK )
                    WHERE   so.order_no = order_headers.order_no
                            AND so.rec_time_stamp < @newlasttime

                    SET @error_number = 100210
                    INSERT  INTO order_headers
                            SELECT  so.*
                            FROM    [10.0.0.6].CCVN4.dbo.order_headers so WITH ( NOLOCK )
                            WHERE   so.rec_time_stamp < @newlasttime
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   order_headers oh
                                                     WHERE  so.order_no = oh.order_no
                                                            AND DATEDIFF(day,
                                                              oh.rec_time_stamp,
                                                              GETDATE()) <= 7 )

		/*update order_headers set Reject_status=1
		where order_no in(select distinct order_no from [10.0.0.6].CCVN4.dbo.order_lines
						  where rec_time_stamp<@newlasttime
						  and REASON_REJ<>''
						  and REASON_REJ is not null)*/
		
                    SET @error_number = 100220
                    INSERT  INTO interfacetime
                            ( tablename, lasttime )
                    VALUES  ( 'order_headers', @newlasttime )
                END
            ELSE
                BEGIN
                    SET @error_number = 100230
                    UPDATE  order_headers
                    SET     req_delivery_date = so.req_delivery_date
								 --,dlv_block=so.dlv_block
                            ,
                            ordertype = so.ordertype ,
                            total_amount = so.total_amount ,
                            total_quantity = so.total_quantity ,
                            confirmed_Date = so.confirmed_date ,
                            status = so.status ,
                            Confirm_user_code = so.Confirm_user_code ,
                            orderTarget = so.orderTarget ,
                            OrderStatusText = so.OrderStatusText ,
                            sapcustomerid = so.sapcustomerid ,
                            rec_time_stamp = so.rec_time_stamp ,
                            rec_user_code = so.rec_user_code
                    FROM    [10.0.0.6].CCVN4.dbo.order_headers so
                    WHERE   so.order_no = order_headers.order_no
                            AND so.rec_time_stamp BETWEEN @lasttime
                                                  AND     @newlasttime

		/*update order_headers set Reject_status=1
		where order_no in(select distinct order_no from [10.0.0.6].CCVN4.dbo.order_lines
						  where rec_time_stamp between @lasttime and @newlasttime
						  and REASON_REJ<>''
						  and REASON_REJ is not null)*/

                    SET @error_number = 100240
                    INSERT  INTO order_headers
                            SELECT  so.*
                            FROM    [10.0.0.6].CCVN4.dbo.order_headers so WITH ( NOLOCK )
                            WHERE   so.rec_time_stamp BETWEEN @lasttime
                                                      AND     @newlasttime
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   order_headers oh
                                                     WHERE  so.order_no = oh.order_no
                                                            AND DATEDIFF(day,
                                                              oh.rec_time_stamp,
                                                              GETDATE()) <= 7 )
	
                    SET @error_number = 100250
                    UPDATE  interfacetime
                    SET     lasttime = @newlasttime
                    WHERE   tablename = 'order_headers'
                END
	
	--set @error_number=100260
	--set @lasttime=getdate()
	--select @lasttime=lasttime 
	--from interfacetime
	--where tablename='order_headers'

	/*导入ORDER_LINES数据*/
            SET @error_number = 100270
			/*
			ORDER_LINES
			*/
			CREATE TABLE #temp_order_line(
				[ID] [numeric](20, 0) null,
				[ORDER_NO] [varchar](30) collate Latin1_General_CI_AS,
				[PRODUCT_ID] [int]null,
				[UOM_CODE] [varchar](3) collate Latin1_General_CI_AS,
				[UNIT_PRICE] [numeric](15, 4) NULL,
				[PRODUCT_CODE] [varchar](18)  collate Latin1_General_CI_AS,
				[QUANTITY_ORDERED] [numeric](8, 0) NULL,
				[QUANTITY_SHIPPED] [numeric](8, 0) NULL,
				[LINE_AMOUNT] [numeric](15, 4) NULL,
				[LINE_DISC_RATE] [numeric](15, 2) NULL,
				[LINE_DISC_AMOUNT] [numeric](15, 4) NULL,
				[LINE_TAX] [numeric](15, 4) NULL,
				[LINE_TAX_AMOUNT] [numeric](15, 4) NULL,
				[SKU_DISC_RATE] [numeric](5, 2) NULL,
				[SKU_DISC_AMOUNT] [numeric](15, 4) NULL,
				[DOMAIN_ID] [numeric](10, 0)null,
				[REC_USER_CODE] [nvarchar](50)  collate Latin1_General_CI_AS,
				[REC_TIME_STAMP] [datetime] NULL,
				[CANCELLED] [char](1)  collate Latin1_General_CI_AS,
				[FREE_PRODUCTS] [int] NULL,
				[DISC_1] [numeric](15, 4) NULL,
				[DISC_2] [numeric](15, 4) NULL,
				[Quantity_Received] [numeric](8, 0) NULL,
				[own_pro_id] [int] NULL,
				[ARRIVAL_date] [datetime] NULL,
				[Confirm_user_code] [nvarchar](20)  collate Latin1_General_CI_AS,
				[Confirmed_Date] [datetime] NULL,
				[OrderLineStatus] [numeric](2, 0) NULL,
				[promotion_id] [nvarchar](500)  collate Latin1_General_CI_AS,
				[Quantity_Confirmed] [numeric](13, 3) NULL,
				[ItemNO] [int] NULL,
				[ReasonCode] [nvarchar](50) NULL,
				[Promotion_TypeID] [int] NULL,
				[Promotion_Detail] [nvarchar](2000)  collate Latin1_General_CI_AS,
				[PROMOTION_REASON] [nvarchar](50)  collate Latin1_General_CI_AS,
				[Quantity_Confirmed_EC] [decimal](13, 3) NULL,
				[EquivalentCases] [decimal](13, 3) NULL
			)

            IF ( DATEDIFF(n, @lasttime, GETDATE()) = 0 )
            BEGIN
				insert into #temp_order_line
				select ol.*,p.EquivalentCases 
				from [10.0.0.6].CCVN4.dbo.order_lines ol 
					inner join [10.0.0.6].CCVN4.dbo.PRODUCTS p on ol.PRODUCT_ID = p.ID
					inner join [10.0.0.6].CCVN4.dbo.order_headers oh on ol.order_no = oh.order_no 
					AND oh.rec_time_stamp < @newlasttime
	
				SET @error_number = 100280
                    INSERT  INTO order_lines
                            ( id ,
                              order_no ,
                              product_id ,
                              uom_code ,
                              product_code ,
                              quantity_ordered ,
                              LINE_TAX ,
                              LINE_TAX_AMOUNT ,
                              quantity_shipped ,
                              line_amount ,
                              LINE_DISC_RATE ,
                              LINE_DISC_AMOUNT ,
                              SKU_DISC_RATE ,
                              SKU_DISC_AMOUNT ,
                              domain_id ,
                              rec_user_code ,
                              rec_time_stamp ,
                              CANCELLED ,
                              FREE_PRODUCTS ,
                              DISC_1 ,
                              DISC_2 ,
                              Quantity_Received ,
                              own_pro_id ,
                              ARRIVAL_date ,
                              Confirm_user_code ,
                              Confirmed_Date ,
                              OrderLineStatus ,
                              promotion_id ,
                              quantity_Confirmed ,
                              ol.ItemNO ,
                              ol.ReasonCode ,
                              UNIT_PRICE ,
                              Promotion_TypeID ,
                              Promotion_Detail ,
                              PROMOTION_REASON
							  ,Quantity_Confirmed_EC
                            )
                            SELECT  id ,
                                    dq.order_no ,
                                    dq.product_id ,
                                    uom_code ,
                                    product_code ,
                                    quantity_ordered ,
                                    LINE_TAX ,
                                    LINE_TAX_AMOUNT ,
                                    quantity_shipped ,
                                    line_amount ,
                                    LINE_DISC_RATE ,
                                    LINE_DISC_AMOUNT ,
                                    SKU_DISC_RATE ,
                                    OPD.DISCOUNTMONEY ,
                                    domain_id ,
                                    rec_user_code ,
                                    rec_time_stamp ,
                                    CANCELLED ,
                                    FREE_PRODUCTS ,
                                    DISC_1 ,
                                    DISC_2 ,
                                    Quantity_Received ,
                                    own_pro_id ,
                                    ARRIVAL_date ,
                                    Confirm_user_code ,
                                    Confirmed_Date ,
                                    OrderLineStatus ,
                                    promotion_id ,
                                    quantity_Confirmed ,
                                    dq.ItemNO ,
                                    dq.ReasonCode ,
                                    UNIT_PRICE ,
                                    Promotion_TypeID ,
                                    Promotion_Detail ,
                                    dq.PROMOTION_REASON ,
                                     Quantity_Confirmed_EC
                            FROM    /*( SELECT  MAX(id) AS id ,order_no , product_id,'CS' AS uom_code ,product_code ,SUM(quantity_ordered) AS quantity_ordered ,MAX(LINE_TAX) AS line_tax ,SUM(LINE_TAX_AMOUNT) AS LINE_TAX_AMOUNT ,
											SUM(quantity_shipped) AS quantity_shipped ,SUM(line_amount) AS line_amount ,SUM(LINE_DISC_RATE) AS LINE_DISC_RATE ,SUM(LINE_DISC_AMOUNT) AS LINE_DISC_AMOUNT ,
											SUM(SKU_DISC_RATE) AS SKU_DISC_RATE ,SUM(SKU_DISC_AMOUNT) AS SKU_DISC_AMOUNT ,domain_id ,MAX(rec_user_code) AS rec_user_code ,
											MAX(rec_time_stamp) AS rec_time_stamp ,MAX(CANCELLED) AS CANCELLED ,MAX(FREE_PRODUCTS) AS FREE_PRODUCTS ,SUM(DISC_1) AS DISC_1 ,
											SUM(DISC_2) AS DISC_2 ,SUM(Quantity_Received) AS Quantity_Received ,MAX(own_pro_id) own_pro_id ,MAX(ARRIVAL_date) ARRIVAL_date ,
											MAX(Confirm_user_code) Confirm_user_code ,MAX(Confirmed_Date) Confirmed_Date ,MAX(OrderLineStatus) OrderLineStatus ,
											MAX(promotion_id) promotion_id ,
											SUM(quantity_Confirmed) quantity_Confirmed ,MAX(ItemNO) ItemNO ,MAX(ReasonCode) ReasonCode ,MAX(UNIT_PRICE) AS unit_price ,
											MAX(Promotion_TypeID) AS Promotion_TypeID ,MAX(Promotion_Detail) AS Promotion_Detail ,MAX(PROMOTION_REASON) AS PROMOTION_REASON,
											ISNULL(SUM(quantity_Confirmed) * ( ISNULL(MAX(EquivalentCases), 0) ),0) Quantity_Confirmed_EC
										FROM */   
											( SELECT ol.id ,ol.order_no ,ol.product_id ,'CS' AS uom_code ,ol.product_code 
												  ,case when ol.uom_code='CS' then ol.quantity_ordered else  ol.quantity_ordered/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_ordered
												  ,ol.quantity_shipped ,ol.LINE_TAX ,ol.LINE_TAX_AMOUNT ,ol.line_amount ,ol.line_disc_rate ,ol.line_disc_amount ,ol.sku_disc_rate ,ol.sku_disc_amount ,
												  ol.domain_id ,ol.rec_user_code ,ol.rec_time_stamp ,ol.cancelled ,ol.free_products ,ol.disc_1 ,ol.disc_2 
												  ,case when ol.uom_code='CS' then ol.quantity_received else  ol.quantity_received/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_received ,
												  ol.own_pro_id ,ol.arrival_date ,ol.confirm_user_code ,ol.confirmed_date ,ol.orderlinestatus ,ol.promotion_id ,
												  case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_Confirmed ,
												  ol.ItemNO ,ol.ReasonCode ,ol.UNIT_PRICE ,ol.Promotion_TypeID ,ol.Promotion_Detail ,ol.PROMOTION_REASON,case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end * ol.EquivalentCases
											  FROM #temp_order_line ol left join [10.0.0.6].CCVN4.dbo.Product_UOMS pu on ol.PRODUCT_id = pu.PRODUCT_ID
											  WHERE  ol.FREE_PRODUCTS <> 2
											--and ol.item_categ='ZN11'
											  AND NOT EXISTS ( SELECT 'X'
																FROM order_lines
																WHERE ol.order_no = order_lines.order_no
																AND ol.product_id = order_lines.product_id
																AND order_lines.FREE_PRODUCTS <> 2
																AND DATEDIFF(day,
																rec_Time_stamp,
																GETDATE()) <= 7 )
											  /*) t

										GROUP BY order_no ,
												product_id ,
												domain_id ,
												product_code*/
                                    ) DQ
                                    LEFT JOIN [10.0.0.6].CCVN4.dbo.Order_Promotion_DiscValue opd ( NOLOCK ) ON opd.Order_NO = DQ.ORDER_NO
                                                              AND opd.PRODUCT_ID = DQ.PRODUCT_ID 

			
			
			
                    INSERT  INTO order_lines
                            ( id ,
                              order_no ,
                              product_id ,
                              uom_code ,
                              product_code ,
                              quantity_ordered ,
                              LINE_TAX ,
                              LINE_TAX_AMOUNT ,
                              quantity_shipped ,
                              line_amount ,
                              LINE_DISC_RATE ,
                              LINE_DISC_AMOUNT ,
                              SKU_DISC_RATE ,
                              SKU_DISC_AMOUNT ,
                              domain_id ,
                              rec_user_code ,
                              rec_time_stamp ,
                              CANCELLED ,
                              FREE_PRODUCTS ,
                              DISC_1 ,
                              DISC_2 ,
                              Quantity_Received ,
                              own_pro_id ,
                              ARRIVAL_date ,
                              Confirm_user_code ,
                              Confirmed_Date ,
                              OrderLineStatus ,
                              promotion_id ,
                              quantity_Confirmed ,
                              ol.ItemNO ,
                              ol.ReasonCode ,
                              UNIT_PRICE ,
                              Promotion_TypeID ,
                              Promotion_Detail ,
                              PROMOTION_REASON
							  ,Quantity_Confirmed_EC
                            )
                           /*SELECT  MAX(id) AS id ,order_no , product_id,'CS' AS uom_code ,product_code ,SUM(quantity_ordered) AS quantity_ordered ,MAX(LINE_TAX) AS line_tax ,SUM(LINE_TAX_AMOUNT) AS LINE_TAX_AMOUNT ,
								SUM(quantity_shipped) AS quantity_shipped ,SUM(line_amount) AS line_amount ,SUM(LINE_DISC_RATE) AS LINE_DISC_RATE ,SUM(LINE_DISC_AMOUNT) AS LINE_DISC_AMOUNT ,
								SUM(SKU_DISC_RATE) AS SKU_DISC_RATE ,SUM(SKU_DISC_AMOUNT) AS SKU_DISC_AMOUNT ,domain_id ,MAX(rec_user_code) AS rec_user_code ,
								MAX(rec_time_stamp) AS rec_time_stamp ,MAX(CANCELLED) AS CANCELLED ,MAX(FREE_PRODUCTS) AS FREE_PRODUCTS ,SUM(DISC_1) AS DISC_1 ,
								SUM(DISC_2) AS DISC_2 ,SUM(Quantity_Received) AS Quantity_Received ,MAX(own_pro_id) own_pro_id ,MAX(ARRIVAL_date) ARRIVAL_date ,
								MAX(Confirm_user_code) Confirm_user_code ,MAX(Confirmed_Date) Confirmed_Date ,MAX(OrderLineStatus) OrderLineStatus ,
								MAX(promotion_id) promotion_id ,
								SUM(quantity_Confirmed) quantity_Confirmed ,MAX(ItemNO) ItemNO ,MAX(ReasonCode) ReasonCode ,MAX(UNIT_PRICE) AS unit_price ,
								MAX(Promotion_TypeID) AS Promotion_TypeID ,MAX(Promotion_Detail) AS Promotion_Detail ,MAX(PROMOTION_REASON) AS PROMOTION_REASON,
								ISNULL(SUM(quantity_Confirmed) * ( ISNULL(MAX(EquivalentCases), 0) ),0) Quantity_Confirmed_EC
							FROM    
								(*/ SELECT ol.id ,ol.order_no ,ol.product_id ,'CS' AS uom_code ,ol.product_code 
									  ,case when ol.uom_code='CS' then ol.quantity_ordered else  ol.quantity_ordered/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_ordered
									  ,ol.quantity_shipped ,ol.LINE_TAX ,ol.LINE_TAX_AMOUNT ,ol.line_amount ,ol.line_disc_rate ,ol.line_disc_amount ,ol.sku_disc_rate ,ol.sku_disc_amount ,
									  ol.domain_id ,ol.rec_user_code ,ol.rec_time_stamp ,ol.cancelled ,ol.free_products ,ol.disc_1 ,ol.disc_2 
									  ,case when ol.uom_code='CS' then ol.quantity_received else  ol.quantity_received/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_received ,
									  ol.own_pro_id ,ol.arrival_date ,ol.confirm_user_code ,ol.confirmed_date ,ol.orderlinestatus ,ol.promotion_id ,
									  case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_Confirmed ,
									  ol.ItemNO ,ol.ReasonCode ,ol.UNIT_PRICE ,ol.Promotion_TypeID ,ol.Promotion_Detail ,ol.PROMOTION_REASON,case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end * ol.EquivalentCases
								  FROM #temp_order_line ol left join [10.0.0.6].CCVN4.dbo.Product_UOMS pu on ol.PRODUCT_id = pu.PRODUCT_ID
								  WHERE  ol.FREE_PRODUCTS = 2
								--and ol.item_categ='ZN11'
								  AND NOT EXISTS ( SELECT 'X'
													FROM order_lines
													WHERE ol.order_no = order_lines.order_no
													AND ol.product_id = order_lines.product_id
													AND order_lines.FREE_PRODUCTS <> 2
													AND DATEDIFF(day,
													rec_Time_stamp,
													GETDATE()) <= 7 )
								  /*) t
							GROUP BY order_no ,
									product_id ,
									domain_id ,
									product_code*/
      
                    SET @error_number = 100281
                    UPDATE  ORDER_LINES
                    SET     SKU_DISC_AMOUNT = A.DISCOUNTMONEY
                    FROM    Order_Promotion_DiscValue A
                    WHERE   ORDER_LINES.ORDER_NO = A.Order_NO
                            AND ORDER_LINES.PRODUCT_ID = A.PRODUCT_ID
                            AND ORDER_LINES.rec_time_stamp < @newlasttime

					SET @error_number = 100282
					/*Update ol set promotion_id = t.promotion_id
					from ORDER_LINES ol,
						(select order_no,product_id,(select distinct promotion_id+','from #temp_order_line
														where order_no = t.ORDER_NO
														and product_id = t.product_id 
														and promotion_id is not null and FREE_PRODUCTS=2
														for xml path('')) as promotion_id 
					    from #temp_order_line t
						where promotion_id is not null
						group by order_no,product_id )t
					where ol.ORDER_NO = t.ORDER_NO
					and ol.PRODUCT_ID = t.PRODUCT_ID
					and ol.FREE_PRODUCTS =2*/
				
		/*insert into interfacetime(tablename,lasttime)
		values('order_lines',@newlasttime)*/
                END
            ELSE
                BEGIN
					insert into #temp_order_line
					select ol.*,p.EquivalentCases 
					from [10.0.0.6].CCVN4.dbo.order_lines ol 
						inner join [10.0.0.6].CCVN4.dbo.PRODUCTS p on ol.PRODUCT_ID = p.ID
						inner join [10.0.0.6].CCVN4.dbo.order_headers oh on ol.order_no = oh.order_no 
						AND oh.rec_time_stamp BETWEEN @lasttime AND @newlasttime
		
                    SET @error_number = 100290
                    DELETE  FROM order_lines
                    WHERE   order_no IN (
                            SELECT distinct order_no collate Latin1_General_CI_AS
                            FROM    #temp_order_line )

                    SET @error_number = 100300
		
                    PRINT @lasttime
                    PRINT @newlasttime
		
                    INSERT  INTO order_lines
							( id ,
                              order_no ,
                              product_id ,
                              uom_code ,
                              product_code ,
                              quantity_ordered ,
                              LINE_TAX ,
                              LINE_TAX_AMOUNT ,
                              quantity_shipped ,
                              line_amount ,
                              LINE_DISC_RATE ,
                              LINE_DISC_AMOUNT ,
                              SKU_DISC_RATE ,
                              SKU_DISC_AMOUNT ,
                              domain_id ,
                              rec_user_code ,
                              rec_time_stamp ,
                              CANCELLED ,
                              FREE_PRODUCTS ,
                              DISC_1 ,
                              DISC_2 ,
                              Quantity_Received ,
                              own_pro_id ,
                              ARRIVAL_date ,
                              Confirm_user_code ,
                              Confirmed_Date ,
                              OrderLineStatus ,
                              promotion_id ,
                              quantity_Confirmed ,
                              ol.ItemNO ,
                              ol.ReasonCode ,
                              UNIT_PRICE ,
                              Promotion_TypeID ,
                              Promotion_Detail ,
                              PROMOTION_REASON
			     ,Quantity_Confirmed_EC
                            )

                        /*SELECT  MAX(id) AS id ,order_no , product_id,'CS' AS uom_code ,product_code ,SUM(quantity_ordered) AS quantity_ordered ,MAX(LINE_TAX) AS line_tax ,SUM(LINE_TAX_AMOUNT) AS LINE_TAX_AMOUNT ,
							SUM(quantity_shipped) AS quantity_shipped ,SUM(line_amount) AS line_amount ,SUM(LINE_DISC_RATE) AS LINE_DISC_RATE ,SUM(LINE_DISC_AMOUNT) AS LINE_DISC_AMOUNT ,
							SUM(SKU_DISC_RATE) AS SKU_DISC_RATE ,SUM(SKU_DISC_AMOUNT) AS SKU_DISC_AMOUNT ,domain_id ,MAX(rec_user_code) AS rec_user_code ,
							MAX(rec_time_stamp) AS rec_time_stamp ,MAX(CANCELLED) AS CANCELLED ,MAX(FREE_PRODUCTS) AS FREE_PRODUCTS ,SUM(DISC_1) AS DISC_1 ,
							SUM(DISC_2) AS DISC_2 ,SUM(Quantity_Received) AS Quantity_Received ,MAX(own_pro_id) own_pro_id ,MAX(ARRIVAL_date) ARRIVAL_date ,
							MAX(Confirm_user_code) Confirm_user_code ,MAX(Confirmed_Date) Confirmed_Date ,MAX(OrderLineStatus) OrderLineStatus ,
							MAX(promotion_id) promotion_id ,
							SUM(quantity_Confirmed) quantity_Confirmed ,MAX(ItemNO) ItemNO ,MAX(ReasonCode) ReasonCode ,MAX(UNIT_PRICE) AS unit_price ,
							MAX(Promotion_TypeID) AS Promotion_TypeID ,MAX(Promotion_Detail) AS Promotion_Detail ,MAX(PROMOTION_REASON) AS PROMOTION_REASON,
							ISNULL(SUM(quantity_Confirmed) * ( ISNULL(MAX(EquivalentCases), 0) ),0) Quantity_Confirmed_EC
						FROM    
							(*/ SELECT ol.id ,ol.order_no ,ol.product_id ,'CS' AS uom_code ,ol.product_code 
									,case when ol.uom_code='CS' then ol.quantity_ordered else  ol.quantity_ordered/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_ordered
									,ol.quantity_shipped ,ol.LINE_TAX ,ol.LINE_TAX_AMOUNT ,ol.line_amount ,ol.line_disc_rate ,ol.line_disc_amount ,ol.sku_disc_rate ,ol.sku_disc_amount ,
									ol.domain_id ,ol.rec_user_code ,ol.rec_time_stamp ,ol.cancelled ,ol.free_products ,ol.disc_1 ,ol.disc_2 
									,case when ol.uom_code='CS' then ol.quantity_received else  ol.quantity_received/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_received ,
									ol.own_pro_id ,ol.arrival_date ,ol.confirm_user_code ,ol.confirmed_date ,ol.orderlinestatus ,ol.promotion_id ,
									case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_Confirmed ,
									ol.ItemNO ,ol.ReasonCode ,ol.UNIT_PRICE ,ol.Promotion_TypeID ,ol.Promotion_Detail ,ol.PROMOTION_REASON,case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end * ol.EquivalentCases
								FROM #temp_order_line ol left join [10.0.0.6].CCVN4.dbo.Product_UOMS pu on ol.PRODUCT_id = pu.PRODUCT_ID
								WHERE  ol.FREE_PRODUCTS <> 2
							--and ol.item_categ='ZN11'
								AND NOT EXISTS ( SELECT 'X'
												FROM order_lines
												WHERE ol.order_no = order_lines.order_no
												AND ol.product_id = order_lines.product_id
												AND order_lines.FREE_PRODUCTS <> 2
												AND DATEDIFF(day,
												rec_Time_stamp,
												GETDATE()) <= 180 )
								/*) t
						GROUP BY order_no ,
								product_id ,
								domain_id ,
								product_code*/


                    INSERT  INTO order_lines

                            ( id ,
                              order_no ,
                              product_id ,
                              uom_code ,
                              product_code ,
                              quantity_ordered ,
                              LINE_TAX ,
                              LINE_TAX_AMOUNT ,
                              quantity_shipped ,
                              line_amount ,
                              LINE_DISC_RATE ,
                              LINE_DISC_AMOUNT ,
                              SKU_DISC_RATE ,
                              SKU_DISC_AMOUNT ,
                              domain_id ,
                              rec_user_code ,
                              rec_time_stamp ,
                              CANCELLED ,
                              FREE_PRODUCTS ,
                              DISC_1 ,
                              DISC_2 ,
                              Quantity_Received ,
                              own_pro_id ,
                              ARRIVAL_date ,
                              Confirm_user_code ,
                              Confirmed_Date ,
                              OrderLineStatus ,
                              promotion_id ,
                              quantity_Confirmed ,
                              ol.ItemNO ,
                              ol.ReasonCode ,
                              UNIT_PRICE ,
                              Promotion_TypeID ,
                              Promotion_Detail ,
                              PROMOTION_REASON
			      ,Quantity_Confirmed_EC
                            )

                            /*SELECT  MAX(id) AS id ,order_no , product_id,'CS' AS uom_code ,product_code ,SUM(quantity_ordered) AS quantity_ordered ,MAX(LINE_TAX) AS line_tax ,SUM(LINE_TAX_AMOUNT) AS LINE_TAX_AMOUNT ,
								SUM(quantity_shipped) AS quantity_shipped ,SUM(line_amount) AS line_amount ,SUM(LINE_DISC_RATE) AS LINE_DISC_RATE ,SUM(LINE_DISC_AMOUNT) AS LINE_DISC_AMOUNT ,
								SUM(SKU_DISC_RATE) AS SKU_DISC_RATE ,SUM(SKU_DISC_AMOUNT) AS SKU_DISC_AMOUNT ,domain_id ,MAX(rec_user_code) AS rec_user_code ,
								MAX(rec_time_stamp) AS rec_time_stamp ,MAX(CANCELLED) AS CANCELLED ,MAX(FREE_PRODUCTS) AS FREE_PRODUCTS ,SUM(DISC_1) AS DISC_1 ,
								SUM(DISC_2) AS DISC_2 ,SUM(Quantity_Received) AS Quantity_Received ,MAX(own_pro_id) own_pro_id ,MAX(ARRIVAL_date) ARRIVAL_date ,
								MAX(Confirm_user_code) Confirm_user_code ,MAX(Confirmed_Date) Confirmed_Date ,MAX(OrderLineStatus) OrderLineStatus ,
								MAX(promotion_id) promotion_id ,
								SUM(quantity_Confirmed) quantity_Confirmed ,MAX(ItemNO) ItemNO ,MAX(ReasonCode) ReasonCode ,MAX(UNIT_PRICE) AS unit_price ,
								MAX(Promotion_TypeID) AS Promotion_TypeID ,MAX(Promotion_Detail) AS Promotion_Detail ,MAX(PROMOTION_REASON) AS PROMOTION_REASON,
								ISNULL(SUM(quantity_Confirmed) * ( ISNULL(MAX(EquivalentCases), 0) ),0) Quantity_Confirmed_EC
							FROM    
								(*/ SELECT ol.id ,ol.order_no ,ol.product_id ,'CS' AS uom_code ,ol.product_code 
									  ,case when ol.uom_code='CS' then ol.quantity_ordered else  ol.quantity_ordered/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_ordered
									  ,ol.quantity_shipped ,ol.LINE_TAX ,ol.LINE_TAX_AMOUNT ,ol.line_amount ,ol.line_disc_rate ,ol.line_disc_amount ,ol.sku_disc_rate ,ol.sku_disc_amount ,
									  ol.domain_id ,ol.rec_user_code ,ol.rec_time_stamp ,ol.cancelled ,ol.free_products ,ol.disc_1 ,ol.disc_2 
									  ,case when ol.uom_code='CS' then ol.quantity_received else  ol.quantity_received/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_received ,
									  ol.own_pro_id ,ol.arrival_date ,ol.confirm_user_code ,ol.confirmed_date ,ol.orderlinestatus ,ol.promotion_id ,
									  case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end as quantity_Confirmed ,
									  ol.ItemNO ,ol.ReasonCode ,ol.UNIT_PRICE ,ol.Promotion_TypeID ,ol.Promotion_Detail ,ol.PROMOTION_REASON,case when ol.uom_code='CS' then ol.quantity_Confirmed else  ol.quantity_Confirmed/CASE isnull(DENOMINATOR,0) WHEN 0 THEN 1 ELSE isnull(DENOMINATOR,0)  END end * ol.EquivalentCases
								  FROM #temp_order_line ol left join [10.0.0.6].CCVN4.dbo.Product_UOMS pu on ol.PRODUCT_id = pu.PRODUCT_ID
								  WHERE  ol.FREE_PRODUCTS = 2
								--and ol.item_categ='ZN11'
								  AND NOT EXISTS ( SELECT 'X'
													FROM order_lines
													WHERE ol.order_no = order_lines.order_no
													AND ol.product_id = order_lines.product_id
													AND order_lines.FREE_PRODUCTS = 2
													AND DATEDIFF(day,
													rec_Time_stamp,
													GETDATE()) <= 180 )
								 /* ) t
							GROUP BY order_no ,
									product_id ,
									domain_id ,
									product_code*/
		  
                    SET @error_number = 100301
                    UPDATE  ORDER_LINES
                    SET     SKU_DISC_AMOUNT = A.DISCOUNTMONEY
                    FROM    Order_Promotion_DiscValue A
                    WHERE   ORDER_LINES.ORDER_NO = A.Order_NO
                            AND ORDER_LINES.PRODUCT_ID = A.PRODUCT_ID
                            AND ORDER_LINES.rec_time_stamp BETWEEN @lasttime
                                                           AND
                                                              @newlasttime

					SET @error_number = 100302
					/*Update ol set promotion_id = t.promotion_id
					from ORDER_LINES ol,
						(select order_no,product_id,(select distinct promotion_id+','from #temp_order_line
														where order_no = t.ORDER_NO
														and product_id = t.product_id 
														and promotion_id is not null and FREE_PRODUCTS=2
														for xml path('')) as promotion_id 
					    from #temp_order_line t
						where promotion_id is not null
						group by order_no,product_id )t
					where ol.ORDER_NO = t.ORDER_NO
					and ol.PRODUCT_ID = t.PRODUCT_ID
					and ol.FREE_PRODUCTS =2
				*/

                END

            SET @error_number = 100310
            SET @lasttime = GETDATE()
            SELECT  @lasttime = lasttime
            FROM    interfacetime
            WHERE   tablename = 'Store_Inventory'

            SET @error_number = 100320
            IF ( DATEDIFF(n, @lasttime, GETDATE()) = 0 )
                BEGIN
                    SET @error_number = 100330
                    UPDATE  Store_Inventory
                    SET     Visit_ID = si.Visit_ID ,
                            customer_ID = si.customer_ID ,
                            User_ID = si.User_ID ,
                            Count_Date = si.Count_Date ,
                            Stock_Front = si.Stock_Front_CS ,
                            Stock_Back = si.Stock_Back_CS ,
                            Stock_Room = si.Stock_Room_CS ,
                            REC_User_Code = si.REC_User_Code ,
                            Rec_Time_Stamp = si.Rec_Time_Stamp ,
                            Product_Id = si.Product_Id ,
                            Stock_Front_EA = si.Stock_Front_EA ,
                            Stock_Back_EA = si.Stock_Back_EA ,
                            Stock_Room_EA = si.Stock_Room_EA ,
                            Total = si.Total ,
                            Stock_Front_EC = ISNULL(si.Stock_Front_CS
                                                    * ( ISNULL(EquivalentCases,
                                                              0) ), 0) ,
                            Stock_Back_EC = ISNULL(si.Stock_Back_CS
                                                   * ( ISNULL(EquivalentCases,
                                                              0) ), 0) ,
                            Stock_Room_EC = ISNULL(si.Stock_Room_CS
                                                   * ( ISNULL(EquivalentCases,
                                                              0) ), 0)
                    FROM    [10.0.0.6].CCVN4.dbo.Store_Inventory si WITH ( NOLOCK )
                            JOIN [10.0.0.6].CCVN4.dbo.PRODUCTS p ON si.Product_Id = p.ID
                    WHERE   si.Visit_ID = Store_Inventory.Visit_ID
                            AND si.Product_Id = Store_Inventory.Product_Id
                            AND si.rec_time_stamp < @newlasttime

                    SET @error_number = 100340
                    INSERT  INTO Store_Inventory
                            ( Visit_ID ,
                              customer_ID ,
                              User_ID ,
                              Count_Date ,
                              Stock_Front ,
                              Stock_Back ,
                              Stock_Room ,
                              REC_User_Code ,
                              Rec_Time_Stamp ,
                              Product_Id ,
                              Stock_Front_EA ,
                              Stock_Back_EA ,
                              Stock_Room_EA ,
                              Total ,
                              Stock_Front_EC ,
                              Stock_Back_EC ,
                              Stock_Room_EC
				            )
                            SELECT  si.Visit_ID ,
                                    si.customer_ID ,
                                    si.User_ID ,
                                    si.Count_Date ,
                                    si.Stock_Front_CS ,
                                    si.Stock_Back_CS ,
                                    si.Stock_Room_CS ,
                                    si.REC_User_Code ,
                                    si.Rec_Time_Stamp ,
                                    si.Product_Id ,
                                    si.Stock_Front_EA ,
                                    si.Stock_Back_EA ,
                                    si.Stock_Room_EA ,
                                    si.Total ,
                                    ISNULL(si.Stock_Front_CS
                                           * ISNULL(p.EquivalentCases, 0.25),
                                           0) ,
                                    ISNULL(si.Stock_Back_CS
                                           * ISNULL(p.EquivalentCases, 0.25),
                                           0) ,
                                    ISNULL(si.Stock_Room_CS
                                           * ISNULL(p.EquivalentCases, 0.25),
                                           0)
                            FROM    [10.0.0.6].CCVN4.dbo.Store_Inventory si WITH ( NOLOCK )
                                    JOIN [10.0.0.6].CCVN4.dbo.PRODUCTS p ON si.Product_Id = p.ID
                            WHERE   si.rec_time_stamp < @newlasttime
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   Store_Inventory si2
                                                     WHERE  si.Visit_ID = si2.Visit_ID
                                                            AND si.Product_Id = si2.Product_Id
                                                            AND DATEDIFF(day,
                                                              si2.rec_time_stamp,
                                                              GETDATE()) <= 7 )
		
                    SET @error_number = 100350
                    INSERT  INTO interfacetime
                            ( tablename, lasttime )
                    VALUES  ( 'Store_Inventory', @newlasttime )
                END
            ELSE
                BEGIN
                    SET @error_number = 100360
                    UPDATE  Store_Inventory
                    SET     Visit_ID = si.Visit_ID ,
                            customer_ID = si.customer_ID ,
                            User_ID = si.User_ID ,
                            Count_Date = si.Count_Date ,
                            Stock_Front = si.Stock_Front_CS ,
                            Stock_Back = si.Stock_Back_CS ,
                            Stock_Room = si.Stock_Room_CS ,
                            REC_User_Code = si.REC_User_Code ,
                            Rec_Time_Stamp = si.Rec_Time_Stamp ,
                            Product_Id = si.Product_Id ,
                            Stock_Front_EA = si.Stock_Front_EA ,
                            Stock_Back_EA = si.Stock_Back_EA ,
                            Stock_Room_EA = si.Stock_Room_EA ,
                            Total = si.Total
							/**/
							/**/ ,
                            Stock_Front_EC = ISNULL(si.Stock_Front_CS
                                                    * ( ISNULL(EquivalentCases,
                                                              0) ), 0) ,
                            Stock_Back_EC = ISNULL(si.Stock_Back_CS
                                                   * ( ISNULL(EquivalentCases,
                                                              0) ), 0) ,
                            Stock_Room_EC = ISNULL(si.Stock_Room_CS
                                                   * ( ISNULL(EquivalentCases,
                                                              0) ), 0)
                    FROM    [10.0.0.6].CCVN4.dbo.Store_Inventory si WITH ( NOLOCK )
                            JOIN [10.0.0.6].CCVN4.dbo.PRODUCTS p ON si.Product_Id = p.ID
                    WHERE   si.Visit_ID = Store_Inventory.Visit_ID
                            AND si.Product_Id = Store_Inventory.Product_Id
                            AND si.rec_time_stamp BETWEEN @lasttime
                                                  AND     @newlasttime

                    SET @error_number = 100370
                    INSERT  INTO Store_Inventory
                            ( Visit_ID ,
                              customer_ID ,
                              User_ID ,
                              Count_Date ,
                              Stock_Front ,
                              Stock_Back ,
                              Stock_Room ,
                              REC_User_Code ,
                              Rec_Time_Stamp ,
                              Product_Id ,
                              Stock_Front_EA ,
                              Stock_Back_EA ,
                              Stock_Room_EA ,
                              Total ,
                              Stock_Front_EC ,
                              Stock_Back_EC ,
                              Stock_Room_EC
				            )
                            SELECT  si.Visit_ID ,
                                    si.customer_ID ,
                                    si.User_ID ,
                                    si.Count_Date ,
                                    si.Stock_Front_CS ,
                                    si.Stock_Back_CS ,
                                    si.Stock_Room_CS ,
                                    si.REC_User_Code ,
                                    si.Rec_Time_Stamp ,
                                    si.Product_Id ,
                                    si.Stock_Front_EA ,
                                    si.Stock_Back_EA ,
                                    si.Stock_Room_EA ,
                                    si.Total ,
                                    ISNULL(si.Stock_Front_CS
                                           * ISNULL(p.EquivalentCases, 0.25),
                                           0) ,
                                    ISNULL(si.Stock_Back_CS
                                           * ISNULL(p.EquivalentCases, 0.25),
                                           0) ,
                                    ISNULL(si.Stock_Room_CS
                                           * ISNULL(p.EquivalentCases, 0.25),
                                           0)
                            FROM    [10.0.0.6].CCVN4.dbo.Store_Inventory si WITH ( NOLOCK )
                                    JOIN [10.0.0.6].CCVN4.dbo.PRODUCTS p ON si.Product_Id = p.ID
                            WHERE   si.rec_time_stamp BETWEEN @lasttime
                                                      AND     @newlasttime
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   Store_Inventory si2
                                                     WHERE  si.Visit_ID = si2.Visit_ID
                                                            AND si.Product_Id = si2.Product_Id
                                                            AND DATEDIFF(day,
                                                              si2.rec_time_stamp,
                                                              GETDATE()) <= 7 
														)
	
                    SET @error_number = 100380
                    UPDATE  interfacetime
                    SET     lasttime = @newlasttime
                    WHERE   tablename = 'Store_Inventory'
		
-------------------------------------------------------------------------------------
-- 导入库存 
--	add by kris 2012-06-05
-------------------------------------------------------------------------------------		
                    SET @error_number = 100390
                    SET @lasttime = GETDATE()
                    SELECT  @lasttime = lasttime
                    FROM    interfacetime
                    WHERE   tablename = 'Inventory'

                    SET @error_number = 100410
                    UPDATE  INVENTORY_LIST
                    SET     CHAIN_ID = si.CHAIN_ID ,
                            OPEN_DATE = si.OPEN_DATE ,
                            CLOSE_DATE = si.CLOSE_DATE ,
                            STATUS = si.STATUS ,
                            REC_USER_CODE = si.REC_USER_CODE ,
                            REC_TIME_STAMP = si.REC_TIME_STAMP
                    FROM    [10.0.0.6].CCVN4.dbo.INVENTORY_LIST si
                    WHERE   si.id = INVENTORY_LIST.id
                            AND DATEDIFF(DAY, si.close_date, @newlasttime) <= 7
	
                    SET @error_number = 100420
                    UPDATE  INVENTORY_LIST_ITEM
                    SET     INVENTORY_LIST_ID = si.INVENTORY_LIST_ID ,
                            PRODUCT_ID = si.PRODUCT_ID ,
                            OPENING_STOCK = si.OPENING_STOCK ,
                            OPENING_STOCK_EA = si.OPENING_STOCK_EA ,
                            RECEIVED = si.RECEIVED ,
                            RECEIVED_EA = si.RECEIVED_EA ,
                            SALES = si.SALES ,
                            SALES_EA = si.SALES_EA ,
                            Returned = si.Returned ,
                            Returned_EA = si.Returned_EA ,
                            BREAKAGES = si.BREAKAGES ,
                            BREAKAGES_EA = si.BREAKAGES_EA ,
                            ACTUAL = si.ACTUAL ,
                            ACTUAL_EA = si.ACTUAL_EA ,
                            REC_USER_CODE = si.REC_USER_CODE ,
                            REC_TIME_STAMP = si.REC_TIME_STAMP ,
                            OPENING_STOCK_EC = ISNULL(si.OPENING_STOCK
                                                      * ( ISNULL(p.EquivalentCases,
                                                              0) ), 0) ,
                            RECEIVED_EC = ISNULL(si.RECEIVED
                                                 * ( ISNULL(p.EquivalentCases,
                                                            0) ), 0) ,
                            SALES_EC = ISNULL(si.SALES
                                              * ( ISNULL(p.EquivalentCases, 0) ),
                                              0) ,
                            Returned_EC = ISNULL(si.Returned
                                                 * ( ISNULL(p.EquivalentCases,
                                                            0) ), 0) ,
                            BREAKAGES_EC = ISNULL(si.BREAKAGES
                                                  * ( ISNULL(p.EquivalentCases,
                                                             0) ), 0) ,
                            ACTUAL_EC = ISNULL(si.ACTUAL
                                               * ( ISNULL(p.EquivalentCases, 0) ),
                                               0)
                    FROM    [10.0.0.6].CCVN4.dbo.INVENTORY_LIST_ITEM si
                            INNER JOIN [10.0.0.6].CCVN4.dbo.INVENTORY_LIST si2 ON si.INVENTORY_LIST_ID = si2.ID
                            JOIN PRODUCTS p ON si.PRODUCT_ID = p.ID
                    WHERE   si.id = INVENTORY_LIST_ITEM.id
                            AND DATEDIFF(DAY, si2.close_date, @newlasttime) <= 7
	
                    SET @error_number = 100430
                    INSERT  INTO INVENTORY_LIST
                            ( ID ,
                              CHAIN_ID ,
                              OPEN_DATE ,
                              CLOSE_DATE ,
                              STATUS ,
                              REC_USER_CODE ,
                              REC_TIME_STAMP
                            )
                            SELECT  ID ,
                                    CHAIN_ID ,
                                    OPEN_DATE ,
                                    CLOSE_DATE ,
                                    STATUS ,
                                    REC_USER_CODE ,
                                    REC_TIME_STAMP
                            FROM    [10.0.0.6].CCVN4.dbo.INVENTORY_LIST si WITH ( NOLOCK )
                            WHERE   DATEDIFF(DAY, si.close_date, @newlasttime) <= 7
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   INVENTORY_LIST si2
                                                     WHERE  si.ID = si2.ID )
					
                    SET @error_number = 100440
                    INSERT  INTO INVENTORY_LIST_ITEM
                            ( ID ,
                              INVENTORY_LIST_ID ,
                              PRODUCT_ID ,
                              OPENING_STOCK ,
                              OPENING_STOCK_EA ,
                              RECEIVED ,
                              RECEIVED_EA ,
                              SALES ,
                              SALES_EA ,
                              Returned ,
                              Returned_EA ,
                              BREAKAGES ,
                              BREAKAGES_EA ,
                              ACTUAL ,
                              ACTUAL_EA ,
                              REC_USER_CODE ,
                              REC_TIME_STAMP ,
                              OPENING_STOCK_EC ,
                              RECEIVED_EC ,
                              SALES_EC ,
                              Returned_EC ,
                              BREAKAGES_EC ,
                              ACTUAL_EC
                            )
                            SELECT  si.ID ,
                                    INVENTORY_LIST_ID ,
                                    PRODUCT_ID ,
                                    OPENING_STOCK ,
                                    OPENING_STOCK_EA ,
                                    RECEIVED ,
                                    RECEIVED_EA ,
                                    SALES ,
                                    SALES_EA ,
                                    Returned ,
                                    Returned_EA ,
                                    BREAKAGES ,
                                    BREAKAGES_EA ,
                                    ACTUAL ,
                                    ACTUAL_EA ,
                                    si.REC_USER_CODE ,
                                    si.REC_TIME_STAMP ,
                                    ISNULL(si.OPENING_STOCK
                                           * ( ISNULL(p.EquivalentCases, 0) ),
                                           0) ,
                                    ISNULL(si.RECEIVED
                                           * ( ISNULL(p.EquivalentCases, 0) ),
                                           0) ,
                                    ISNULL(si.SALES
                                           * ( ISNULL(p.EquivalentCases, 0) ),
                                           0) ,
                                    ISNULL(si.Returned
                                           * ( ISNULL(p.EquivalentCases, 0) ),
                                           0) ,
                                    ISNULL(si.BREAKAGES
                                           * ( ISNULL(p.EquivalentCases, 0) ),
                                           0) ,
                                    ISNULL(si.ACTUAL
                                           * ( ISNULL(p.EquivalentCases, 0) ),
                                           0)
                            FROM    [10.0.0.6].CCVN4.dbo.INVENTORY_LIST_ITEM si WITH ( NOLOCK )
                                    INNER JOIN [10.0.0.6].CCVN4.dbo.INVENTORY_LIST si2

                                    WITH ( NOLOCK ) ON si.INVENTORY_LIST_ID = si2.ID
                                    JOIN dbo.PRODUCTS p ON si.PRODUCT_ID = p.ID
                            WHERE   DATEDIFF(DAY, si2.close_date, @newlasttime) <= 7
                                    AND NOT EXISTS ( SELECT 'X'
                                                     FROM   INVENTORY_LIST_ITEM si3
                                                     WHERE  si.ID = si3.ID )
					
                    SET @error_number = 100450
                    DELETE  INVENTORY_LIST_ITEM
                    WHERE   INVENTORY_LIST_ID IN (
                            SELECT  ID
                            FROM    INVENTORY_LIST
                            WHERE   DATEDIFF(DAY, CLOSE_DATE, GETDATE()) > 7 )
	
                    DELETE  INVENTORY_LIST
                    WHERE   DATEDIFF(DAY, CLOSE_DATE, GETDATE()) > 7

                    SET @error_number = 100460
                    UPDATE  interfacetime
                    SET     lasttime = @newlasttime
                    WHERE   tablename = 'Inventory'
	
-------------------------------------------------------------------------------------
-- 更新每天的实际路线统计
--	add by kris 2012-09-04
-------------------------------------------------------------------------------------
--	set @error_number=100470		
--	update Daily_Visit set onRouteOrder=onRoute,offRouteOrder=offRoute
--	from(
--		select USER_ID,dateadd(day,datediff(day,0,START_TIME),0) as Date
--				,case left(VISIT_TYPE,1) when 0 then COUNT(distinct CUSTOMER_ID) else 0 end onRoute
--				,case left(VISIT_TYPE,1) when 1 then COUNT(distinct CUSTOMER_ID) else 0 end offRoute
--		from VISITS
--		where exists(select 'x' from ORDER_HEADERS where visit_id=VISITS.id)
--			and START_TIME>=dateadd(day,datediff(day,0,GETDATE()),0)
--		group by USER_ID,dateadd(day,datediff(day,0,START_TIME),0),VISIT_TYPE
--	)tmp where tmp.USER_ID=Daily_Visit.User_ID and tmp.Date=Daily_Visit.Date
--	
--	update Daily_Visit set onRouteAchieved=actual from(
--	select USER_ID,dateadd(day,datediff(day,0,START_TIME),0) as Date
--			,COUNT(distinct CUSTOMER_ID) actual
--	from VISITS
--	where left(VISIT_TYPE,1)=0 and START_TIME>=dateadd(day,datediff(day,0,GETDATE()),0)
--	group by USER_ID,dateadd(day,datediff(day,0,START_TIME),0)
--	)tmp where tmp.USER_ID=Daily_Visit.User_ID and tmp.Date=Daily_Visit.Date


                    SET @error_number = 100470		
                    UPDATE  Daily_Visit
                    SET     onRouteOrder = onRoute
                    FROM    ( SELECT    v.USER_ID ,
                                        DATEADD(day,
                                                DATEDIFF(day, 0, START_TIME),
                                                0) AS Date ,
                                        COUNT(DISTINCT v.CUSTOMER_ID) AS onRoute
                              FROM      VISITS v
                                        INNER JOIN ORDER_HEADERS oh ON v.ID = oh.VISIT_ID
                              WHERE     v.START_TIME >= DATEADD(day,
                                                              DATEDIFF(day, 0,
                                                              GETDATE()), 0)
                                        AND LEFT(VISIT_TYPE, 1) = 0
                                        AND oh.OrderType = 0
                              GROUP BY  v.USER_ID ,
                                        DATEADD(day,
                                                DATEDIFF(day, 0, START_TIME),
                                                0)
                            ) tmp
                    WHERE   tmp.USER_ID = Daily_Visit.User_ID
                            AND tmp.Date = Daily_Visit.Date
	
                    UPDATE  Daily_Visit
                    SET     offRouteOrder = offRoute
                    FROM    ( SELECT    v.USER_ID ,
                                        DATEADD(day,
                                                DATEDIFF(day, 0, START_TIME),
                                                0) AS Date ,
                                        COUNT(DISTINCT v.CUSTOMER_ID) AS offRoute
                              FROM      VISITS v
                                        INNER JOIN ORDER_HEADERS oh ON v.ID = oh.VISIT_ID
                              WHERE     v.START_TIME >= DATEADD(day,
                                                              DATEDIFF(day, 0,
                                                              GETDATE()), 0)
                                        AND LEFT(VISIT_TYPE, 1) = 1
                                        AND oh.OrderType = 0
                              GROUP BY  v.USER_ID ,
                                        DATEADD(day,
                                                DATEDIFF(day, 0, START_TIME),
                                                0)
                            ) tmp
                    WHERE   tmp.USER_ID = Daily_Visit.User_ID
                            AND tmp.Date = Daily_Visit.Date
	
                    UPDATE  Daily_Visit
                    SET     onRouteAchieved = actual
                    FROM    ( SELECT    USER_ID ,
                                        DATEADD(day,
                                                DATEDIFF(day, 0, START_TIME),
                                                0) AS Date ,
                                        COUNT(DISTINCT CUSTOMER_ID) actual
                              FROM      VISITS
                              WHERE     LEFT(VISIT_TYPE, 1) = 0
                                        AND START_TIME >= DATEADD(day,
                                                              DATEDIFF(day, 0,
                                                              GETDATE()), 0)
                              GROUP BY  USER_ID ,
                                        DATEADD(day,
                                                DATEDIFF(day, 0, START_TIME),
                                                0)
                            ) tmp
                    WHERE   tmp.USER_ID = Daily_Visit.User_ID
                            AND tmp.Date = Daily_Visit.Date

                    UPDATE  Daily_Visit
                    SET     SKUNum = qty
                    FROM    ( SELECT    USER_ID ,
                                        date ,
                                        SUM(num) AS qty
                              FROM      ( SELECT    oh.USER_ID ,
                                                    oh.CUSTOMER_ID ,
                                                    DATEADD(day,
                                                            DATEDIFF(day, 0,
                                                              oh.ORDER_date),
                                                            0) AS date ,
                                                    COUNT(DISTINCT ol.PRODUCT_ID) AS num
                                          FROM      ORDER_HEADERS oh
                                                    INNER JOIN ORDER_LINES ol ON oh.ORDER_NO = ol.ORDER_NO
                                          WHERE     ( ISNULL(ol.FREE_PRODUCTS,
                                                             0) = 0
                                                      OR ol.FREE_PRODUCTS = 2
                                                    )
                                                    AND LEFT(oh.ORDER_NO, 1) <> 'M'
                                                    AND oh.OrderType = 0
                                                    AND oh.ORDER_date >= DATEADD(day,
                                                              DATEDIFF(day, 0,
                                                              GETDATE()), 0)
                                          GROUP BY  oh.USER_ID ,
                                                    oh.CUSTOMER_ID ,
                                                    DATEADD(day,
                                                            DATEDIFF(day, 0,
                                                              oh.ORDER_date),
                                                            0)
                                        ) aa
                              GROUP BY  USER_ID ,
                                        date
                            ) tmp
                    WHERE   tmp.USER_ID = Daily_Visit.User_ID
                            AND tmp.Date = Daily_Visit.Date

		--------------------------------------------------------------------------------------------------------------
		--Volume Range Discount Report
		--------------------------------------------------------------------------------------------------------------
		INSERT INTO dbo.Order_Promotion_MatrixValue(ORDER_NO,VOLUME_EC,VOLUME_DISCOUNT,SKU_NUMBER,SKU_EC,SKU_DISCOUNT,PromotionID,VOLUME_PromotionID,SKU_PromotionID,REC_TIME_STAMP)
		SELECT opm.ORDER_NO,opm.VOLUME_EC,opm.VOLUME_DISCOUNT,opm.SKU_NUMBER,opm.SKU_EC,opm.SKU_DISCOUNT,PromotionID,VOLUME_PromotionID,SKU_PromotionID,REC_TIME_STAMP
		FROM [10.0.0.6].CCVN4.dbo.Order_Promotion_MatrixValue opm
		WHERE NOT EXISTS (SELECT 'X' FROM dbo.Order_Promotion_MatrixValue opm1 WHERE opm.ORDER_NO=opm1.ORDER_NO)
		--------------------------------------------------------------------------------------------------------------
		UPDATE Order_Promotion_MatrixValue SET VOLUME_EC=opm.VOLUME_EC
											  ,VOLUME_DISCOUNT=opm.VOLUME_DISCOUNT
											  ,SKU_NUMBER=opm.SKU_NUMBER
											  ,SKU_EC=opm.SKU_EC
											  ,SKU_DISCOUNT=opm.SKU_DISCOUNT
											  ,PromotionID=opm.PromotionID
											  ,VOLUME_PromotionID = opm.VOLUME_PromotionID
											  ,SKU_PromotionID = opm.SKU_PromotionID
											  ,REC_TIME_STAMP = opm.REC_TIME_STAMP
		FROM [10.0.0.6].CCVN4.dbo.Order_Promotion_MatrixValue opm 
		WHERE opm.ORDER_NO=Order_Promotion_MatrixValue.ORDER_NO

		------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO dbo.ORDER_LINES_PROMO(ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,PROMO_CLASS,DISCOUNT_VALUE,FREE_QTY ,FREE_UOM,LineID, FreeLineID, OwnProductID, FreeProductID, CALCULATE_TIME ,UPLOAD_TIME)
		SELECT olp.ORDER_NO,olp.PROMO_ID,olp.PROMO_CODE,olp.PROMO_NAME,olp.PROMO_TYPE_ID,olp.PROMO_CLASS,olp.DISCOUNT_VALUE,olp.FREE_QTY,olp.FREE_UOM,LineID, FreeLineID, OwnProductID, FreeProductID,GETDATE(),GETDATE() 
		FROM [10.0.0.6].CCVN4.dbo.ORDER_LINES_PROMO olp
		WHERE NOT EXISTS (SELECT 'X' FROM dbo.ORDER_LINES_PROMO olp1 WHERE olp.ORDER_NO=olp1.ORDER_NO AND olp.PROMO_ID=olp1.PROMO_ID AND ISNULL(olp.LineID,0) = ISNULL(olp1.LineID,0) AND ISNULL(olp.FreeLineID,0) = ISNULL(olp1.FreeLineID,0))
		UPDATE dbo.ORDER_LINES_PROMO SET PROMO_NAME=olp.PROMO_NAME
										,PROMO_TYPE_ID=olp.PROMO_TYPE_ID
										,PROMO_CLASS=olp.PROMO_CLASS
										,DISCOUNT_VALUE=olp.DISCOUNT_VALUE
										,FREE_QTY=olp.FREE_QTY
										,FREE_UOM=olp.FREE_UOM
										,OwnProductID=olp.OwnProductID
										,FreeProductID=olp.FreeProductID
										,UPLOAD_TIME=GETDATE()
		FROM [10.0.0.6].CCVN4.dbo.ORDER_LINES_PROMO olp
		WHERE olp.ORDER_NO=ORDER_LINES_PROMO.ORDER_NO
		  AND olp.PROMO_ID=ORDER_LINES_PROMO.PROMO_ID
		------------------------------------------------------------------------------------------------------------------------------------------------------------------

                END
			drop table #temp_order_line
            COMMIT TRAN sp_visitdata_int
        END TRY
        BEGIN CATCH 
            SET @error_code = @@error
			

            ROLLBACK TRAN sp_visitdata_int

            SELECT  @error_message = '【错误信息:' + CONVERT(VARCHAR(20), GETDATE(), 120)
                    + '】错误位置：' + CAST(@error_number AS VARCHAR(100)) + ' '
                    + CAST(@error_code AS VARCHAR(100)) + ' '
                    + ERROR_MESSAGE()

            RAISERROR (@error_message,16,1)
            PRINT @error_message
			/*insert into tblErrLog (sysNam, ModuleNam, ErrClass, ErrCode, ErrDesc, UpdUsr, CrtDat)
			select 'CCCIL_Reporting','sp_visitdata_int','*','*',@error_message,'CCCIL_Reporting',getdate()*/
        END CATCH
    END
