SELECT --CONVERT(date, res.confirmed_date) ConfirmedDate ,
  res.Plant,
  res.SalesOrg,
  res.SalesOrgName,
  res.AreaCode,
  res.AreaManager,
  res.mdc_name Distributor,
  res.mdc_code DistributorCode,
  res.customer_name Customer,
  res.customer_code CustomerCode,
  COUNT(DISTINCT res.OrderNumber) as TotalOrder,
  res.product_code,
  SUM(res.qty_ec) as TotalVolumeEC
FROM 
  (
SELECT    
  o1.OrgCode as Plant,
  o2.OrgCode as SalesOrg,
  o2.OrgName as SalesOrgName,
  po.AreaCode,
  po.AreaManager,
  isnull(cc.CHAINS_NAME,'x') as mdc_name,
  isnull(cc.CHAINS_CODE,'x') as mdc_code,
  p.code as product_code,
  p.DESCRIPTION as product_desc,
  c.name as customer_name,
  c.code as customer_code,
  oh.order_no AS OrderNumber,
  oh.Confirmed_Date AS confirmed_date,
  MAX(oh.ORDER_date) AS order_date,
  (CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed),0) ELSE isnull(SUM(-ol.Quantity_Confirmed),0) END) as qty,
  (CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed_ec),0) ELSE isnull(SUM(-ol.Quantity_Confirmed_ec),0) END) as qty_ec,
  isnull(SUM(ol.LINE_AMOUNT),0) as list_price,
  (CASE ol.Promotion_TypeID WHEN 3 THEN cast(ol.LINE_DISC_RATE as nvarchar)+'%' ELSE cast(ol.LINE_DISC_RATE as nvarchar) end) as discount,
  sum(ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount)) as discount_value,
  SUM(isnull(ol.Line_Disc_Amount,ol.Line_Amount)) as net_price,
  c.Cooler_Customer as coolerCustomer,
  (CASE oh.ordertype WHEN 0 THEN 'orders' ELSE 'trade returns' end ) as ordertype,
  oh.USER_ID as SalesRepID,
  u.Code as SalesRepCode
FROM 
  order_headers (nolock) oh
    inner join order_lines ol on ol.order_no=oh.order_no 
    inner join Organization o1 on oh.org_id=o1.OrgID 
    inner join Organization o2 on o1.ParentID=o2.OrgID 
    inner join PRODUCTS p on ol.PRODUCT_ID=p.ID 
    inner join customers c on oh.customer_id=c.id 
    inner join Users u on oh.USER_ID=u.USER_ID 
    inner join CUSTOMER_CHAINS cc on oh.customer_id=cc.customer_id
LEFT JOIN View_PositionOrg po ON u.user_id = po.salesRepID
WHERE 
  isnull(ol.FREE_PRODUCTS,0)<>1 and (oh.STATUS = 6 or ol.OrderLineStatus=2)    
  and oh.Confirmed_Date BETWEEN '01Jul16' and '01Aug16'
  and o2.OrgCode LIKE ('VN11')
GROUP BY
  o1.OrgCode,o2.OrgCode,o2.OrgName,po.AreaCode, po.AreaManager,cc.CHAINS_NAME,cc.CHAINS_CODE,p.code,p.DESCRIPTION,c.name,c.code,oh.order_no,oh.Confirmed_Date,
  oh.OrderType,ol.LINE_AMOUNT,ol.Promotion_TypeID,ol.LINE_DISC_RATE,
  ol.LINE_DISC_AMOUNT,c.Cooler_Customer,oh.USER_ID,u.Code) res
GROUP BY  res.Plant,
  res.SalesOrg,
  res.SalesOrgName,
  res.AreaCode,
  res.AreaManager,
  res.mdc_name,
  res.mdc_code,
  res.customer_name,
  res.product_code,
  res.customer_code
-- res.confirmed_date 
  ORDER BY  res.Plant,
  res.SalesOrg,
  res.SalesOrgName,
  res.AreaCode,
  res.AreaManager
-- res.confirmed_date