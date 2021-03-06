USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[SP_Calc_Promo_Myanmar]    Script Date: 11/23/2016 10:49:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [SP_Calc_Order_SRI_New] '136281502051723411',162,3757
ALTER PROCEDURE [dbo].[SP_Calc_Promo_Myanmar](@Order_NO nvarchar(30),@Org_ID int,@Chain_id int)
AS
BEGIN
	DECLARE @isUserPromotion INT  --判断是否使用第二种折扣
	,@opSum INT
	,@ppSum INT
	,@priceSum DECIMAL(10,2)
	,@priceSum1 DECIMAL(10,2)
	,@priceSum2 DECIMAL(10,2)
	,@proNum INT
	,@QTY INT 
	,@discountType INT
	,@discount DECIMAL(10,2)
	,@MDC_Cust_Prod_ID INT
	,@error_num int 
	,@error_code int
	,@error_message nvarchar(2000)

	DELETE FROM Order_lines
	WHERE Order_NO = @Order_NO
	AND Free_Products = 2
	AND REC_USER_CODE<>'Calc_Promo_Standard'

	--计算总价
	UPDATE Order_Headers SET Total_Amount =CASE WHEN OrderType=1 THEN  -isnull(T.Tatal_Amount,0)
											ELSE isnull(T.Tatal_Amount,0) END
									,REC_Time_Stamp   = getdate()
									,DISC_AMOUNT=CASE WHEN OrderType=1 THEN Total_Amount+ ISNULL(standPro.DiscountValue,0)
											ELSE Total_Amount- ISNULL(standPro.DiscountValue,0) END
	FROM (SELECT Sum(OL.Line_Amount) as Tatal_Amount
		  FROM Order_Lines OL(NOLOCK)
		  WHERE OL.Order_NO = @Order_NO) T
	LEFT JOIN (SELECT SUM(ISNULL(DISCOUNT_VALUE,0)) AS DiscountValue,ORDER_NO FROM ORDER_LINES_PROMO WHERE ORDER_NO=@Order_NO GROUP BY ORDER_NO) standPro ON standPro.ORDER_NO=@Order_NO
	WHERE Order_Headers.Order_NO = @Order_NO
    
	SELECT @isUserPromotion=IsUsePromotion FROM dbo.ORDER_HEADERS WHERE ORDER_NO=@Order_NO

	--查询用到新促销的sku start--------------
   	CREATE TABLE #SplitStringsPromotion 
	(
		[id] NUMERIC(20,0) ,
		[promotiomID] nvarchar(max)
	)
	DECLARE @id NUMERIC(20,0)
	DECLARE @StrPromotionID NVARCHAR(500)
	SELECT * INTO #temp FROM dbo.ORDER_LINES ol WHERE ORDER_NO=@Order_NO AND free_products<>2
	WHILE ((SELECT COUNT(*) FROM #temp)>0)
	BEGIN
		SELECT TOP 1 @id=ID,@StrPromotionID=promotion_id FROM #temp
		INSERT INTO #SplitStringsPromotion(id,promotiomID)
		SELECT OrderLineID,PromotionID FROM dbo.F_OrderLineSplit(@StrPromotionID,@id,',')
		DELETE #temp WHERE ID=@id
	END
    -----------------end--------------------

	--订单下的sku
	SET @error_num=100002
	SELECT DISTINCT PRODUCT_ID
	,ol.PRODUCT_CODE
	,CASE WHEN pp.OWN_UOM=ol.UOM_CODE 
	THEN  QUANTITY_ORDERED
	WHEN pp.OWN_UOM='EA' AND ol.UOM_CODE='CS' 
	THEN QUANTITY_ORDERED*(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID)
	ELSE CAST((QUANTITY_ORDERED/(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID)) AS NUMERIC(10,3)) 
	END QUANTITY_ORDERED
	,ol.promotion_id
	,(ISNULL(UNIT_PRICE,0)*QUANTITY_ORDERED) AS Price
	INTO #OrderLineProduct
	FROM (SELECT ORDER_NO,PRODUCT_ID,PRODUCT_CODE,UOM_CODE,QUANTITY_ORDERED,UNIT_PRICE,ssp.promotiomID AS promotion_id
			FROM dbo.ORDER_LINES ol
			INNER JOIN #SplitStringsPromotion ssp ON ol.ID=ssp.id
			) ol 
	INNER JOIN dbo.ORDER_HEADERS oh ON ol.ORDER_NO=oh.ORDER_NO
	INNER JOIN dbo.PROMOTION_PRODUCT pp ON ol.PRODUCT_CODE=pp.PRODUCT_CODE AND pp.VALID='1' AND pp.PROMOTION_ID=ol.promotion_id
	INNER JOIN dbo.PROMOTION_CUSTOMERS pc ON pc.CUSTOMER_ID=oh.CUSTOMER_ID AND pc.PROMOTION_ID=pp.PROMOTION_ID 
	INNER JOIN dbo.PROMOTIONS p ON p.ID=pc.PROMOTION_ID
	INNER JOIN dbo.ORGANIZATION org ON org.ParentID=p.Org_ID AND org.ID=@Org_ID
	WHERE oh.ORDER_NO=@Order_NO
	AND p.Start_Time<=oh.ORDER_date AND p.End_Time >=oh.ORDER_date
	AND pp.VALID='1' AND pc.VALID='1' AND p.Valid='1' AND p.Type=1

	--订单里面每个促销的sku数
	SET @error_num=100003
	SELECT COUNT(DISTINCT PRODUCT_ID) AS orderProNum,SUM(QUANTITY_ORDERED) AS QUANTITY_ORDERED,SUM(Price) AS Price,promotion_id 
	INTO #OrderPromotionProduct 
	FROM #OrderLineProduct GROUP BY promotion_id

	--促销的sku
	SET @error_num=100004
	SELECT COUNT(DISTINCT p.ID) AS promotionProNum,PROMOTION_ID 
	INTO #PromotionProduct 
	FROM PROMOTION_PRODUCT pp
	INNER JOIN dbo.PRODUCTS p ON p.CODE=pp.PRODUCT_CODE
	WHERE pp.VALID='1' GROUP BY pp.PROMOTION_ID


	--查询属于第一种促销里面的促销方式
	SET @error_num=100005
	SELECT pd.PromotionID,ISNULL(pd.FreeGoods,0) AS freeGoods,pd.DiscountType,isnull(pd.Discount,0) Discount 
	INTO #FirstPromotionFreeGoods 
	FROM #OrderPromotionProduct opp
	--INNER JOIN #PromotionProduct pp ON pp.PROMOTION_ID=opp.promotion_id AND opp.orderProNum=pp.promotionProNum
	INNER JOIN PROMOTION_DETAILS pd ON opp.promotion_id=pd.PromotionID
	WHERE pd.Valid='1' AND pd.MinValue<=opp.QUANTITY_ORDERED AND pd.MaxValue>=QUANTITY_ORDERED

	--查询属于第二种促销里面的促销方式
	--SELECT @proNum=COUNT(DISTINCT PRODUCT_ID),@QTY=SUM(QUANTITY_ORDERED) FROM #OrderLineProduct
	SET @error_num=100006
	SELECT @proNum=COUNT(DISTINCT t.PRODUCT_ID),@QTY=SUM(t.QUANTITY_ORDERED) FROM(
		SELECT PRODUCT_ID,PRODUCT_CODE,CASE UOM_CODE 
		WHEN 'EA' 
		THEN  CAST((QUANTITY_ORDERED/(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID)) AS NUMERIC(10,3))
		ELSE QUANTITY_ORDERED 
		END QUANTITY_ORDERED
		,(ISNULL(UNIT_PRICE,0)*QUANTITY_ORDERED) AS Price
		FROM dbo.ORDER_LINES(NOLOCK) ol 
		WHERE ORDER_NO=@Order_NO AND free_products<>2
	)t

	SET @error_num=100007
	DECLARE @PROMOTION_NAME NVARCHAR(30)
	SELECT TOP 1 @PROMOTION_NAME=P.[Name],@discountType=DiscountType,@discount=ISNULL(Discount,0)
	  FROM dbo.PROMOTION_DETAILS pd
	INNER JOIN (SELECT p.* FROM PROMOTIONS p
	INNER JOIN dbo.PROMOTION_CUSTOMERS pc ON p.ID=pc.PROMOTION_ID
	INNER JOIN ORDER_HEADERS oh ON oh.CUSTOMER_ID= pc.CUSTOMER_ID
	 WHERE p.Type=2 
			AND oh.ORDER_NO=@Order_NO
			AND p.Valid='1'
			AND p.Start_Time<=oh.ORDER_date AND p.End_Time >=oh.ORDER_date
	 ) p ON p.ID=pd.PromotionID
	INNER JOIN dbo.ORGANIZATION org ON org.ParentID=p.Org_ID
	WHERE pd.Valid='1' AND @proNum>=pd.TotalSKU AND @QTY>=TotalQty
			AND pd.FreeGoods=0 AND org.ID=@Org_ID
	ORDER BY TotalSKU DESC,TotalQty DESC
	
	
	--赠品
	SET @error_num=100008
	SELECT @opSum=COUNT(*) FROM #FirstPromotionFreeGoods WHERE freeGoods>0

	--打折或者直接减钱
	SET @error_num=100009
	SELECT @ppSum=COUNT(*) FROM #FirstPromotionFreeGoods WHERE freeGoods=0

	--赠品列表
	SET @error_num=100010
	SELECT t.op_ID AS PromotionID,t.FREE_PRODUCT_ID AS ProductID,t.FREE_UOM AS UOM,tt.freeGoods 
	INTO #FreeGoods 
	FROM PROMOTION_FREE_PRODUCT t
	INNER JOIN #FirstPromotionFreeGoods tt ON tt.PromotionID=t.op_ID
	WHERE tt.freeGoods>0

	BEGIN TRY
	BEGIN TRAN Calc_Order_New
	
	IF @opSum>0 --有赠品的情况
		BEGIN
			--添加赠品
			SET @error_num=100012
			INSERT INTO Order_Lines(Order_NO,Product_ID,Uom_Code,UNIT_PRICE,PRODUCT_CODE,QUANTITY_ORDERED,QUANTITY_SHIPPED,LINE_AMOUNT,LINE_DISC_RATE,
			LINE_DISC_AMOUNT,LINE_TAX,LINE_TAX_AMOUNT,SKU_DISC_RATE,SKU_DISC_AMOUNT,DOMAIN_ID,REC_USER_CODE,REC_TIME_STAMP,CANCELLED,FREE_PRODUCTS,own_pro_id,
			OrderLineStatus,promotion_id,Promotion_TypeID,Promotion_Detail)
			SELECT 
			@Order_NO,pfp.ProductID,pfp.UOM
			,0,p.CODE,pfp.freeGoods --赠品数量
			,0,0,0,0,0,0,0,0,1,'Calc_Promo_Myanmar',GETDATE(),'N',2,pfp.ProductID
			,1,pfp.PromotionID,1,pom.Name
			FROM #FreeGoods pfp
			INNER JOIN dbo.PRODUCTS p ON p.ID=pfp.ProductID
			INNER JOIN dbo.PROMOTIONS pom ON pom.ID=pfp.PromotionID
		END   

	IF @ppSum>0 --有打折的情况
		BEGIN
			--折扣+减去的价格  
			SET @error_num=100013
			SELECT @priceSum=SUM(t.Price) FROM(
			SELECT 
			 CASE WHEN tpf.DiscountType =1 THEN tpf.Discount
			 ELSE opp.Price*(tpf.Discount)/100.0 END AS Price
			 FROM #OrderPromotionProduct opp
			INNER JOIN #FirstPromotionFreeGoods tpf ON opp.promotion_id=tpf.PromotionID
			WHERE tpf.freeGoods=0)t

			SET @error_num=100014
			UPDATE dbo.ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN OrderType=0 
															THEN 
																CASE WHEN ISNULL(DISC_AMOUNT,0)=0 
																	 THEN ISNULL(TOTAL_AMOUNT,0)-ISNULL(@priceSum,0)
																	 ELSE ISNULL(DISC_AMOUNT,0)-ISNULL(@priceSum,0) END                                                             
															 ELSE
																CASE WHEN ISNULL(DISC_AMOUNT,0)=0
																	 THEN ISNULL(TOTAL_AMOUNT,0)+ISNULL(@priceSum,0) 
																	 ELSE ISNULL(DISC_AMOUNT,0)+ISNULL(@priceSum,0) END
															 END
  											,REC_TIME_STAMP=GETDATE()
											,REC_USER_CODE='Calc_Promo_Myanmar'                                                           
			WHERE ORDER_NO=@Order_NO       
		END

	IF @isUserPromotion=1--第二种情况
		BEGIN			    
			SET @error_num=100015        
			IF @discount IS NOT NULL             
				UPDATE dbo.ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN @discountType=1 
																THEN CASE WHEN OrderType=0 THEN ISNULL(CASE WHEN ISNULL(DISC_AMOUNT,0)=0 
																										THEN TOTAL_AMOUNT-@discount*@QTY 
																										ELSE DISC_AMOUNT-@discount*@QTY 
																										END,0)
																						   ELSE ISNULL(CASE WHEN ISNULL(DISC_AMOUNT,0)=0 
																										THEN TOTAL_AMOUNT+@discount*@QTY 
																										ELSE DISC_AMOUNT+@discount*@QTY
																										END,0)
																							END
																ELSE ISNULL(CASE WHEN ISNULL(DISC_AMOUNT,0)=0 
																										THEN TOTAL_AMOUNT*((100.0-@discount)/100.0) 
																										ELSE DISC_AMOUNT*((100.0-@discount)/100.0) 
																										END,0)
																END 
											,REC_TIME_STAMP=GETDATE()
											,REC_USER_CODE='Calc_Promo_Myanmar'
				WHERE ORDER_NO=@Order_NO

				UPDATE dbo.ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN OrderType=0 THEN ISNULL(DISC_AMOUNT,0) - DISC_1
																			   ELSE ISNULL(DISC_AMOUNT,0) + DISC_1 END
											,REC_TIME_STAMP=GETDATE()
											,REC_USER_CODE='Calc_Promo_Myanmar'
				WHERE ORDER_NO=@Order_NO
				
				--IF @PROMOTION_NAME IS NOT NULL
				--	UPDATE dbo.ORDER_LINES 
				--	SET Promotion_Detail = case when isnull(Promotion_Detail,'')='' THEN '' ELSE Promotion_Detail+',' END + @PROMOTION_NAME
				--	WHERE ORDER_NO=@Order_NO
		END    
	


	COMMIT TRAN Calc_Order_New

	DROP TABLE #OrderLineProduct
	DROP TABLE #OrderPromotionProduct
	DROP TABLE #PromotionProduct
	DROP TABLE #FirstPromotionFreeGoods
	DROP TABLE #FreeGoods
	DROP TABLE #SplitStringsPromotion
	DROP TABLE #temp

	--Auto Confirm order
	--exec SP_AutoConfirm_NEW @Order_NO

		RETURN 1
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN Calc_Order_New

		SET @error_code=@@error

		select @error_message =N'【订单编号:' + @Order_NO + N'】 【错误信息:' + convert(varchar(20),getdate(),120) + N'】错误位置：' 
		+ cast(@error_num as varchar(100)) + ' '+ cast(@error_code as varchar(100))+ ' ' + ERROR_MESSAGE()
		raiserror (@error_message,16,1)

		insert into  Error_Log(sys_Nam, Module_Nam, ErrDesc, UpdUsr, CrtDat)
		select 'SFADB','Calc_Promo_Myanmar',@error_message,'SFADB',getdate()
		
		DROP TABLE #OrderLineProduct
		DROP TABLE #OrderPromotionProduct
		DROP TABLE #PromotionProduct
		DROP TABLE #FirstPromotionFreeGoods
		DROP TABLE #FreeGoods
		DROP TABLE #SplitStringsPromotion
		DROP TABLE #temp
		RETURN @error_num
	END CATCH			  
END
