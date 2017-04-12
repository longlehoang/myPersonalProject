USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[SP_Calc_Promo_Standard]    Script Date: 9/9/2016 2:50:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*****Create by lumi.Create Date 2015-11-16******/
ALTER procedure [dbo].[SP_Calc_Promo_Standard](@Order_NO varchar(30),@Org_ID int,@Chain_id int)
AS
BEGIN
	DECLARE @IsSingleUse INT --该促销是否为单次使用值为0，单次=1
	,@IsMultiple INT --倍数
	,@PromotionTypeID INT --促销类型
	,@Promotion_Form INT --来源：Portal promotion=0、Coupon promotion=1
	,@promotionID NVARCHAR(50) --促销ID
	,@str VARCHAR(30)
	,@PromotionStr NVARCHAR(500)
	,@userType CHAR(1)
	,@MDC_Cust_Prod_ID INT
	,@Number INT  
  	,@error_num int 
	,@error_code INT
	,@error_message nvarchar(2000)  

	----删除赠品------------------------
	DELETE FROM Order_lines
	WHERE Order_NO = @Order_NO
	AND Free_Products =2

	--计算总价 
	UPDATE Order_Headers SET Total_Amount =CASE WHEN OrderType=1 THEN  -isnull(T.Tatal_Amount,0)
											ELSE isnull(T.Tatal_Amount,0) END
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE='Calc_Promo_Standard'
									,DISC_AMOUNT=Total_Amount
	FROM (SELECT Sum(OL.Line_Amount) as Tatal_Amount
		  FROM Order_Lines OL(NOLOCK)
		  WHERE OL.Order_NO = @Order_NO) T
	WHERE Order_Headers.Order_NO = @Order_NO

	BEGIN TRY
	BEGIN TRAN Calc_Order

	--把订单中所有用到的促销ID拼接成一个字符串
	SELECT DISTINCT STUFF((SELECT ',' + promotion_id FROM (SELECT promotion_id FROM dbo.ORDER_LINES WHERE ORDER_NO=@Order_NO AND ISNULL(promotion_id,'')<>''
	 AND free_products<>2 AND QUANTITY_ORDERED>0) subTitle FOR XML PATH('')),1, 1, '') AS promotionID
	INTO #PromotiomStr FROM (SELECT promotion_id FROM dbo.ORDER_LINES WHERE ORDER_NO=@Order_NO AND ISNULL(promotion_id,'')<>''
	 AND free_products<>2 AND QUANTITY_ORDERED>0)t


	SELECT @PromotionStr=promotionID FROM #PromotiomStr
	
	--把字符串拆分放到一个临时表中
	SELECT DISTINCT a AS promotionID INTO #PromotionIDS FROM dbo.FN_SPLIT(@PromotionStr, ',')

	CREATE TABLE #PromotionProduct --创建促销基本信息表
	(
		ID INT IDENTITY(1,1)
		,OrderNO VARCHAR(30)
		,LineAmount NUMERIC(15,4)
		,OwnProductID INT
		,PromotionID NVARCHAR(50)
		,PromotionName NVARCHAR(50)
		,FreeProductID INT
		,FreeQTY INT
		,FreeUom VARCHAR(3)
		,ValueDiscount NUMERIC(18,2)
		,PercentageDiscount NUMERIC(5,1)
		,OwnQTY INT
		,IsMultiple INT
		,ProUom VARCHAR(3)   
		,QTY NUMERIC(15,8)                      
	)

	DELETE dbo.ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO

	--循环临时表	
	while(ISNULL((select COUNT(*) FROM #PromotionIDS),0)<>0)  
        BEGIN
			SET @Number=0
			SELECT TOP 1 @promotionID=promotionID FROM #PromotionIDS

			SELECT @Promotion_Form=Promotion_Form,@PromotionTypeID=TypeID,@IsMultiple=IsMultiple,@IsSingleUse=ISNULL(IsSingleUse,0),@userType=ISNULL(UseType,'0')
			FROM dbo.ORDER_PROMOTION WHERE ID =@promotionID

			--符合订单下使用促销的SKU,ID，数量
			INSERT INTO #PromotionProduct(OrderNO,LineAmount,OwnProductID,PromotionID,PromotionName,FreeProductID,FreeQTY,FreeUom,ValueDiscount,PercentageDiscount,OwnQTY,IsMultiple,ProUom,QTY)
			SELECT DISTINCT oh.ORDER_NO AS OrderNO,ol.LINE_AMOUNT AS LineAmount,ol.PRODUCT_ID AS OwnProductID,op.ID AS PromotionID,op.NAME AS PromotionName,ISNULL(op.FREE_PRODUCT_ID,0) AS FreeProductID,op.FREE_QTY AS FreeQTY,op.FREE_UOM AS FreeUom,ISNULL(op.VALUE_DISCOUNT,0) AS ValueDiscount,ISNULL(op.PERCENTAGE_DISCOUNT,0) AS PercentageDiscount,opp.OWN_QTY AS OwnQTY,op.IsMultiple
			,opp.OWN_UOM AS ProUom
			,CASE WHEN opp.OWN_UOM='EC' AND ol.UOM_CODE='CS' 
						THEN QUANTITY_ORDERED*ISNULL((SELECT p.EquivalentCases FROM dbo.PRODUCTS p WHERE p.ID=ol.PRODUCT_ID AND p.VALID='1'),0) --CS 转换成EC
					WHEN opp.OWN_UOM='EC' AND ol.UOM_CODE='EA' 
						THEN CAST((QUANTITY_ORDERED/(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID)) AS NUMERIC(10,3))*ISNULL((SELECT p.EquivalentCases FROM dbo.PRODUCTS p WHERE p.ID=ol.PRODUCT_ID AND p.VALID='1'),0) --EA转换成EC，需要先转换成CS再转换成EC
					WHEN opp.OWN_UOM='CS' AND ol.UOM_CODE='EA'
						THEN QUANTITY_ORDERED/(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID) --EA 换成 CS
					WHEN opp.OWN_UOM='EA' AND ol.UOM_CODE='CS'
						THEN QUANTITY_ORDERED*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID) --CS 换成 EA
					ELSE QUANTITY_ORDERED
								END AS QTY
			FROM dbo.ORDER_HEADERS oh 
			INNER JOIN ORDER_LINES ol ON oh.ORDER_NO = ol.ORDER_NO
			INNER JOIN ORDER_PROMOTION_PRODUCT opp ON ol.PRODUCT_CODE=opp.PRODUCT_CODE 
														--AND opp.OWN_UOM=ol.UOM_CODE 
														AND opp.PROMOTION_ID=@promotionID 
														AND opp.VALID='1'
			INNER JOIN dbo.ORDER_PROMOTION op ON op.ID=opp.PROMOTION_ID AND op.VALID='1'
			INNER JOIN dbo.ORGANIZATION org ON org.ParentID=op.Org_ID
			--INNER JOIN dbo.ORDER_PROMOTION_CUSTOMER opc ON opc.PROMOTION_ID=op.ID AND oh.CUSTOMER_ID=opc.CUSTOMER_ID AND ISNULL(opc.IsUse,0)=0 AND opc.VALID='1'
			WHERE oh.ORDER_NO=@Order_NO 
			AND QUANTITY_ORDERED>0 
			AND ol.promotion_id LIKE '%'+@promotionID+'%' 
			AND free_products<>2
			AND op.Start_Time<=oh.ORDER_date 
			AND op.End_Time >=oh.ORDER_date
			AND opp.PRODUCT_CODE NOT IN(SELECT PRODUCT_CODE FROM dbo.ORDER_PROMOTION_EXCLUDE WHERE PROMOTION_ID=opp.PROMOTION_ID AND VALID='1')
			AND oh.CUSTOMER_ID IN(CASE WHEN op.IsSingleUse=1 
			THEN (SELECT opc.CUSTOMER_ID FROM dbo.ORDER_PROMOTION_CUSTOMER opc WHERE 
					opc.PROMOTION_ID=op.ID
					AND oh.CUSTOMER_ID=opc.CUSTOMER_ID 
					AND ISNULL(opc.IsUse,0)=0 AND opc.VALID='1') 
					ELSE oh.CUSTOMER_ID END)

			/***********by pack************/
			DECLARE @n1 INT,@n2 INT,@minIsMultiple INT,@minQty INT 
			SELECT @n1=COUNT(DISTINCT fp.OwnProductID),@minIsMultiple=MIN(IsMultiple),@minQty=MIN(CAST(QTY/OwnQTY AS INT)) 
			FROM (SELECT OrderNO,SUM(LineAmount) AS LineAmount,OwnProductID,PromotionID,MAX(ValueDiscount) AS ValueDiscount,MAX(OwnQTY) AS OwnQTY,MAX(IsMultiple) AS IsMultiple,ProUom,SUM(QTY) AS QTY
							FROM #PromotionProduct GROUP BY OrderNO,OwnProductID,PromotionID,ProUom) fp   --符合促销条件的SKU
			INNER JOIN dbo.ORDER_PROMOTION_PRODUCT opp ON fp.PromotionID=opp.PROMOTION_ID
			WHERE opp.PROMOTION_ID=@promotionID AND opp.VALID='1' AND fp.QTY>=opp.OWN_QTY 
			
			SELECT @n2=COUNT(*) FROM dbo.ORDER_PROMOTION_PRODUCT opp --促销中设定的SKU
			WHERE opp.PROMOTION_ID=@promotionID AND opp.VALID='1'
			--------------------------------------------------------------------------------
			
			IF @PromotionTypeID=1
			BEGIN
				--Free cases 赠品 处理逻辑
				IF (SELECT COUNT(*) FROM #PromotionProduct WHERE FreeProductID>0 AND PromotionID=@promotionID)>0 --如果有赠品
				BEGIN
					SET @Number=1						
					IF(SELECT COUNT(*) FROM dbo.ORDER_LINES ol
						INNER JOIN #PromotionProduct fp ON ol.ORDER_NO=fp.OrderNO COLLATE Chinese_PRC_CI_AS
													AND ol.PRODUCT_ID=fp.FreeProductID
													AND ol.UOM_CODE=fp.FreeUom COLLATE Chinese_PRC_CI_AS
													AND ol.own_pro_id=fp.OwnProductID
													AND fp.PromotionID=@promotionID
						WHERE ol.ORDER_NO=@Order_NO AND ol.FREE_PRODUCTS=2)=0 --还未存在此赠品，需要insert           
						--添加赠品
						INSERT INTO Order_Lines(Order_NO,Product_ID,Uom_Code,UNIT_PRICE,PRODUCT_CODE,QUANTITY_ORDERED,QUANTITY_SHIPPED,LINE_AMOUNT,LINE_DISC_RATE,
						LINE_DISC_AMOUNT,LINE_TAX,LINE_TAX_AMOUNT,SKU_DISC_RATE,SKU_DISC_AMOUNT,DOMAIN_ID,REC_USER_CODE,REC_TIME_STAMP,CANCELLED,FREE_PRODUCTS,own_pro_id,
						OrderLineStatus,promotion_id)
						SELECT 
						@Order_NO,freePro.FreeProductID,freePro.FreeUom
						,0,p.CODE,(CASE WHEN ISNULL(CAST(freePro.QTY/freePro.OwnQTY AS INT),0)>freePro.IsMultiple 
										THEN freePro.IsMultiple*freePro.FreeQTY 
										ELSE ISNULL(CAST(freePro.QTY/freePro.OwnQTY AS INT),0)*freePro.FreeQTY END )  --赠品数量
						,0,0,0,0,0,0,0,0,1,'Calc_Promo_Standard',GETDATE(),'N',2,freePro.OwnProductID
						,2,freePro.PromotionID
						FROM (SELECT OrderNO,OwnProductID,PromotionID,FreeProductID,MAX(FreeQTY) AS FreeQTY,FreeUom,MAX(OwnQTY) AS OwnQTY,MAX(IsMultiple) AS IsMultiple,SUM(QTY) AS QTY FROM #PromotionProduct
								GROUP BY OrderNO,OwnProductID,PromotionID,FreeProductID,FreeUom
							) freePro
						INNER JOIN dbo.PRODUCTS p ON p.ID=freePro.FreeProductID AND p.VALID='1'
						WHERE freePro.PromotionID=@promotionID AND freePro.QTY>=freePro.OwnQTY
					ELSE  --存在需更新
						UPDATE dbo.ORDER_LINES SET QUANTITY_ORDERED= QUANTITY_ORDERED+t.qty
													,REC_USER_CODE='Calc_Promo_Standard'
													,REC_TIME_STAMP=GETDATE()
						FROM (select ol.order_no,ol.product_id,sum(ISNULL((CASE WHEN ISNULL(CAST(fp.QTY/fp.OwnQTY AS INT),0)>fp.IsMultiple 
																							THEN fp.IsMultiple*fp.FreeQTY 
																							ELSE ISNULL(CAST(fp.QTY/fp.OwnQTY AS INT),0)*fp.FreeQTY END ),0)) as qty
							from 
							(SELECT OrderNO,PromotionID,FreeProductID,MAX(FreeQTY) AS FreeQTY,FreeUom,MAX(OwnQTY) AS OwnQTY,MAX(IsMultiple) AS IsMultiple,SUM(QTY) AS QTY FROM #PromotionProduct
								GROUP BY OrderNO,PromotionID,FreeProductID,FreeUom
							)fp,order_lines ol
							WHERE fp.OrderNO=ol.ORDER_NO COLLATE Chinese_PRC_CI_AS
								AND ol.PRODUCT_ID=fp.FreeProductID
								AND ol.UOM_CODE=fp.FreeUom COLLATE Chinese_PRC_CI_AS
								AND ol.FREE_PRODUCTS=2
								--AND dbo.ORDER_LINES.ORDER_NO=@Order_NO
								--AND dbo.ORDER_LINES.own_pro_id=fp.OwnProductID
								AND fp.PromotionID=@promotionID
							group by  ol.order_no,ol.product_id)t
						WHERE dbo.ORDER_LINES.order_no = t.ORDER_NO
						and dbo.ORDER_LINES.PRODUCT_ID = t.PRODUCT_ID
						and dbo.ORDER_LINES.FREE_PRODUCTS =2
						
						--已使用的促销信息添加到ORDER_LINES_PROMO表，以便报表使用
						IF(SELECT COUNT(*) FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID)=0                  
							INSERT INTO dbo.ORDER_LINES_PROMO
								( ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,
									PROMO_CLASS,FREE_QTY,FREE_UOM,CALCULATE_TIME,UPLOAD_TIME)
							SELECT DISTINCT @Order_NO,@promotionID,op.CODE,op.NAME,op.TypeID,op.PromotionClass,ISNULL(pp.FreeQtyNum,0),FreeUom,GETDATE(),GETDATE() 
							FROM (SELECT OrderNO,PromotionID,FreeUom,SUM(ISNULL((CASE WHEN ISNULL(CAST(pp.QTY/pp.OwnQTY AS INT),0)>pp.IsMultiple 
									THEN pp.IsMultiple*pp.FreeQTY 
									ELSE ISNULL(CAST(pp.QTY/pp.OwnQTY AS INT),0)*pp.FreeQTY END),0)) AS FreeQtyNum
										FROM #PromotionProduct pp GROUP BY OrderNO,PromotionID,FreeUom) pp
							INNER JOIN dbo.ORDER_PROMOTION op ON op.ID=pp.PromotionID
							WHERE op.ID=@promotionID AND VALID='1'                     
						ELSE
							UPDATE dbo.ORDER_LINES_PROMO SET FREE_QTY=ISNULL(FREE_QTY,0)+ISNULL(pp.FreeQtyNum,0)
						FROM (SELECT OrderNO,PromotionID,FreeUom,SUM(ISNULL((CASE WHEN ISNULL(CAST(pp.QTY/pp.OwnQTY AS INT),0)>pp.IsMultiple 
								THEN pp.IsMultiple*pp.FreeQTY 
								ELSE ISNULL(CAST(pp.QTY/pp.OwnQTY AS INT),0)*pp.FreeQTY END),0)) AS FreeQtyNum
									FROM #PromotionProduct pp GROUP BY OrderNO,PromotionID,FreeUom) pp
							WHERE ORDER_NO=@Order_NO AND PROMO_ID=pp.PromotionID AND pp.PromotionID= @promotionID
				END
			END
			ELSE IF @PromotionTypeID=2
			BEGIN
				--Value Discount 直接减钱
				DECLARE @disCountSum NUMERIC(18,2) --减掉的总金额
				IF (SELECT COUNT(*) FROM #PromotionProduct WHERE ValueDiscount>0 AND PromotionID=@promotionID)>0 --如果有数据
				BEGIN
					SELECT @disCountSum= SUM(ISNULL((CASE WHEN ISNULL(CAST(freePro.QTY/freePro.OwnQTY AS INT),0)>freePro.IsMultiple 
					THEN freePro.IsMultiple*freePro.ValueDiscount 
					ELSE ISNULL(CAST(freePro.QTY/freePro.OwnQTY AS INT),0)*freePro.ValueDiscount END ),0)) 
					FROM (SELECT OrderNO,SUM(LineAmount) AS LineAmount,OwnProductID,PromotionID,MAX(ValueDiscount) AS ValueDiscount,MAX(OwnQTY) AS OwnQTY,MAX(IsMultiple) AS IsMultiple,ProUom,SUM(QTY) AS QTY
							FROM #PromotionProduct GROUP BY OrderNO,OwnProductID,PromotionID,ProUom
						 ) freePro 
					WHERE ValueDiscount>0

					--已使用的促销信息添加到ORDER_LINES_PROMO表，以便报表使用
					IF(SELECT COUNT(*) FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID)=0
						INSERT INTO dbo.ORDER_LINES_PROMO
							( ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,
								PROMO_CLASS,DISCOUNT_VALUE,CALCULATE_TIME,UPLOAD_TIME)
						SELECT DISTINCT @Order_NO,@promotionID,op.CODE,op.NAME,op.TypeID,op.PromotionClass,@disCountSum,GETDATE(),GETDATE() 
						FROM dbo.ORDER_PROMOTION op
						WHERE op.ID=@promotionID AND VALID='1'
					ELSE
						UPDATE dbo.ORDER_LINES_PROMO SET DISCOUNT_VALUE=ISNULL(DISCOUNT_VALUE,0)+ISNULL(@disCountSum,0)
						WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID
				END
			END
			ELSE IF @PromotionTypeID=3
			BEGIN
				--Percentage Discount 百分比
				DECLARE @PercentageDiscountSum NUMERIC(18,2) --打折后减掉的总金额
				IF (SELECT COUNT(*) FROM #PromotionProduct WHERE PercentageDiscount>0 AND PromotionID=@promotionID)>0 --如果有数据
				BEGIN
					SET @Number=1
					SELECT @PercentageDiscountSum=SUM(CAST(CASE WHEN ISNULL(CAST(freePro.QTY/freePro.OwnQTY AS INT),0)>freePro.IsMultiple 
						THEN freePro.IsMultiple*freePro.UnitOwnQTY*LineAmount/UnitQty*freePro.PercentageDiscount/100
						ELSE ISNULL(CAST(freePro.QTY/freePro.OwnQTY AS INT),0)*freePro.UnitOwnQTY*LineAmount/UnitQty*freePro.PercentageDiscount/100 END as int))
					FROM (
						SELECT *
						,CASE WHEN ProUom='EC'
							THEN QTY/(SELECT p.EquivalentCases FROM dbo.PRODUCTS p WHERE p.ID=OwnProductID AND p.VALID='1')*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
							WHEN ProUom='CS'
							THEN QTY*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
							ELSE QTY
						END AS UnitQty
						,CASE WHEN ProUom='EC'
							THEN OwnQTY/(SELECT p.EquivalentCases FROM dbo.PRODUCTS p WHERE p.ID=OwnProductID AND p.VALID='1')*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
							WHEN ProUom='CS'
							THEN OwnQTY*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
							ELSE OwnQTY
						END AS UnitOwnQTY
							FROM(
							SELECT OrderNO,SUM(LineAmount) AS LineAmount,OwnProductID,PromotionID,MAX(PercentageDiscount) AS PercentageDiscount,MAX(OwnQTY) AS OwnQTY,MAX(IsMultiple) AS IsMultiple,ProUom,SUM(QTY) AS QTY
							FROM #PromotionProduct GROUP BY OrderNO,OwnProductID,PromotionID,ProUom
						)t
					) freePro 
											
					--已使用的促销信息添加到ORDER_LINES_PROMO表，以便报表使用
					IF(SELECT COUNT(*) FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID)=0
						INSERT INTO dbo.ORDER_LINES_PROMO
							( ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,
								PROMO_CLASS,DISCOUNT_VALUE,CALCULATE_TIME,UPLOAD_TIME)
						SELECT DISTINCT @Order_NO,@promotionID,op.CODE,op.NAME,op.TypeID,op.PromotionClass,@PercentageDiscountSum,GETDATE(),GETDATE() 
						FROM dbo.ORDER_PROMOTION op
						WHERE op.ID=@promotionID AND VALID='1'
					ELSE
						UPDATE dbo.ORDER_LINES_PROMO SET DISCOUNT_VALUE=ISNULL(DISCOUNT_VALUE,0)+ISNULL(@PercentageDiscountSum,0)
						WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID							          
				END                  
			END
  			ELSE IF @PromotionTypeID=4
			BEGIN
				--Free cases(By Pack)
				IF @n1=@n2
				BEGIN				
					SET @Number=1
					IF @minQty>0
						INSERT INTO Order_Lines(Order_NO,Product_ID,Uom_Code,UNIT_PRICE,PRODUCT_CODE,QUANTITY_ORDERED,QUANTITY_SHIPPED,LINE_AMOUNT,LINE_DISC_RATE,
						LINE_DISC_AMOUNT,LINE_TAX,LINE_TAX_AMOUNT,SKU_DISC_RATE,SKU_DISC_AMOUNT,DOMAIN_ID,REC_USER_CODE,REC_TIME_STAMP,CANCELLED,FREE_PRODUCTS,
						OrderLineStatus)
						SELECT 
						@Order_NO,freePro.FREE_PRODUCT_ID,freePro.FREE_UOM
						,0,p.CODE,(CASE WHEN @minIsMultiple>@minQty 
										THEN @minQty*freePro.FREE_QTY 
										ELSE @minIsMultiple*freePro.FREE_QTY END )  --赠品数量
						,0,0,0,0,0,0,0,0,1,'Calc_Promo_Standard',GETDATE(),'N',2,2
						FROM ORDER_PROMOTION_FREE_PRODUCT freePro
						INNER JOIN dbo.PRODUCTS p ON p.ID=freePro.FREE_PRODUCT_ID AND p.VALID='1'
						WHERE op_ID=@promotionID

					--已使用的促销信息添加到ORDER_LINES_PROMO表，以便报表使用
					IF(SELECT COUNT(*) FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID)=0                 
						INSERT INTO dbo.ORDER_LINES_PROMO
							( ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,
								PROMO_CLASS,FREE_QTY,FREE_UOM,CALCULATE_TIME,UPLOAD_TIME)
						SELECT DISTINCT @Order_NO,@promotionID,op.CODE,op.NAME,op.TypeID,op.PromotionClass
						,(SELECT SUM(ISNULL((CASE WHEN @minIsMultiple>@minQty 
									THEN @minQty*freePro.FREE_QTY 
									ELSE @minIsMultiple*freePro.FREE_QTY END),0))
							FROM ORDER_PROMOTION_FREE_PRODUCT freePro
							WHERE op_ID=op.ID)
						,(SELECT TOP 1 freePro.FREE_UOM
							FROM ORDER_PROMOTION_FREE_PRODUCT freePro
							WHERE op_ID=op.ID)
						,GETDATE(),GETDATE()
						FROM dbo.ORDER_PROMOTION op
						WHERE op.ID=@promotionID AND VALID='1'                     
					ELSE
						UPDATE dbo.ORDER_LINES_PROMO SET FREE_QTY=ISNULL(FREE_QTY,0)+(SELECT SUM(ISNULL((CASE WHEN @minIsMultiple>@minQty 
																			THEN @minQty*freePro.FREE_QTY 
																			ELSE @minIsMultiple*freePro.FREE_QTY END),0))
																			FROM ORDER_PROMOTION_FREE_PRODUCT freePro
																			WHERE op_ID=pp.PromotionID)
						FROM #PromotionProduct pp
						WHERE ORDER_NO=@Order_NO AND PROMO_ID=pp.PromotionID AND pp.PromotionID= @promotionID 
				END          
			END
  			ELSE IF @PromotionTypeID=5
			BEGIN
				--Value Discount(By Pack)
				DECLARE @disCountByPackSum NUMERIC(18,2),@ValueDiscount NUMERIC(18,2) --减掉的总金额 
				IF @n1=@n2
				BEGIN          
					IF (SELECT COUNT(*) FROM #PromotionProduct WHERE ValueDiscount>0 AND PromotionID=@promotionID)>0 --如果有数据
					BEGIN
						SET @Number=1					
						SELECT @ValueDiscount=MAX(ValueDiscount) FROM #PromotionProduct WHERE PromotionID=@promotionID
						SET @disCountByPackSum=ISNULL((CASE WHEN @minIsMultiple>@minQty 
									THEN @minQty*@ValueDiscount 
									ELSE @minIsMultiple*@ValueDiscount END ),0)

					--已使用的促销信息添加到ORDER_LINES_PROMO表，以便报表使用
					IF(SELECT COUNT(*) FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID)=0                  
						INSERT INTO dbo.ORDER_LINES_PROMO
							( ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,
								PROMO_CLASS,DISCOUNT_VALUE,CALCULATE_TIME,UPLOAD_TIME)
						SELECT DISTINCT @Order_NO,@promotionID,op.CODE,op.NAME,op.TypeID,op.PromotionClass,@disCountByPackSum,GETDATE(),GETDATE() 
						FROM dbo.ORDER_PROMOTION op
						WHERE op.ID=@promotionID AND VALID='1'
					ELSE                 
						UPDATE dbo.ORDER_LINES_PROMO SET DISCOUNT_VALUE=ISNULL(DISCOUNT_VALUE,0)+ISNULL(@disCountByPackSum,0)
						WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID
					END             
				END             
			END
  			ELSE IF @PromotionTypeID=6
			BEGIN
				--Percentage Discount(By Pack)
				DECLARE @PercentageDiscountByPackSum NUMERIC(18,2) --打折后减掉的总金额
				IF @n1=@n2
				BEGIN
					IF (SELECT COUNT(*) FROM #PromotionProduct WHERE PercentageDiscount>0 AND PromotionID=@promotionID)>0 --如果有数据
					BEGIN
						SET @Number=1
						SELECT @PercentageDiscountByPackSum=SUM(CAST(CASE WHEN @minIsMultiple>@minQty 
							THEN @minQty*freePro.UnitOwnQTY*LineAmount/UnitQty*freePro.PercentageDiscount/100
							ELSE @minIsMultiple*freePro.UnitOwnQTY*LineAmount/UnitQty*freePro.PercentageDiscount/100 END AS INT))
						FROM (
							SELECT *
							,CASE WHEN ProUom='EC'
								THEN QTY/(SELECT p.EquivalentCases FROM dbo.PRODUCTS p WHERE p.ID=OwnProductID AND p.VALID='1')*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
								WHEN ProUom='CS'
								THEN QTY*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
								ELSE QTY
							END AS UnitQty
							,CASE WHEN ProUom='EC'
								THEN OwnQTY/(SELECT p.EquivalentCases FROM dbo.PRODUCTS p WHERE p.ID=OwnProductID AND p.VALID='1')*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
								WHEN ProUom='CS'
								THEN OwnQTY*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=OwnProductID)
								ELSE OwnQTY
							END AS UnitOwnQTY
								FROM(
								SELECT OrderNO,SUM(LineAmount) AS LineAmount,OwnProductID,PromotionID,MAX(PercentageDiscount) AS PercentageDiscount,MAX(OwnQTY) AS OwnQTY,MAX(IsMultiple) AS IsMultiple,ProUom,SUM(QTY) AS QTY
								FROM #PromotionProduct GROUP BY OrderNO,OwnProductID,PromotionID,ProUom
							)t
						) freePro

						--已使用的促销信息添加到ORDER_LINES_PROMO表，以便报表使用
						IF(SELECT COUNT(*) FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID)=0
							INSERT INTO dbo.ORDER_LINES_PROMO
								( ORDER_NO,PROMO_ID,PROMO_CODE,PROMO_NAME,PROMO_TYPE_ID,
									PROMO_CLASS,DISCOUNT_VALUE,CALCULATE_TIME,UPLOAD_TIME)
							SELECT DISTINCT @Order_NO,@promotionID,op.CODE,op.NAME,op.TypeID,op.PromotionClass,@PercentageDiscountByPackSum,GETDATE(),GETDATE() 
							FROM dbo.ORDER_PROMOTION op
							WHERE op.ID=@promotionID AND VALID='1'
						ELSE                 
							UPDATE dbo.ORDER_LINES_PROMO SET DISCOUNT_VALUE=ISNULL(DISCOUNT_VALUE,0)+ISNULL(@PercentageDiscountByPackSum,0)
							WHERE ORDER_NO=@Order_NO AND PROMO_ID=@promotionID
					END
				END
			END        

			IF @Number=1
			BEGIN
				IF @IsSingleUse=1 --如果是单次促销，使用后修改相对信息
					UPDATE ORDER_PROMOTION_CUSTOMER SET IsUse='1'
														,orderNo=t.ORDER_NO
														,REC_USER_CODE='Calc_Promo_Standard'
														,REC_TIME_STAMP=GETDATE()
					FROM (SELECT * FROM dbo.ORDER_HEADERS WHERE ORDER_NO=@Order_NO) t
					WHERE dbo.ORDER_PROMOTION_CUSTOMER.CUSTOMER_ID=t.CUSTOMER_ID 
					AND dbo.ORDER_PROMOTION_CUSTOMER.PROMOTION_ID=@promotionID			             
			END

			--删除已经处理过的PromotionID，以免重复计算
			DELETE #PromotionProduct WHERE PromotionID=@promotionID
			DELETE #PromotionIDS WHERE promotionID=@promotionID  
		END

	UPDATE ORDER_PROMOTION_CUSTOMER	SET IsFirstVisit='0'
											,IsUse='1'
											,REC_TIME_STAMP=GETDATE()
											,REC_USER_CODE='Calc_Promo_Standard'
		FROM ORDER_PROMOTION OP(NOLOCK) ,ORDER_HEADERS OH(NOLOCK),ORDER_PROMOTION_CUSTOMER opc(NOLOCK)
		WHERE opc.PROMOTION_ID=OP.ID
				AND OH.ORDER_NO=@Order_NO
				AND OH.CUSTOMER_ID=opc.CUSTOMER_ID
				AND ISNULL(OP.UseType,0)=1
				AND ISNULL(opc.VALID,1)=1
				AND ISNULL(op.IsSingleUse,0)=1
				AND oh.ORDER_date BETWEEN OP.START_TIME AND DATEADD(DAY,1,OP.END_TIME)
				AND ISNULL(opc.IsFirstVisit,1)=1
        
	UPDATE dbo.ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN OrderType=0 
															THEN 
																TOTAL_AMOUNT- ISNULL(t.DiscountValue,0)                                                             
															 ELSE
																TOTAL_AMOUNT+ ISNULL(t.DiscountValue,0)
															 END
	
								,REC_TIME_STAMP=GETDATE()
								,REC_USER_CODE='Calc_Promo_Standard'
	FROM (SELECT SUM(ISNULL(DISCOUNT_VALUE,0)) AS DiscountValue,ORDER_NO FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO GROUP BY ORDER_NO)t
	WHERE dbo.ORDER_HEADERS.ORDER_NO=@Order_NO

	COMMIT TRAN Calc_Order

	DROP TABLE #PromotiomStr
	DROP TABLE #PromotionIDS
	DROP TABLE #PromotionProduct 
	
	RETURN 1
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN Calc_Order

		SET @error_code=@@error

		select @error_message =N'【订单编号:' + @Order_NO + N'】 【错误信息:' + convert(varchar(20),getdate(),120) + N'】错误位置：' 
		+ cast(@error_num as varchar(100)) + ' '+ cast(@error_code as varchar(100))+ ' ' + ERROR_MESSAGE()
		raiserror (@error_message,16,1)

		insert into  Error_Log(sys_Nam, Module_Nam, ErrDesc, UpdUsr, CrtDat)
		select 'CCVN4','Calc_Promo_Standard',@error_message,'CCVN4',getdate()
	
		DROP TABLE #PromotiomStr
		DROP TABLE #PromotionIDS
		DROP TABLE #PromotionProduct 
		RETURN @error_num
	END CATCH		 
END

