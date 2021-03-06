USE [CCVN4]
GO
/****** Object:  StoredProcedure [dbo].[usp_SelectCUSTOMERSsDynamicForExcel]    Script Date: 2/15/2016 2:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Procedure
--***********************************************************************
-- Author:		<Jake.hua>
-- Create date: <Create Date>
-- Description:	<Description>
-- Modified History
--***********************************************************************
-- Modify: washing
-- Modify date: 09/02/01
-- Description: 因为选择数据时报转换错误,经过排查是
--              (SELECT Name FROM DICTIONARYITEMS WHERE DICTIONARYITEMID = 
--              cast(C.LOCAL_LEVEL1_CODE as int)) AS Channel
--              代码报错,转换以后就不报了,所以进行此修改
--***********************************************************************
ALTER PROCEDURE [dbo].[usp_SelectCUSTOMERSsDynamicForExcel]
	@WhereCondition nvarchar(max),
	@VALID VARCHAR(2) 
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

DECLARE @SQL nvarchar(max)
SET @SQL = ' SELECT distinct
	C.ID,
	C.CODE,
	C.NAME,
	CHAINS.CODE AS CHAIN_CODE,
	ORG.CODE AS ORG_CODE,
	TradeChannel.CodeValue as CHANNEL_CODE,
	CustomerType.CodeValue as CUSTOMER_TYPE_CODE,
	U.code AS Sales_Rep,
	CI.ADDRESS_LINE,
	CI.ContactFirstName,
	CI.ContactLastName,
	CI.ContactTel,
	CI.ContactMobile,
	C.VALID,
	C.STATUS,
	C.DeliveryType,
	C.GEO_LEVEL_CODE,
	''U'' AS Flag,
	C.Cooler_Customer
FROM CUSTOMERS AS C 
	INNER JOIN ORGANIZATION ORG ON C.ORG_ID=ORG.ID
	LEFT JOIN CONTACT_INFO CI ON C.ID=CI.CUSTOMER_ID
	LEFT JOIN sfaCodeDesc TradeChannel ON C.TradeChannel=TradeChannel.CodeValue 
		AND TradeChannel.CodeCategory= ''TradeChannel''
		AND TradeChannel.CountryId = case when TradeChannel.CountryId=''*'' then TradeChannel.CountryId else cast(dbo.FN_GETParentID(C.org_id,1) as nvarchar) end
		AND TradeChannel.SalesOrg = case when TradeChannel.SalesOrg=''*'' then TradeChannel.SalesOrg else cast(dbo.FN_GETParentID(C.org_id,3) as nvarchar) end
	LEFT JOIN sfaCodeDesc CustomerType ON C.customer_type=CustomerType.CodeValue 
		AND CustomerType.CodeCategory= ''Customer_Type''
		AND CustomerType.CountryId = case when CustomerType.CountryId=''*'' then CustomerType.CountryId else cast(dbo.FN_GETParentID(C.org_id,1) as nvarchar) end
		AND CustomerType.SalesOrg = case when CustomerType.SalesOrg=''*'' then CustomerType.SalesOrg else cast(dbo.FN_GETParentID(C.org_id,3) as nvarchar) end
	LEFT JOIN CUSTOMER_CHAINS ON CUSTOMER_CHAINS.CUSTOMER_ID=C.ID
	LEFT JOIN CHAINS ON CHAINS_ID=CHAINS.ID
	LEFT JOIN ROUTE_CUSTOMERS RC ON RC.CUSTOMER_ID=C.ID
		AND RC.ROUTE_NUMBER=0
	LEFT JOIN USERS U ON U.ID=RC.USER_ID
WHERE 1=1  and C.VALID=1
	' + @WhereCondition

--IF @VALID <> ''
--SET @SQL = @SQL + ' AND C.VALID = '''+@VALID+''' '

SET @SQL = @SQL + ' ORDER BY C.CODE  '

print (@sql)

EXEC sp_executesql @SQL
