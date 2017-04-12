SELECT  res.order_date OrderDate ,
  res.Plant,
  res.SalesOrg,
  res.SalesOrgName,
  res.AreaCode,
  res.AreaManager,
  res.mdc_name Distributor,
  res.mdc_Code DistributorCode,
  res.TerritorySalesManager,
  res.TSMCode,
  res.RepCode,
  res.RepName,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(res.customer_name, CHAR(13), ''), CHAR(10), ''),',',';'))) Customer,
  res.customer_Code CustomerCode,
  res.order_type OrderType,
  res.OrderNumber OrderNo,
  res.ProductCode,
  res.qty Quantity,
  res.qty_ec QuantityEC,
  res.net_price NetAmount
FROM 
  (
SELECT    
  o1.OrgCode as Plant,
  o2.OrgCode as SalesOrg,
  o2.OrgName as SalesOrgName,
  po.AreaCode,
  po.AreaManager,
  po.TerritorySalesManager,
  tsm.Code TSMCode,
  isnull(cc.CHAINS_NAME,'x') as mdc_name,
  isnull(cc.CHAINS_Code,'x') as mdc_Code,
  u.Code as RepCode,
  u.Name as RepName,
  p.Code as productCode,
  p.DESCRIPTION as product_desc,
  c.name as customer_name,
  c.Code as customer_Code,
  oh.order_no AS OrderNumber,
  oh.Confirmed_Date AS confirmed_date,
  MAX(oh.ORDER_date) AS order_date,
  CASE oh.OrderType WHEN 0 THEN 'Sales' ELSE  'Return' END AS order_type,
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
    inner join Customers c on oh.customer_id=c.id 
    inner join Users u on oh.USER_ID=u.USER_ID 
    inner join Users tsm on u.Manager_ID=tsm.USER_ID 
    inner join CUSTOMER_CHAINS cc on oh.customer_id=cc.customer_id
	LEFT JOIN View_PositionOrg po ON u.user_id = po.salesRepID
WHERE 
  isnull(ol.FREE_PRODUCTS,0)<>1 and (oh.STATUS = 6 or ol.OrderLineStatus=2)    
  and oh.order_date > '1Oct16' AND ( DATEPART(hh,oh.order_date) >= 20 OR DATEPART(hh,oh.order_date) < 5)
  and o2.OrgCode LIKE ('V%')
GROUP BY
  o1.OrgCode,o2.OrgCode,o2.OrgName,po.AreaCode, po.AreaManager,cc.CHAINS_NAME,cc.CHAINS_Code,p.Code,p.DESCRIPTION,c.name,c.Code,oh.order_no,oh.Confirmed_Date,
  oh.OrderType,ol.LINE_AMOUNT,ol.Promotion_TypeID,ol.LINE_DISC_RATE,
  ol.LINE_DISC_AMOUNT,c.Cooler_Customer,oh.USER_ID,u.Code, u.name, po.TerritorySalesManager,tsm.Code) res

 
