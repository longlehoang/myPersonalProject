USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[SP_Calc_Promo_Vietnam]    Script Date: 10/13/2016 4:08:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [SP_Calc_Order_SRI_New] '136281502051723411',162,3757
ALTER PROCEDURE [dbo].[SP_Calc_Promo_Vietnam](@Order_NO nvarchar(30),@Org_ID int,@Chain_id int)
AS
BEGIN
	DECLARE @isUserPromotion INT  --判断是否使用第二种折扣
	,@opSum INT
	,@ppSum INT
	,@priceSum DECIMAL(10,2)
	,@proNum INT
	,@discountType INT
	,@discount DECIMAL(10,2)
	,@MDC_Cust_Prod_ID INT
	,@error_num int 
	,@error_code INT
	,@error_message nvarchar(2000)
	,@maxEc INT
	,@promotionID INT  
	,@ecCount INT 
    
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

    
	--SELECT @isUserPromotion=IsUsePromotion FROM dbo.ORDER_HEADERS WHERE ORDER_NO=@Order_NO

	--订单下的sku
	SET @error_num=100002
	SELECT t1.ORDER_NO,t1.PRODUCT_ID,SUM(ISNULL(t1.QTYEC,0)) AS QTYEC
	INTO #OrderProducts FROM(
			SELECT DISTINCT 
			ol.ORDER_NO
			,PRODUCT_ID
			,UOM_CODE
			,CASE WHEN UOM_CODE='CS' THEN QUANTITY_ORDERED*ISNULL(p.EquivalentCases,0) --CS 转换成EC
				ELSE CAST((QUANTITY_ORDERED/(SELECT DENOMINATOR FROM PRODUCT_UOMS WHERE PRODUCT_UOMS.PRODUCT_ID=ol.PRODUCT_ID)) AS NUMERIC(10,3))*ISNULL(p.EquivalentCases,0) --EA转换成EC，需要先转换成CS再转换成EC			
			 END AS QTYEC
			FROM dbo.ORDER_LINES(NOLOCK) ol		
			LEFT JOIN dbo.PRODUCTS p ON ol.PRODUCT_ID=P.ID 
			WHERE ORDER_NO=@Order_NO AND free_products<>2 AND p.VALID='1' AND QUANTITY_ORDERED>0
		)t1 GROUP BY t1.ORDER_NO,t1.PRODUCT_ID
	
	--计算EC
	SELECT t.ORDER_NO,oh.OrderType,0 AS skus,0 AS skuEc,cast(SUM(QTYEC) as int) AS qtyEc ,MAX(oh.TOTAL_AMOUNT) AS TOTAL_AMOUNT
	INTO #OrderLine 
	FROM #OrderProducts t
	INNER JOIN dbo.ORDER_HEADERS oh ON oh.ORDER_NO=t.ORDER_NO
	 GROUP BY t.ORDER_NO,oh.OrderType

	--统计SKU数,符合条件的SKU数
	UPDATE #OrderLine SET skus=ISNULL(t._skus,0),skuEc=ISNULL(t._skuEc,0)
	FROM (SELECT COUNT(PRODUCT_ID) AS _skus,SUM(CAST(QTYEC AS INT)) AS _skuEc FROM #OrderProducts WHERE qtyEc>=1)t

	--查询当前订单下的总EC
	SELECT @ecCount=qtyEc FROM #OrderLine

	--查询当前的type=1的max Ec的值
	SELECT DISTINCT @maxEc=MAX(MaxValue),@promotionID= pd.PromotionID FROM dbo.PROMOTION_DETAILS pd 
	INNER  JOIN PROMOTIONS p ON p.ID=pd.PromotionID
	INNER JOIN dbo.ORGANIZATION org ON org.ParentID=p.Org_ID
	INNER JOIN dbo.PROMOTION_CUSTOMERS pc ON p.ID=pc.PROMOTION_ID
	INNER JOIN ORDER_HEADERS oh ON oh.CUSTOMER_ID= pc.CUSTOMER_ID AND oh.ORDER_NO=@Order_NO
	WHERE pd.Valid='1' AND p.Valid='1' AND pc.VALID='1' AND p.Type=1 AND p.Start_Time<=oh.ORDER_date AND p.End_Time >=oh.ORDER_date  
	GROUP BY pd.PromotionID

	CREATE TABLE #FirstPromotion(
	 Order_NO NVARCHAR(30)
	,PromotionID INT
	,PromotionName NVARCHAR(50)  
	,freeGoods INT
	,DiscountType INT
	,Discount DECIMAL
	,MinValue int
	,MaxValue int
	)

	--查询符合范围的促销
	IF @ecCount >@maxEc --实际EC数大于设置的最大EC数时取最大的计算
		INSERT INTO #FirstPromotion
		SELECT DISTINCT TOP 1 @Order_NO, pd.PromotionID,p.Name AS PromotionName,ISNULL(pd.FreeGoods,0) AS freeGoods,ISNULL(pd.DiscountType,0) AS DiscountType,isnull(pd.Discount,0) Discount,MinValue,MaxValue
		FROM PROMOTION_DETAILS pd 
		INNER JOIN(SELECT MAX(DetailNo) AS DetailNo,@promotionID AS PromotionID FROM dbo.PROMOTION_DETAILS WHERE PromotionID=@promotionID GROUP BY PromotionID HAVING MAX(MaxValue)=@maxEc)tt ON tt.DetailNo=pd.DetailNo AND tt.PromotionID=pd.PromotionID
		INNER  JOIN PROMOTIONS p ON p.ID=pd.PromotionID
		ORDER BY MinValue DESC,MaxValue      
	ELSE  
		INSERT INTO #FirstPromotion
		SELECT DISTINCT TOP 1 opp.ORDER_NO, pd.PromotionID,p.Name AS PromotionName,ISNULL(pd.FreeGoods,0) AS freeGoods,ISNULL(pd.DiscountType,0) AS DiscountType,isnull(pd.Discount,0) Discount,MinValue,MaxValue
		FROM #OrderLine opp
		INNER JOIN dbo.PROMOTION_DETAILS pd ON pd.MinValue<=opp.qtyEc AND pd.MaxValue>=opp.qtyEc AND PromotionID=@promotionID
		INNER  JOIN PROMOTIONS p ON p.ID=pd.PromotionID
		ORDER BY MinValue DESC,MaxValue DESC

	--赠品
	SET @error_num=100008
	SELECT @opSum=COUNT(*) FROM #FirstPromotion WHERE freeGoods>0

	--打折或者直接减钱
	SET @error_num=100009
	SELECT @ppSum=COUNT(*) FROM #FirstPromotion WHERE freeGoods=0

	--赠品列表
	SET @error_num=100010
	SELECT t.PromotionID,tt.FREE_PRODUCT_ID,tt.FREE_UOM,t.freeGoods INTO #FreeGoods
	 FROM #FirstPromotion t
	INNER JOIN PROMOTION_FREE_PRODUCT tt ON tt.op_ID=t.PromotionID
	WHERE t.freeGoods>0

	BEGIN TRY
	BEGIN TRAN Calc_Order_EC

	--第一种促销时修改订单行的促销明细字段	
	SET @error_num=100011
	--UPDATE dbo.ORDER_LINES SET Promotion_Detail=t.PromotionName
	--FROM #FirstPromotion t
	--WHERE t.ORDER_NO=dbo.ORDER_LINES.ORDER_NO COLLATE Chinese_PRC_CI_AS
	
	
	IF @opSum>0 --有赠品的情况
		BEGIN
			--添加赠品
			SET @error_num=100012
			INSERT INTO Order_Lines(Order_NO,Product_ID,Uom_Code,UNIT_PRICE,PRODUCT_CODE,QUANTITY_ORDERED,QUANTITY_SHIPPED,LINE_AMOUNT,LINE_DISC_RATE,
			LINE_DISC_AMOUNT,LINE_TAX,LINE_TAX_AMOUNT,SKU_DISC_RATE,SKU_DISC_AMOUNT,DOMAIN_ID,REC_USER_CODE,REC_TIME_STAMP,CANCELLED,FREE_PRODUCTS,own_pro_id,
			OrderLineStatus,promotion_id,Promotion_TypeID,Promotion_Detail)
			SELECT 
			@Order_NO,pfp.FREE_PRODUCT_ID,pfp.FREE_UOM
			,0,p.CODE,pfp.freeGoods --赠品数量
			,0,0,0,0,0,0,0,0,1,'SP_Calc_Order_EC',GETDATE(),'N',2,pfp.FREE_PRODUCT_ID
			,1,pfp.PromotionID,1,pom.Name
			FROM #FreeGoods pfp
			INNER JOIN dbo.PRODUCTS p ON p.ID=pfp.FREE_PRODUCT_ID
			INNER JOIN dbo.PROMOTIONS pom ON pom.ID=pfp.PromotionID
		END   

	IF @ppSum>0 --有打折的情况
		BEGIN
			--折扣+减去的价格  
			SET @error_num=100013
			SELECT @priceSum=SUM(t.Price) FROM(
				SELECT
					 CASE WHEN tpf.DiscountType =1 THEN CASE WHEN @maxEc>qtyEc THEN tpf.Discount*qtyEc else tpf.Discount*@maxEc END
					 ELSE ol.TOTAL_AMOUNT*(tpf.Discount)/100.0
				END AS Price
			 FROM #OrderLine ol
			INNER JOIN #FirstPromotion tpf ON ol.ORDER_NO=tpf.ORDER_NO COLLATE Chinese_PRC_CI_AS
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
			WHERE ORDER_NO=@Order_NO
		END 
	--ELSE
	--	BEGIN
	--		UPDATE dbo.ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN ISNULL(DISC_AMOUNT,0)=0 THEN ISNULL(TOTAL_AMOUNT-@priceSum,0) ELSE ISNULL(DISC_AMOUNT-@priceSum,0) END
	--		WHERE ORDER_NO=@Order_NO
	--	END 

	SET @error_num=100006
	SELECT DISTINCT TOP 1 opp.ORDER_NO,opp.OrderType, pd.PromotionID,p.Name AS PromotionName,opp.skus,opp.qtyEc AS skuEc,ISNULL(pd.FreeGoods,0) AS freeGoods,ISNULL(pd.DiscountType,0) AS DiscountType,CASE WHEN @maxEc>opp.qtyEc THEN isnull(pd.Discount,0)*opp.qtyEc ELSE isnull(pd.Discount,0)*@maxEc END AS DisPrice,TotalSKU,TotalQty
	INTO #SecondPromotion
	FROM #OrderLine opp
	INNER JOIN dbo.PROMOTION_DETAILS pd ON pd.TotalSKU<=opp.skus AND pd.TotalQty>=opp.skus
	INNER  JOIN PROMOTIONS p ON p.ID=pd.PromotionID
	INNER JOIN dbo.ORGANIZATION org ON org.ParentID=p.Org_ID
	INNER JOIN dbo.PROMOTION_CUSTOMERS pc ON p.ID=pc.PROMOTION_ID
	INNER JOIN ORDER_HEADERS oh ON oh.CUSTOMER_ID= pc.CUSTOMER_ID AND oh.ORDER_NO=opp.ORDER_NO
	WHERE pd.Valid='1' AND p.Valid='1' AND pc.VALID='1' AND p.Type=2 AND p.Start_Time<=oh.ORDER_date AND p.End_Time >=oh.ORDER_date
	ORDER BY TotalSKU DESC,TotalQty DESC
    
	IF (SELECT COUNT(*) FROM #SecondPromotion)>0
		BEGIN		
			UPDATE dbo.ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN sp.OrderType=0 
															THEN 
																CASE WHEN ISNULL(DISC_AMOUNT,0)=0 
																	 THEN ISNULL(TOTAL_AMOUNT,0)-ISNULL(sp.DisPrice,0)
																	 ELSE ISNULL(DISC_AMOUNT,0)-ISNULL(sp.DisPrice,0) END                                                             
															 ELSE
																CASE WHEN ISNULL(DISC_AMOUNT,0)=0
																	 THEN ISNULL(TOTAL_AMOUNT,0)+ISNULL(sp.DisPrice,0) 
																	 ELSE ISNULL(DISC_AMOUNT,0)+ISNULL(sp.DisPrice,0) END
															 END
			FROM #SecondPromotion sp
			WHERE ORDER_HEADERS.ORDER_NO=sp.ORDER_NO

			--UPDATE dbo.ORDER_LINES SET Promotion_Detail = case when isnull(Promotion_Detail,'')='' THEN '' ELSE Promotion_Detail+',' END + sp.PromotionName
			--FROM #SecondPromotion sp
			--WHERE ORDER_LINES.ORDER_NO=sp.ORDER_NO      
		END

	COMMIT TRAN Calc_Order_EC

	DROP TABLE #OrderProducts
	DROP TABLE #OrderLine
	DROP TABLE #FirstPromotion
	DROP TABLE #FreeGoods
	DROP TABLE #SecondPromotion

		RETURN 1
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN Calc_Order_EC

		SET @error_code=@@error

		select @error_message =N'【订单编号:' + @Order_NO + N'】 【错误信息:' + convert(varchar(20),getdate(),120) + N'】错误位置：' 
		+ cast(@error_num as varchar(100)) + ' '+ cast(@error_code as varchar(100))+ ' ' + ERROR_MESSAGE()
		raiserror (@error_message,16,1)

		insert into  Error_Log(sys_Nam, Module_Nam, ErrDesc, UpdUsr, CrtDat)
		select 'SFADB','SP_Calc_Confirm_Order_New',@error_message,'SFADB',getdate()
		
		DROP TABLE #OrderProducts
		DROP TABLE #OrderLine
		DROP TABLE #FirstPromotion
		DROP TABLE #FreeGoods
		DROP TABLE #SecondPromotion
		RETURN @error_num
	END CATCH			  
END
