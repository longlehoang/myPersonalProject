USE CCVN4_Reporting
GO
Declare @Date_From datetime,@Date_To datetime,
		@Country nvarchar(100),@Company nvarchar(100),@SalesOrg nvarchar(100)
set @Date_From='25Feb16'
set @Date_To='04Mar16'
set @SalesOrg='North East Region'

select @Country=Region.OrgID,@Company=DUG.OrgID,@SalesOrg=DU.OrgID 
from Organization Region with(nolock)
inner join Organization DUG with(nolock) on Region.OrgID=DUG.ParentID
inner join Organization DU with(nolock) on DUG.OrgID=DU.ParentID
inner join Organization City with(nolock) on DU.OrgID=City.ParentID
WHERE City.OrgLevel=4 and DU.OrgName=@SalesOrg;

exec dbo.Report_Promotion @Date_From=@Date_From,@Date_To=@Date_To,@PromotionType=NULL,@Country=@Country,@Company=@Company,@SalesOrg=@SalesOrg,@Salesoffice=NULL,@MDC=NULL,@SalesRep=NULL