BEGIN
	--导入配置表数据CodeDesc
	declare @l_CodeCategory nvarchar(20)
		   ,@l_CodeValue nvarchar(50)
		   ,@l_CodeDesc nvarchar(50)
 ,@l_DeleteFlag bit
 declare @l_SalesOrg	nchar(4)
 	declare @l_CountryId nchar(2)
	declare c_codedesc cursor for
	select CountryId,SalesOrg,CodeCategory,CodeValue,CodeDesc,DeleteFlag
	from sapCodedesc s
	where CountryId = 'MM'
	and SalesOrg = 'MM09'
	for read only
	

	open c_codedesc
	fetch c_codedesc into @l_CountryId,@l_SalesOrg,@l_CodeCategory,@l_CodeValue,@l_CodeDesc,@l_DeleteFlag

	while(@@fetch_status = 0)
	begin

		exec [dbo].[insertOrUpdateCodeDesc_SFA] @l_CountryId,@l_SalesOrg,@l_CodeCategory,@l_CodeValue,@l_CodeDesc,@l_DeleteFlag

		fetch c_codedesc into @l_CountryId,@l_SalesOrg,@l_CodeCategory,@l_CodeValue,@l_CodeDesc,@l_DeleteFlag
	end

	close c_codedesc
	deallocate c_codedesc
END