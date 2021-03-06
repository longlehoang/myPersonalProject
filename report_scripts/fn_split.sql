USE [CCVN4_Reporting]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_SPLIT]    Script Date: 8/1/2016 10:16:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[FN_SPLIT]
(
	@inputstr   VARCHAR(MAX),     
	@seprator   VARCHAR(10)   
)

RETURNS @temp TABLE (a VARCHAR(MAX))   
AS
BEGIN
	DECLARE @x XML
    SET @x = CONVERT(XML,'<items><item id="' + REPLACE(@inputstr, @seprator, '"/><item id="') + '"/></items>')
    INSERT INTO @temp SELECT x.item.value('@id[1]', 'INT') FROM @x.nodes('//items/item') AS x(item)
    RETURN 
END