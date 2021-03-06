USE [PRD_CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[SP_Calc_Confirm_Order]    Script Date: 7/26/2016 1:50:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Calc_Confirm_Order](@Order_NO nvarchar(30),@Org_ID int,@Chain_id int)
AS

BEGIN
	SET NOCOUNT ON
	--------------------------------------call unit price--------------------------------------
	print '01.unit price'

	exec USP_Calc_Order_Price @Order_NO,1

	--------------------------------------call standard promotion------------------------------
	print '02.standrad promotion'

	exec SP_Calc_Confirm_Promo_Standard @Order_NO,@Org_ID,@Chain_id

	--------------------------------------call MatrixValue promotion---------------------------
	--get country
	declare @country_code as nvarchar(50)
	select @country_code=dbo.FN_GETParentCode(@Org_ID,1)

	if @country_code='VN'
	begin
		print '03.vietnam promotion'
		exec SP_Calc_Confirm_Promo_Vietnam @Order_NO,@Org_ID,@Chain_id	
	end
	else
	begin
		print '04.myanmar promotion'
		exec SP_Calc_Confirm_Promo_Myanmar @Order_NO,@Org_ID,@Chain_id
	end

	--------------------------------------call Tax---------------------------------------------
	print '05.tax'
	exec USP_Calc_Order_Tax @Order_NO,1
	
	-------------------------------------update inventory---------------------------------------
	print '06.update inventory'
	exec SP_Calc_Confirm_Inventory @Order_NO

	print 'completed'
	
END
