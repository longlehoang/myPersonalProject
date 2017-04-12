BEGIN
declare @l_Sequence int
		   ,@l_MobileSaleFlag bit
		    ,@l_DeleteFlag bit
		   declare @l_SalesOrg	nchar(4)
declare @l_ProductId nvarchar(10)
declare c_salesorgproduct cursor for
	select SalesOrg,ProductId,Sequence,MobileSaleFlag,deleteflag
	from sapSalesOrgProduct
	where SalesOrg = 'MM09'
	for read only

	open c_salesorgproduct 
	fetch c_salesorgproduct into @l_SalesOrg,@l_ProductId,@l_Sequence,@l_MobileSaleFlag,@l_DeleteFlag
	while(@@fetch_status = 0)
	begin

		exec [dbo].[insertOrUpdateSalesOrgProduct_SFA] @SalesOrg       = @l_SalesOrg
													  ,@ProductId	   = @l_ProductId
													  ,@Sequence	   = @l_Sequence
													  ,@MobileSaleFlag = @l_MobileSaleFlag
													  ,@DeleteFlag	   = @l_DeleteFlag

		fetch c_salesorgproduct into @l_SalesOrg,@l_ProductId,@l_Sequence,@l_MobileSaleFlag,@l_DeleteFlag
	end
	close c_salesorgproduct
	deallocate c_salesorgproduct

	END