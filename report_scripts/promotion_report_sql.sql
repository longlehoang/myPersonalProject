WITH ol
AS (SELECT
  t.*,
  p.qtyDiscounted,
  p.qtyDiscounted_CS,
  p.qtyDiscounted_EA,
  p.qtyDiscounted_EC
FROM (SELECT
  oh.customer_id,
  oh.Confirmed_Date AS oh_comfirmed,
  oh.OrderType,
  oh.user_id,
  oh.chain_id,
  ol.*,
  CASE
    WHEN ISNULL(ol.Quantity_Confirmed, 0) = 0 THEN NULL
    ELSE ol.LINE_DISC_RATE
  END AS discountPerCase,
  ol.LINE_DISC_RATE * ol.Quantity_Confirmed AS totalDiscount,
  (CASE oh.OrderType
    WHEN 0 THEN ISNULL(ol.Quantity_Confirmed, 0)
    ELSE -ISNULL(ol.Quantity_Confirmed, 0)
  END) AS qtySold,
  (CASE oh.OrderType
    WHEN 0 THEN ISNULL(ol.Quantity_Confirmed_EC, 0)
    ELSE -ISNULL(ol.Quantity_Confirmed_EC, 0)
  END) AS qtySold_ec,
  (CASE ol.FREE_PRODUCTS
    WHEN 2 THEN 'Y'
    ELSE 'N'
  END) AS isFreeProduct
FROM order_headers oh WITH (INDEX = [IDX_Order_Header_Comfirmed_Date])
INNER JOIN ORDER_lines ol WITH (INDEX = [idx_orderNo])
  ON ol.ORDER_NO = oh.ORDER_NO
  AND ol.OrderLineStatus = 2
  AND (ISNULL(ol.FREE_PRODUCTS, 0) = 0
  OR ol.FREE_PRODUCTS = 2)
  AND ol.Promotion_id IS NOT NULL
WHERE oh.Confirmed_Date >= '12Sep16'
AND oh.Confirmed_Date < '24Sep16') t
LEFT JOIN (SELECT
  ol.order_no,
  ol.own_pro_id,
  SUM(Quantity_Confirmed) AS qtyDiscounted,
  CASE
    WHEN ol.[UOM_CODE] = 'CS' THEN SUM(Quantity_Confirmed)
    ELSE NULL
  END AS qtyDiscounted_CS,
  CASE
    WHEN ol.[UOM_CODE] = 'EA' THEN SUM(Quantity_Confirmed)
    ELSE NULL
  END AS qtyDiscounted_EA,
  SUM(Quantity_Confirmed_EC) AS qtyDiscounted_EC
FROM order_headers oh WITH (INDEX = [IDX_Order_Header_Comfirmed_Date])
INNER JOIN ORDER_lines ol WITH (INDEX = [idx_orderNo])
  ON ol.ORDER_NO = oh.ORDER_NO
WHERE oh.Confirmed_Date >= '12Sep16'
AND oh.Confirmed_Date < '24Sep16'
AND ol.FREE_PRODUCTS = 2
GROUP BY ol.order_no,
         own_pro_id,
         ol.[UOM_CODE]) p
  ON t.order_no = p.order_no
  AND t.product_id = ISNULL(p.own_pro_id, 1))
SELECT
  u.AreaCode,
  u.AreaManager,
  u.salesRep,
  u.salesRepCode,
  chains.DESCRIPTION AS distributor,
  chains.code AS distributor_code,
  c.name AS customer,
  c.code AS customer_code,
  brand.CodeDesc AS brand,
  pack.CodeDesc AS pack,
  p.DESCRIPTION AS product,
  p.code AS product_code,
  ol.ORDER_NO,
  ol.oh_comfirmed,
  ol.qtySold,
  ol.qtySold_ec,
  ol.isFreeProduct,
  ISNULL(ol.Line_Disc_Amount, ol.Line_Amount) AS salesValue,
  CASE
    WHEN ISNULL(ol.promotion_ID, '') <> '' THEN (SELECT DISTINCT
        STUFF((SELECT
          ',' + TypeID
        FROM (SELECT DISTINCT
          CASE CAST(TypeID AS varchar)
            WHEN '1' THEN 'Free cases'
            WHEN '2' THEN 'Value Discount'
            WHEN '3' THEN 'Percentage Discount'
            WHEN '4' THEN 'Free Case (By Pack)'
            WHEN '5' THEN 'Value Discount (By Pack)'
            WHEN '6' THEN 'Percentage Discount(By Pack)'
            ELSE ''
          END AS TypeID
        FROM [dbo].[FN_SPLIT](ol.promotion_ID, ',') t
        INNER JOIN order_promotion op
          ON op.id = t.a) subTitle
        FOR xml PATH ('')), 1, 1, '') AS TypeID
      FROM (SELECT DISTINCT
        CAST(op.TypeID AS varchar) AS TypeID
      FROM [dbo].[FN_SPLIT](ol.promotion_ID, ',') t
      INNER JOIN order_promotion op
        ON op.id = t.a) t)
    ELSE ''
  END AS Promotion_TypeID --,op.name as promotion_name 
  ,
  CASE
    WHEN ISNULL(ol.promotion_ID, '') <> '' THEN (SELECT DISTINCT
        STUFF((SELECT
          ',' + NAME
        FROM (SELECT DISTINCT
          NAME
        FROM [dbo].[FN_SPLIT](ol.promotion_ID, ',') t
        INNER JOIN order_promotion op
          ON op.id = t.a) subTitle
        FOR xml PATH ('')), 1, 1, '') AS NAME
      FROM (SELECT DISTINCT
        CAST(op.NAME AS varchar) AS NAME
      FROM [dbo].[FN_SPLIT](ol.promotion_ID, ',') t
      INNER JOIN order_promotion op
        ON op.id = t.a) t)
    ELSE ''
  END AS promotion_name,
  ol.qtyDiscounted,
  ol.discountPerCase,
  ol.totalDiscount,
  ol.promotion_ID AS promotionid,
  ol.qtyDiscounted_CS,
  ol.qtyDiscounted_EA,
  ol.qtyDiscounted_EC,
  channel.CodeValue channelcode,
  channel.CodeDesc channelname,
  ol.Confirmed_Date,
  CASE
    WHEN ol.Promotion_TypeID IN (3, 6) THEN CAST(ol.LINE_DISC_RATE AS nvarchar) + '%'
    ELSE CAST(ol.LINE_DISC_RATE AS nvarchar)
  END AS discount
FROM ol
INNER JOIN CUSTOMERS c WITH (NOLOCK)
  ON ol.CUSTOMER_ID = c.ID
INNER JOIN View_PositionOrg u WITH (NOLOCK)
  ON ol.USER_ID = u.salesRepID
INNER JOIN PRODUCTS p WITH (NOLOCK)
  ON ol.PRODUCT_ID = p.ID
LEFT JOIN ORDER_PROMOTION op WITH (NOLOCK)
  ON ol.promotion_id = op.id
LEFT JOIN CHAINS WITH (NOLOCK)
  ON ol.CHAIN_ID = chains.ID
LEFT JOIN sfaCodeDesc brand WITH (NOLOCK)
  ON p.BRAND_CODE = brand.CodeValue
  AND brand.CodeCategory = 'ProductBrand'
  AND brand.CountryId = '8'
  AND brand.SalesOrg = '54'
LEFT JOIN sfaCodeDesc pack WITH (NOLOCK)
  ON p.ProductGroupId = pack.CodeValue
  AND pack.CodeCategory = 'ProductGroup'
  AND pack.CountryId = '8'
  AND pack.SalesOrg = '54'
LEFT JOIN sfaCodeDesc channel WITH (NOLOCK)
  ON c.TradeChannel = channel.CodeValue
  AND channel.CodeCategory = 'TradeChannel'
  AND channel.CountryId = '8'
  AND channel.SalesOrg = '54'
WHERE 1 = 1
AND u.countryID = 8
AND u.companyID = 35
AND u.salesOrgID = 54