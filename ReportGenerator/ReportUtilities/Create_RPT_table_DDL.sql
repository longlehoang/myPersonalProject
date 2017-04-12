USE [CCVN4_Reporting]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_REDSurvey] (
	[CreatedDate]				[varchar](30)		DEFAULT 'NULL',
	[country]					[nvarchar](50)		DEFAULT 'NULL',
	[countryID]					[int]				DEFAULT 'NULL',
	[company]					[nvarchar](50)		DEFAULT 'NULL',
	[companyID]					[int]				DEFAULT 'NULL',
	[salesOrg]					[nvarchar](50)		DEFAULT 'NULL',
	[salesOrgID]				[int]				DEFAULT 'NULL',
	[RegionManager]				[nvarchar](200)		DEFAULT 'NULL',
	[SalesManager]				[nvarchar](200)		DEFAULT 'NULL',
	[salesOffice]				[nvarchar](50)		DEFAULT 'NULL',
	[salesOfficeID]				[int]				DEFAULT 'NULL',
	[AreaCode]					[nvarchar](50)		DEFAULT 'NULL',
	[AreaManager]				[nvarchar](200)		DEFAULT 'NULL',
	[TerritorySalesManager]		[nvarchar](200)		DEFAULT 'NULL',
	[salesRep]					[nvarchar](200)		DEFAULT 'NULL',
	[salesRepCode]				[nvarchar](50)		DEFAULT 'NULL',
	[salesRepID]				[varchar](20)		DEFAULT 'NULL',
	[CreatorName]				[nvarchar](200)		DEFAULT 'NULL',
	[CreatorCode]				[varchar](20)		DEFAULT 'NULL',
	[CreatorRole]				[varchar](10)		DEFAULT 'NULL',
	[CustomerName]				[nvarchar](4000)		DEFAULT 'NULL',
	[CustomerCode]				[varchar](100)		DEFAULT 'NULL',
	[ProfileName]				[nvarchar](50)		DEFAULT 'NULL',
	[GroupName]					[nvarchar](50)		DEFAULT 'NULL',
	[ItemName]					[nvarchar](4000)	DEFAULT 'NULL',
	[ItemContent]				[nvarchar](4000)	DEFAULT 'NULL',
	[ItemValue]					[nvarchar](4000)	DEFAULT 'NULL',
	[ItemScore]					[varchar](30)		DEFAULT 'NULL',
	[TotalScore]				[varchar](50)		DEFAULT 'NULL',
	[PictureLink]				[varchar](200)		DEFAULT 'NULL',
	[PictureMetadataLink]		[varchar](200)		DEFAULT 'NULL',
	[PhotoRemark]				[varchar](8000)		DEFAULT 'NULL',
	[salesRepEmail]				[nvarchar](200)		DEFAULT 'NULL',
	[TSMCode]					[nvarchar](50)		DEFAULT 'NULL',
	[TSMEmail]					[nvarchar](200)		DEFAULT 'NULL',
	[ASMEmail]					[nvarchar](200)		DEFAULT 'NULL',
	[Distributor]				[nvarchar](200)		DEFAULT 'NULL',
	[DistributorCode]			[nvarchar](50)		DEFAULT 'NULL',
	[CustomerAddress]			[nvarchar](4000)	DEFAULT 'NULL',
	[IsREDNew]					[varchar](10)		DEFAULT 'NULL',
)

GO

SELECT GETDATE() RPT_DATE, a.*
INTO [CCVN4_Reporting].[dbo].[RPT_VN_REDSurvey_HIST]
FROM [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_REDSurvey] a
WHERE 0=1;

GO

CREATE TABLE [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_RouteCompliance_Export] (
	[UserCode]					[nvarchar](50)		DEFAULT 'NULL',
	[UserName]					[nvarchar](200)		DEFAULT 'NULL',
	[Date]						[date]				DEFAULT 'NULL',
	[PlannedCall]				[int]				DEFAULT 'NULL',
	[TotalCall]					[int]				DEFAULT 'NULL',
	[CallRate]					[numeric](10, 4)	DEFAULT 'NULL',
	[ComplianceCall]			[numeric](10, 4)	DEFAULT 'NULL',
	[ComplianceRate]			[numeric](10, 4)	DEFAULT 'NULL',
	[OnRouteCall]				[int]				DEFAULT 'NULL',
	[OffRouteCall]				[int]				DEFAULT 'NULL',
	[AvgVisitTimeOutlet]		[int]				DEFAULT 'NULL',
	[AvgVisitTimeDay]			[int]				DEFAULT 'NULL',
)

GO

SELECT GETDATE() RPT_DATE, a.*
INTO [CCVN4_Reporting].[dbo].[RPT_VN_RouteCompliance_Export_HIST]
FROM [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_RouteCompliance_Export] a
WHERE 0=1;

GO

CREATE TABLE [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_CoolerVerification](
	[SalesOrg]				[nvarchar](50)		NULL,
	[RegionManager]			[nvarchar](200)		NULL,
	[SalesManager]			[nvarchar](200)		NULL,
	[AreaManager]			[nvarchar](200)		NULL,
	[AreaCode]				[nvarchar](50)		NULL,
	[TSM]					[nvarchar](200)		NULL,
	[TSMCode]				[nvarchar](50)		NULL,
	[salesRep]				[nvarchar](200)		NULL,
	[salesRepCode]			[nvarchar](50)		NULL,
	[Distributor]			[nvarchar](200)		NULL,
	[DistributorCode]		[nvarchar](50)		NULL,
	[Customer]				[nvarchar](200)		NULL,
	[CustomerCode]			[varchar](100)		NULL,
	[CustomerAddress]		[nvarchar](1000)	NULL,
	[VerificationID]		[nvarchar](50)		NULL,
	[Real_AssetNo]			[nvarchar](50)		NULL,
	[VerifyTime]			[datetime]			NULL,
	[VerifyStatus]			[int]				NULL,
	[Reason_Code]			[nvarchar](50)		NULL,
	[Note]					[nvarchar](2000)	NULL,
	[SAP_AssetNo]			[nvarchar](100)		NULL,
	[SAP_Model]				[nvarchar](50)		NULL,
	[SAP_SerialNumber]		[nvarchar](50)		NULL,
	[PictureLink]			[varchar](200)		NULL,
	[customerLong]			[float]				NULL,
	[customerLat]			[float]				NULL,
	[long]					[float]				NULL,
	[lat]					[float]				NULL
)
GO

SELECT GETDATE() RPT_DATE, a.*
INTO [CCVN4_Reporting].[dbo].[RPT_VN_CoolerVerification_HIST]
FROM [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_CoolerVerification] a
WHERE 0=1;

GO

CREATE TABLE [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_CoolerVerification_NoPicture](
	[SalesOrg]			[nvarchar](50)		NULL,
	[RegionManager]		[nvarchar](200)		NULL,
	[SalesManager]		[nvarchar](200)		NULL,
	[AreaManager]		[nvarchar](200)		NULL,
	[AreaCode]			[nvarchar](50)		NULL,
	[TSM]				[nvarchar](200)		NULL,
	[TSMCode]			[nvarchar](50)		NULL,
	[salesRep]			[nvarchar](100)		NULL,
	[salesRepCode]		[nvarchar](50)		NULL,
	[Distributor]		[nvarchar](200)		NULL,
	[DistributorCode]	[nvarchar](50)		NULL,
	[Customer]			[nvarchar](4000)	NULL,
	[CustomerCode]		[varchar](100)		NULL,
	[CustomerAddress]	[nvarchar](4000)	NULL,
	[VerificationID]	[nvarchar](50)		NULL,
	[Real_AssetNo]		[nvarchar](50)		NULL,
	[VerifyTime]		[datetime]			NULL,
	[VerifyStatus]		[int]				NULL,
	[Reason_Code]		[nvarchar](50)		NULL,
	[Note]				[nvarchar](4000)	NULL,
	[SAP_AssetNo]		[nvarchar](100)		NULL,
	[SAP_Model]			[nvarchar](50)		NULL,
	[SAP_SerialNumber]	[nvarchar](50)		NULL,
	[customerLong]		[float]				NULL,
	[customerLat]		[float]				NULL,
	[long]				[float]				NULL,
	[lat]				[float]				NULL
)

GO

SELECT GETDATE() RPT_DATE, a.*
INTO [CCVN4_Reporting].[dbo].[RPT_VN_CoolerVerification_NoPicture_HIST]
FROM [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_CoolerVerification_NoPicture] a
WHERE 0=1;

GO

CREATE TABLE [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_CoolerWFReport](
	[RequestedDate]				[varchar](30)		NULL,
	[country]					[nvarchar](50)		NULL,
	[company]					[nvarchar](50)		NULL,
	[salesOrg]					[nvarchar](50)		NULL,
	[RegionManager]				[nvarchar](100)		NULL,
	[SalesManager]				[nvarchar](100)		NULL,
	[SalesOffice]				[nvarchar](50)		NULL,
	[AreaManager]				[nvarchar](100)		NULL,
	[TerritorySalesManager]		[nvarchar](100)		NULL,
	[RequestStartTime]			[varchar](30)		NULL,
	[CustomerCode]				[varchar](100)		NULL,
	[CustomerName]				[nvarchar](4000)	NULL,
	[CustomerAddress]			[nvarchar](4000)	NULL,
	[RepCode]					[nvarchar](50)		NULL,
	[SalesRep]					[nvarchar](100)		NULL,
	[SRRequest]					[varchar](30)		NULL,
	[TSM]						[nvarchar](50)		NULL,
	[TSMApprove]				[varchar](30)		NULL,
	[ASM]						[nvarchar](50)		NULL,
	[ASMApprove]				[varchar](30)		NULL,
	[CDE]						[nvarchar](50)		NULL,
	[CDEApprove]				[varchar](30)		NULL,
	[InstalledDate]				[varchar](1)		NOT NULL,
	[ApprovalDays]				[int]				NULL,
	[SR2InstalledDays]			[varchar](1)		NOT NULL,
	[CDE2InstalledDays]			[varchar](1)		NOT NULL,
	[Remarks]					[varchar](31)		NOT NULL,
	[Comment]					[nvarchar](4000)	NULL,
	[WFID]						[nvarchar](50)		NOT NULL
)

GO

SELECT GETDATE() RPT_DATE, a.*
INTO [CCVN4_Reporting].[dbo].[RPT_VN_CoolerWFReport_HIST]
FROM [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_CoolerWFReport] a
WHERE 0=1;

GO

CREATE TABLE [dbo].[DAILY_RPT_VN_REDCustomerCodeMTD](
	[SurveyDate]		[datetime]			NOT NULL,
	[CreatorCode]		[varchar](50)		NOT NULL,
	[CustomerName]		[nvarchar](4000)	NULL,
	[CustomerCode]		[varchar](100)		NOT NULL
) ON [PRIMARY]

GO

SELECT GETDATE() RPT_DATE, a.*
INTO [CCVN4_Reporting].[dbo].[RPT_VN_REDCustomerCodeMTD_HIST]
FROM [CCVN4_Reporting].[dbo].[DAILY_RPT_VN_REDCustomerCodeMTD] a
WHERE 0=1;

GO

SET ANSI_PADDING OFF
GO
