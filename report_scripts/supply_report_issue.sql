SELECT	
		OH.ORDER_NO AS ORDER_NO,					--¶©µ¥ºÅ
		PERSONS.NAME AS SALES_REP,					--Òµ´ú
		U.Code as SalesRepCode,
		PERSONS.TELEPHONE as SALES_REP_TEL,
		(CASE OH.OrderType WHEN 0 THEN 'Orders'
			WHEN 1 THEN 'Trade Returns'
		ELSE 'N/A' END) AS ORDER_TYPE,			--¶©µ¥ÀàÐÍ
		OH.ORDER_DATE,								--¶©µ¥ÈÕÆÚ
		OH.REQ_DELIVERY_DATE,						--Òª»õÈÕÆÚ
		OH.TOTAL_AMOUNT,
		OH.DISC_AMOUNT,								--ÕÛºó×Ü¼Û
		OH.TAX_AMOUNT,								--Ë°µÄ¼Û¸ñ
		OH.DISC_AMOUNT+OH.TAX_AMOUNT
			 AS TOTAL_AFTER_TAX,					--º¬Ë°×Ü¼Û

		OH.Additional_info as DriverMessage	,		
		OH.ORG_ID,									--×éÖ¯¼Ü¹¹±àºÅ
		OG.NAME AS ORG_NAME,						--×éÖ¯¼Ü¹¹Ãû³Æ
		CH.DESCRIPTION AS CHAIN_NAME,				--¾­ÏúÉÌÃû³Æ
		CH.CODE as CHAIN_CODE,						--¾­ÏúÉÌ±àºÅ
		CHAIN_ADDRESS.ADDRESS_LINE AS CHAIN_ADDRESS,--¾­ÏúÉÌµØÖ·
		CHAIN_ADDRESS.ContactTel AS CHAIN_TEL,		--¾­ÏúÉÌµç»°
		CH.VATNumber AS VAT_NO,						--Ë°±àºÅ
		C.CODE AS CUSTOMER_CODE,					--¿Í»§±àºÅ
		C.NAME AS CUSTOMER_NAME,					--¿Í»§Ãû³Æ
		C.GEO_LEVEL_CODE AS GEO_CODE,				
	    CI.ADDRESS_LINE,							--¿Í»§µØÖ·
		CI.ContactTel AS TEL,						--ÁªÏµµç»°
		P.CODE AS PROEUCT_CODE ,						--²úÆ·±àºÅ
		P.DESCRIPTION as PROEUCT_NAME,				--²úÆ·Ãû³Æ
		SEQ.CodeDesc as ProductGroupId,				--²úÆ·×é
		pu.DENOMINATOR,
		OL.UOM_CODE AS UOMCODE ,					--µ¥Î»
		OL.UNIT_PRICE,								--µ¥¼Û
		CASE OL.UOM_CODE WHEN 'CS' THEN Quantity_Confirmed ELSE 0 END AS CSQTY,
		CASE OL.UOM_CODE WHEN 'EA' THEN Quantity_Confirmed ELSE 0 END AS EAQTY,
		OL.Promotion_Detail,
		CASE WHEN OL.promotion_id IS NOT NULL THEN '1' ELSE '0' END AS Promotion,
		Quantity_Confirmed	AS QTY,					--È·ÈÏÊýÁ¿
		OL.LINE_AMOUNT,								--×Ü¼Û
		OL.LINE_AMOUNT*(LINE_DISC_RATE*1.0/100)
			AS DISC,								--ÕÛ¿Û
		--OL.LINE_DISC_AMOUNT,						--ÕÛºó¼Û
		ISNULL(OL.LINE_DISC_AMOUNT,OL.LINE_AMOUNT) AS LINE_DISC_AMOUNT,
		OL.LINE_DISC_AMOUNT*(LINE_TAX*1.0/100)
			AS VAT,									--Ë°
		OL.LINE_TAX_AMOUNT,							--Ë°ºó¼Û	
		ISNULL(CH.MDCCode,'') MDCCode,
		ISNULL(CH.ReferenceNo,0) ReferenceNo
		,ISNULL(oh.DISC_1,0) AS CompanyDiscount
		,(SELECT SUM(ISNULL(DISCOUNT_VALUE,0)) AS DiscountValue FROM ORDER_LINES_PROMO WHERE ORDER_NO=OH.ORDER_NO) AS SpecialDiscount
		,(SELECT ISNULL(VOLUME_EC,0)*ISNULL(VOLUME_DISCOUNT,0) AS VolumeDiscount FROM dbo.Order_Promotion_MatrixValue WHERE ORDER_NO=OH.ORDER_NO) AS VolumeDiscount
		,(SELECT ISNULL(VOLUME_EC,0)*ISNULL(SKU_DISCOUNT,0) AS SkuDiscount FROM dbo.Order_Promotion_MatrixValue WHERE ORDER_NO=OH.ORDER_NO) AS RangeDiscount
FROM ORDER_HEADERS OH
INNER JOIN ORDER_LINES OL ON OH.ORDER_NO = OL.ORDER_NO
LEFT JOIN dbo.PRODUCT_UOMS pu ON pu.PRODUCT_ID=OL.PRODUCT_ID
INNER JOIN CUSTOMERS C ON OH.CUSTOMER_ID = C.ID
INNER JOIN ORGANIZATION OG ON OG.ID = OH.ORG_ID
INNER JOIN PRODUCTS AS P ON P.ID = OL.PRODUCT_ID
INNER JOIN CHAINS CH ON OH.CHAIN_ID=CH.ID
INNER JOIN CUSTOMERS C2 ON CH.CODE=C2.CODE
INNER JOIN USERS U ON OH.USER_ID=U.ID
INNER JOIN PERSONS ON U.PERSON_ID=PERSONS.ID
LEFT JOIN CONTACT_INFO CHAIN_ADDRESS ON CHAIN_ADDRESS.CUSTOMER_ID=C2.ID
LEFT JOIN MDC_PROD_LIST_ITEMS AS MPLI ON OL.PRODUCT_ID=MPLI.PRODUCT_ID
	AND MPLI.MDC_PRODUCT_LIST_ID=OH.CHAIN_ID
LEFT JOIN CONTACT_INFO AS CI ON CI.CUSTOMER_ID = C.ID
LEFT JOIN sfaCodeDesc SEQ ON P.ProductGroupId=SEQ.CodeValue
	and SEQ.CodeCategory='ProductGroupSequence'
	and SEQ.CountryId = case when SEQ.CountryId='*' then SEQ.CountryId else cast(dbo.FN_GETParentID(OH.org_id,1) as nvarchar) end
	and SEQ.SalesOrg = case when SEQ.SalesOrg='*' then SEQ.SalesOrg else cast(dbo.FN_GETParentID(OH.org_id,3) as nvarchar) end
WHERE OH.STATUS='6' AND OL.OrderLineStatus='2' AND isnull(OL.FREE_PRODUCTS,0)<>1
 AND OH.DOMAIN_ID = 1 AND OH.ORDER_DATE>='2016-04-02' and OH.ORDER_DATE<'2016-04-03' 
ORDER BY OH.ORDER_NO,SEQ.CodeDesc,OL.UOM_CODE,MPLI.SEQUENCE
