SELECT  DATEPART(Month, res.confirmed_date) Month, DATEPART(Year, res.confirmed_date) Year,--CONVERT(date, res.confirmed_date) ConfirmedDate ,
  /*res.Plant,
  res.SalesOrg,
  res.SalesOrgName,
  res.AreaCode,
  res.AreaManager,*/
  res.mdc_name Distributor,
  res.mdc_code DistributorCode,
  /*res.TerritorySalesManager,
  res.TSMCode,
  res.RepCode,
  res.RepName,
  res.customer_name Customer,
  res.customer_code CustomerCode,*/
  COUNT(DISTINCT res.OrderNumber) as TotalOrder,
  SUM(res.qty_ec) as TotalVolumeEC,
  SUM(res.net_price) as TotalAmount
FROM 
  (
SELECT    
 
  isnull(cc.description,'x') as mdc_name,
  isnull(cc.code,'x') as mdc_code,
  oh.order_no AS OrderNumber,
  oh.Confirmed_Date AS confirmed_date,
  MAX(oh.ORDER_date) AS order_date,
  (CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed),0) ELSE isnull(SUM(-ol.Quantity_Confirmed),0) END) as qty,
  (CASE oh.OrderType WHEN 0 THEN isnull(SUM(ol.Quantity_Confirmed_ec),0) ELSE isnull(SUM(-ol.Quantity_Confirmed_ec),0) END) as qty_ec,
  isnull(SUM(ol.LINE_AMOUNT),0) as list_price,
  (CASE ol.Promotion_TypeID WHEN 3 THEN cast(ol.LINE_DISC_RATE as nvarchar)+'%' ELSE cast(ol.LINE_DISC_RATE as nvarchar) end) as discount,
  sum(ol.LINE_AMOUNT-isnull(ol.Line_Disc_Amount,ol.Line_Amount)) as discount_value,
  SUM(isnull(ol.Line_Disc_Amount,ol.Line_Amount)) as net_price,
  (CASE oh.ordertype WHEN 0 THEN 'orders' ELSE 'trade returns' end ) as ordertype
FROM 
  order_headers (nolock) oh
    inner join order_lines ol on ol.order_no=oh.order_no
	JOIN Chains cc ON cc.ID = oh.CHAIN_ID
	
WHERE 
  isnull(ol.FREE_PRODUCTS,0)<>1 and (oh.STATUS = 6 or ol.OrderLineStatus=2)    
  and oh.Confirmed_Date Between '30Jan15' AND '29Jun16'
  and oh.CHAIN_ID IN (918,1754)
GROUP BY
  cc.description,cc.Code,oh.order_no,oh.Confirmed_Date,
  oh.OrderType,ol.LINE_AMOUNT,ol.Promotion_TypeID,ol.LINE_DISC_RATE,
  ol.LINE_DISC_AMOUNT) res
GROUP BY DATEPART(Month, res.confirmed_date), DATEPART(Year, res.confirmed_date),--CONVERT(date, res.confirmed_date),
 /* res.Plant,
  res.SalesOrg,
  res.SalesOrgName,
  res.AreaCode,
  res.AreaManager,*/
  res.mdc_name,
  res.mdc_code
  /*res.customer_name,
  res.customer_code,
  res.TerritorySalesManager,
  res.TSMCode,
  res.RepCode,
  res.RepName*/
  ORDER BY  --CONVERT(date, res.confirmed_date),
  1,2,3
 
