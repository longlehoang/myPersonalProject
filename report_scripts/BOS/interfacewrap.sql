USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[BOSupdateOrderHeadersWrap]    Script Date: 1/27/2017 9:26:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Description			: Update ORDER_HEADERS table with detail from SAP
Author				: Minh D
Create Date			: 27 Jul 2016
Return				: None
Modified Date		: N/A
Modification		: N/A
*/

ALTER procedure [dbo].[BOSupdateOrderHeadersWrap] 
	
	
as

begin	
declare @OrderNo varchar(30),
		@TempSAPOrderNo as int,@ItemNumber as int, @ConfirmedQuantity as numeric(13, 3),
		@UOM as varchar(3), @TotalPrice as numeric(15, 4),
		@startTime as datetime, @endTime as dateTime, @Status as int,
		@BOSOrderNo as	int,@TotalAmount as numeric(15,4),
		@NetAmount as numeric(15,4),@TotalQuantity as numeric(15,0),@DepositAmount as numeric(15,4),
		@REC_TIME_STAMP as datetime,@TaxAmount as numeric(15,4),@ConfirmedDate as datetime,
		@OrderStatusText as nvarchar(max),
		@DiscAmount as numeric(15, 4)

while ((select COUNT(*) from bosOrder_Header WHERE IsProcessed = 0 AND STATUS IN (3,5)) > 0)
	begin

		set @startTime = getdate()
		select top(1) @orderNo = order_no,
					@BOSOrderNo = BOSOrderNo,
					@TotalAmount = Extended_Amount,--Total_Amount,
					@Status = Status,
					@TotalQuantity = Total_Quantity,
					@DiscAmount = DISC_AMOUNT,
					@REC_TIME_STAMP = ChangeDateTime,
					@TaxAmount = Tax_Amount,
					@ConfirmedDate = Confirmed_Date,
					@OrderStatusText = OrderStatusText
		from bosOrder_Header
		WHERE IsProcessed = 0 AND STATUS IN (3,5)
		
		
		execute	 BOSupdateOrderHeaders @OrderNo, @Status,  @BOSOrderNo, @TotalAmount, @DiscAmount, @NetAmount, @TotalQuantity, @DepositAmount, @REC_TIME_STAMP, @TaxAmount, @ConfirmedDate, @OrderStatusText;
		
		
		--execute BOSupdateOrderLinesWrap @OrderNo
	
		IF @Status = 5 BEGIN

		with bosOrder_Lines as(
				SELECT * FROM bosOrder_Line WHERE ORDER_NO = @OrderNo AND IsProcessed = 0
			)
		merge ORDER_LINES as target
			using bosOrder_Lines as source
			on target.ORDER_NO = source.ORDER_NO AND target.PRODUCT_CODE = source.PRODUCT_CODE AND target.UOM_CODE = source.UOM 
			when matched then
				update set  target.Quantity_Confirmed = source.Quantity_Confirmed,
							target.LINE_AMOUNT        = source.LINE_AMOUNT+source.DISC_AMOUNT,
							target.LINE_DISC_AMOUNT   = source.LINE_AMOUNT+source.DISC_AMOUNT,
							target.UNIT_PRICE         = source.UNIT_PRICE,
							target.OrderLineStatus    = 2,
							target.Confirm_user_code  = 'BOS',
							target.rec_user_code	  = 'BOS Interface',
							target.REC_TIME_STAMP     = getdate()
			when not matched by target then
				INSERT (Order_NO,Product_ID,Uom_Code,Product_Code,Quantity_Ordered,Quantity_Shipped,Line_Amount
					  ,Line_Disc_Rate,Line_Disc_Amount,Sku_Disc_Rate,Sku_Disc_Amount,Domain_ID,REC_User_Code
					  ,REC_Time_Stamp,Line_Tax,Line_Tax_Amount,Unit_Price,FREE_PRODUCTS,promotion_id,Promotion_TypeID,own_pro_id
					  ,Quantity_Confirmed,OrderLineStatus)
					VALUES ( Order_NO,(SELECT ID FROM PRODUCTS WHERE Code = Product_Code),UOM,Product_Code,isnull(Quantity_Confirmed,0),isnull(Quantity_Confirmed,0),isnull(Line_Amount,0)
						  ,0,isnull(LINE_AMOUNT+DISC_AMOUNT,0),0,0,1,'BOS Interface'
						  ,getdate(),0,isnull(LINE_AMOUNT+DISC_AMOUNT,0),isnull(Unit_Price,0),2,NULL,NULL,(SELECT ID FROM PRODUCTS WHERE Code = Product_Code)
						  ,isnull(Quantity_Confirmed,0),2);


		UPDATE bosOrder_Line SET IsProcessed = 1 WHERE ORDER_NO = @OrderNo AND IsProcessed = 0-- AND PRODUCT_CODE =  @productCode AND UOM = @UOM--processed

		END

		UPDATE bosOrder_Header SET IsProcessed = 1 WHERE ORDER_NO = @OrderNo

	end	
	
end

