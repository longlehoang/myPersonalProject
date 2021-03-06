USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[BOSupdateOrderHeaders]    Script Date: 1/27/2017 9:25:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Description			: Update ORDER_HEADERS table with detail from BOS
Author				: Minh D
Create Date			: 26 Jul 2016
Return				: None
Modified Date		: N/A
Modification		: N/A
*/

ALTER procedure [dbo].[BOSupdateOrderHeaders] 
	@OrderNo			varchar(30),
	@Status				int,
	@BOSOrderNo			int,
	@TotalAmount		numeric(15,4),
	@DiscAmount			numeric(15,4),
	@NetAmount			numeric(15,4),
	@TotalQuantity		numeric(15,0),
	@DepositAmount		numeric(15,4),
	@REC_TIME_STAMP		datetime,
	@TaxAmount			numeric(15,4),
	@ConfirmedDate		datetime,
	@OrderStatusText	nvarchar(max)
	
as

begin	

	set nocount on

	IF @Status = 3 BEGIN
	
	update	ORDER_HEADERS
	set		--SAPOrderNo		= @BOSOrderNo,
			STATUS				= 3,
			REC_USER_CODE		= 'BOS Interface',
			OrderStatusText		= @OrderStatusText,
			REC_TIME_STAMP		= getdate()
	where	ORDER_NO = @OrderNo;
	END
	ELSE IF @Status = 5 BEGIN

	update	ORDER_HEADERS
	set		--SAPOrderNo		= @BOSOrderNo,
			STATUS				= 6,
			REC_USER_CODE		= 'BOS Interface',
			Confirmed_Date		= @ConfirmedDate,
			Confirm_user_code	= 'BOS',
			TOTAL_QUANTITY		= @TotalQuantity,
			TOTAL_AMOUNT		= @TotalAmount,
			--TAX_AMOUNT			= @TaxAmount,
			EXTENDED_AMOUNT		= @TotalAmount,
			DISC_AMOUNT			= @TotalAmount + @DiscAmount,
			OrderStatusText		= @OrderStatusText,
			REC_TIME_STAMP		= getdate()
	where	ORDER_NO = @OrderNo
	--AND STATUS = 1

	END
end
