USE [PRD_CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[SP_Calc_Order]    Script Date: 7/26/2016 1:57:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Calc_Order](@Order_NO varchar(30),@Org_ID int,@Chain_id int)
AS

BEGIN
	SET NOCOUNT ON
	--------------------------------------call unit price--------------------------------------
	print 'unit price'
	exec USP_Calc_Order_Price @Order_NO,0

	--------------------------------------call standard promotion------------------------------
	print 'standrad promotion'
	exec SP_Calc_Promo_Standard @Order_NO,@Org_ID,@Chain_id

	--------------------------------------call MatrixValue promotion---------------------------
	--get country
	declare @country_code as nvarchar(50)
	select @country_code=dbo.FN_GETParentCode(@Org_ID,1)

	if @country_code='VN'
	begin
		print 'vietnam promotion'
		exec SP_Calc_Promo_Vietnam @Order_NO,@Org_ID,@Chain_id
	end
	else
	begin
		print 'myanmar promotion'
		exec SP_Calc_Promo_Myanmar @Order_NO,@Org_ID,@Chain_id
	end

	print 'auto confirm'
	exec SP_AutoConfirm @Order_NO

	--------------------------------------call Tax---------------------------------------------
	print 'calc tax'
	exec USP_Calc_Order_Tax @Order_NO,0
		
	-------------------------------------------------------------------------------------------
	print 'completed'
	
END