USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[USP_Calc_Order_Price]    Script Date: 11/23/2016 10:18:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[USP_Calc_Order_Price](@Order_NO nvarchar(30),@Status int)
as
begin

	DECLARE @Tax_Rate numeric(10,2) =0.00,
		@Tax_Type bit,
		@error_num int,
		@error_code int,
		@error_message nvarchar(2000),
		@MDC_Cust_Prod_ID int,
		@CustomerID int,
		@Org_ID int,
		@Chain_id int

	SELECT @CustomerID=customer_id,@Org_ID= org_id,@Chain_id= CHAIN_ID FROM ORDER_HEADERS WHERE ORDER_NO=@Order_NO
	
	SET @error_num=100100
	SELECT @Tax_Type=cast(cast(CodeValue as int) as bit) FROM sfaCodeDesc (NOLOCK)
	WHERE CountryId = CASE WHEN CountryId='*' THEN CountryId ELSE cast(dbo.FN_GETParentID(@Org_ID,1) as nvarchar) END
	AND SalesOrg = CASE WHEN SalesOrg='*' then SalesOrg else cast(dbo.FN_GETParentID(@Org_ID,3) as nvarchar) END
	AND CodeCategory = 'Tax_Type'
	AND DeleteFlag = 0

	SET @error_num=100110
	SELECT @Tax_Rate = cast(CodeValue as numeric(10,2))/100 FROM sfaCodeDesc (NOLOCK)
	WHERE CountryId = CASE WHEN CountryId='*' THEN CountryId ELSE cast(dbo.FN_GETParentID(@Org_ID,1) as nvarchar) END
	AND SalesOrg = CASE WHEN SalesOrg='*' then SalesOrg else cast(dbo.FN_GETParentID(@Org_ID,3) as nvarchar) END
	AND CodeCategory = 'Tax_Rate'
	AND DeleteFlag = 0
	
	SET @error_num = 100112
	SELECT @MDC_Cust_Prod_ID = customer_product_list_id
	FROM Customers(NOLOCK)
	WHERE ID = (SELECT Customer_ID FROM Order_Headers(NOLOCK) WHERE ORDER_NO = @Order_NO)
	IF(@MDC_Cust_Prod_ID IS NOT NULL)
	BEGIN
		if (SELECT VALID FROM MDC_Cust_Prod_Lists WHERE ID=@MDC_Cust_Prod_ID)=0
		SET @MDC_Cust_Prod_ID=NULL
	END

	CREATE TABLE #MDC_PROD_LIST_ITEMS
	(MDC_PRODUCT_LIST_ID numeric(10, 0) NOT NULL,
	PRODUCT_ID int NOT NULL,
	PIECE_PRICE numeric(15, 4) NULL,
	CASE_PRICE numeric(15, 4) NULL,
	DISCOUNT int NULL,
	TAX int NULL,
	LandingPriceEA numeric(15,4) null,
	LandingPriceCS numeric(15,4) null
	)
	SET @error_num = 100113
	IF(@MDC_Cust_Prod_ID IS NOT NULL)
	BEGIN 
		Insert into #MDC_PROD_LIST_ITEMS
		SELECT @Chain_ID as ID,MC.PRODUCT_ID,MC.PIECE_PRICE,MC.CASE_PRICE,MC.DISCOUNT
			,isnull(MC.Tax,0) as TAX,MC.PIECE_PRICE as LandingPriceEA,MC.CASE_PRICE as LandingPriceCS
		FROM MDC_CUST_PROD_LIST_ITEMS MC (NOLOCK)
		WHERE MC.MDC_CUST_PROD_LIST_ID = @MDC_Cust_Prod_ID
	END
	ELSE
	BEGIN
		Insert into #MDC_PROD_LIST_ITEMS
		SELECT MP.MDC_PRODUCT_LIST_ID,MP.PRODUCT_ID,MP.PIECE_PRICE,MP.CASE_PRICE,MP.DISCOUNT,MP.TAX
			,MP.LandingPriceEA,MP.LandingPriceCS
		FROM MDC_PROD_LIST_ITEMS MP (NOLOCK)
		WHERE MP.MDC_Product_List_ID = @Chain_ID
		
	END
	begin try
	begin tran
	if @Status = 0 --Status=0 Îª²åÈë¶©µ¥£¬1ÎªComfirmed¶©µ¥
	begin
		DELETE FROM Order_lines
		WHERE Order_NO = @Order_NO
		AND Free_Products >= 1

		if @Tax_Type = 1--1ÊÇ¶©µ¥Í·ÖÐÊ¹ÓÃÍ³Ò»µÄTax_Rate£¬0ÊÇ°´¶©µ¥ÐÐ¼ÆË°
		begin
			SET @error_num = 100115
			UPDATE Order_Lines SET Unit_Price       = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)
									,Line_Amount      = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Ordered
									,Line_Tax         = 0
									,Line_Tax_Amount  =(CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Ordered
									,SKU_DISC_AMOUNT = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.CASE_PRICE-MD.LandingPriceCS
														ELSE MD.PIECE_PRICE-MD.LandingPriceEA
														END)*Order_Lines.Quantity_Ordered
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE	  ='USP_Calc_Order_Price'
									
			FROM #MDC_PROD_LIST_ITEMS MD
			WHERE MD.Product_ID = Order_Lines.Product_ID
			AND MD.MDC_Product_List_ID = @Chain_ID
			AND Order_Lines.Order_NO = @Order_NO
			AND Order_lines.FREE_PRODUCTS<=1

			SET @error_num = 100116
			UPDATE Order_Headers SET Total_Amount = isnull(T.Tatal_Amount,0)
									,Tax_Rate	  = @Tax_Rate
									,Tax_Amount   = isnull((T.Tatal_Amount)*(@Tax_Rate),0)
									,DISC_1		  = t.disc_1
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE	  ='USP_Calc_Order_Price'
			FROM (SELECT Sum(OL.Line_Amount) as Tatal_Amount,sum(OL.SKU_DISC_AMOUNT) as disc_1
				  FROM Order_Lines OL
				  WHERE OL.Order_NO = @Order_NO) T
			WHERE Order_Headers.Order_NO = @Order_NO

		end
		else
		begin
			SET @error_num = 100117
			UPDATE Order_Lines SET Unit_Price       = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)
									,Line_Amount      = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Ordered
									,Line_Disc_Rate   = 0--MD.Discount
									,Line_Disc_Amount = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Ordered
									,Line_Tax         = MD.TAX
									,Line_Tax_Amount  =((CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Ordered)*(1+(MD.Tax/100.00))
									,SKU_DISC_AMOUNT  =((CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price-MD.LandingPriceCS
														ELSE MD.Piece_Price-MD.LandingPriceEA
														END)*Order_Lines.Quantity_Ordered)
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE    = 'USP_Calc_Order_Price'
			FROM #MDC_PROD_LIST_ITEMS MD
			WHERE MD.Product_ID = Order_Lines.Product_ID
			AND MD.MDC_Product_List_ID = @Chain_ID
			AND Order_Lines.Order_NO = @Order_NO	
			AND Order_lines.FREE_PRODUCTS<=1

			SET @error_num = 100118
			UPDATE Order_Headers SET Total_Amount = isnull(T.Tatal_Amount,0)
									,Tax_Rate	  = 0
									,Tax_Amount   = T.LINE_TAX_AMOUNT
									,DISC_1		  = t.disc_1
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE = 'USP_Calc_Order_Price'
			FROM (SELECT Sum(OL.Line_Amount)as Tatal_Amount,sum(LINE_TAX_AMOUNT) as LINE_TAX_AMOUNT 
						,sum(OL.SKU_DISC_AMOUNT) as disc_1
				  FROM Order_Lines OL
				  WHERE OL.Order_NO = @Order_NO) T
			WHERE Order_Headers.Order_NO = @Order_NO

		end
		SET @error_num = 100119
		UPDATE ORDER_HEADERS SET TOTAL_QUANTITY = (select sum(case ol.uom_Code when 'CS' then ol.QUANTITY_ORDERED else 
													cast(ol.QUANTITY_ORDERED as numeric(10,2))/isnull(pu.DENOMINATOR,1) end) as Total_Quanitity
													from order_lines ol left join PRODUCT_UOMS pu on ol.PRODUCT_ID = pu.PRODUCT_ID and pu.VALID =1
													where ol.ORDER_NO = @Order_NO)
								,REC_USER_CODE = 'USP_Calc_Order_Price'
		where ORDER_NO = @Order_NO
	end
	else 
	begin
		SET @error_num = 100210
		DELETE FROM Order_lines
		WHERE Order_NO = @Order_NO
		AND Free_Products >= 1

		if @Tax_Type = 1
		begin
			SET @error_num = 100212
			UPDATE Order_Lines SET Unit_Price       = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)
									,Line_Amount      = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Confirmed
									,Line_Tax         = 0
									,Line_Tax_Amount  =(CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Confirmed
									,SKU_DISC_AMOUNT  =(CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price-MD.LandingPriceCS
														ELSE MD.PIECE_PRICE-MD.LandingPriceEA
														END)*Order_Lines.Quantity_Confirmed
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE	  =  'USP_Calc_Order_Price'
			FROM #MDC_PROD_LIST_ITEMS MD
			WHERE MD.Product_ID = Order_Lines.Product_ID
			AND MD.MDC_Product_List_ID = @Chain_ID
			AND Order_Lines.Order_NO = @Order_NO
			AND Order_lines.FREE_PRODUCTS <= 1

			SET @error_num = 100213
			UPDATE Order_Headers SET Total_Amount = isnull(T.Tatal_Amount,0)
									,Tax_Rate	  = @Tax_Rate
									,Tax_Amount   = isnull((T.Tatal_Amount)*(@Tax_Rate),0)
									,DISC_1		  = t.disc_1
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE = 'USP_Calc_Order_Price'
			FROM (SELECT Sum(OL.Line_Amount) as Tatal_Amount,sum(OL.SKU_DISC_AMOUNT) as disc_1
				  FROM Order_Lines OL
				  WHERE OL.Order_NO = @Order_NO) T
			WHERE Order_Headers.Order_NO = @Order_NO

		end
		else
		begin
			SET @error_num = 100214
			UPDATE Order_Lines SET Unit_Price       = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)
									,Line_Amount      = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Confirmed
									,Line_Disc_Rate   = 0--MD.Discount
									,Line_Disc_Amount = (CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Confirmed
									,Line_Tax         = MD.TAX
									,Line_Tax_Amount  =((CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price 
														ELSE MD.Piece_Price
														END)*Order_Lines.Quantity_Confirmed)*(1+(MD.Tax/100.00))
									,SKU_DISC_AMOUNT  =((CASE Order_Lines.Uom_Code 
														WHEN 'CS' THEN MD.Case_Price-MD.LandingPriceCS
														ELSE MD.Piece_Price-MD.LandingPriceEA
														END)*Order_Lines.Quantity_Confirmed)
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE	  = 'USP_Calc_Order_Price'
			FROM #MDC_PROD_LIST_ITEMS MD
			WHERE MD.Product_ID = Order_Lines.Product_ID
			AND MD.MDC_Product_List_ID = @Chain_ID
			AND Order_Lines.Order_NO = @Order_NO	
			AND Order_lines.FREE_PRODUCTS <= 1

			SET @error_num = 100215
			UPDATE Order_Headers SET Total_Amount = isnull(T.Tatal_Amount,0)
									,Tax_Rate	  = 0
									,Tax_Amount   = T.LINE_TAX_AMOUNT
									,DISC_1		  = t.disc_1
									,REC_Time_Stamp   = getdate()
									,REC_USER_CODE ='USP_Calc_Order_Price'
			FROM (SELECT Sum(OL.Line_Amount)as Tatal_Amount,sum(LINE_TAX_AMOUNT) as LINE_TAX_AMOUNT 
						,Sum(OL.SKU_DISC_AMOUNT) as disc_1
				  FROM Order_Lines OL
				  WHERE OL.Order_NO = @Order_NO) T
			WHERE Order_Headers.Order_NO = @Order_NO

		end

		SET @error_num = 100216
		UPDATE ORDER_HEADERS SET TOTAL_QUANTITY = (select sum(case ol.uom_Code when 'CS' then ol.Quantity_Confirmed else 
													cast(ol.Quantity_Confirmed as numeric(10,2))/isnull(pu.DENOMINATOR,1) end) as Total_Quanitity
													from order_lines ol left join PRODUCT_UOMS pu on ol.PRODUCT_ID = pu.PRODUCT_ID and pu.VALID =1
													where ol.ORDER_NO = @Order_NO)
								,REC_USER_CODE ='USP_Calc_Order_Price'
		where ORDER_NO = @Order_NO

	end

	UPDATE ORDER_HEADERS SET DISC_AMOUNT=CASE WHEN OrderType=0 
                                                            THEN 
                                                                TOTAL_AMOUNT - DISC_1                                                             
                                                             ELSE
                                                                TOTAL_AMOUNT + DISC_1
                                                             END
    
                                ,REC_TIME_STAMP=GETDATE()
                                ,REC_USER_CODE='USP_Calc_Order_Price'
	where ORDER_NO = @Order_NO

	DROP TABLE #MDC_PROD_LIST_ITEMS
	commit
	end try
	begin catch
	ROLLBACK 

		SET @error_code=@@error

		select @error_message =N'¡¾¶©µ¥±àºÅ:' + @Order_NO + N'¡¿ ¡¾´íÎóÐÅÏ¢:' + convert(varchar(20),getdate(),120) + N'¡¿´íÎóÎ»ÖÃ£º' 
		+ cast(@error_num as varchar(100)) + ' '+ cast(@error_code as varchar(100))+ ' ' + ERROR_MESSAGE()
		raiserror (@error_message,16,1)

		insert into Error_Log(sys_Nam, Module_Nam, ErrDesc, UpdUsr, CrtDat)
		select 'SFADB','USP_Calc_Order_Price',@error_message,'SFADB',getdate()
		
		DROP TABLE #MDC_PROD_LIST_ITEMS
		RETURN @error_num
	end catch
end



