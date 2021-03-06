USE [CCVN4_Reporting]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GETParentID]    Script Date: 8/1/2016 10:17:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[FN_GETParentID](@org_id int,@level int)
returns int
as
begin
		declare @parentorg int;

			with ColumnCTE ( id,name,parentID,level)
			as
			(
				select OrgID,OrgName,ParentID,OrgLevel as level from ORGANIZATION where 
				 OrgID=@org_id 
				union all 
				select tt.OrgID,tt.OrgName,tt.ParentID,OrgLevel 
				from ORGANIZATION tt join ColumnCTE cte on tt.OrgID = cte.ParentID
					
			) 
			
			select  @parentorg=id   from ColumnCTE where level=@level
 

       return  @parentorg

end

