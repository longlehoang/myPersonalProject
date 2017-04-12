SELECT po.SalesOffice,  c.Code CustomerCode,  cc.Code as DistributorCode
, oh.order_no, oh.confirmed_date, ol.PRODUCT_CODE, ol.Quantity_Confirmed_EC
  FROM ORDER_HEADERS oh JOIN ORDER_LINES ol ON oh.order_no = ol.order_no AND oh.confirmed_date between '2Apr16' and '30Apr16'
									  JOIN Customers c ON oh.customer_id = c.id
									  JOIN View_PositionORG po ON po.salesRepID = oh.user_id
									  LEFT JOIN CHAINS cc ON cc.id = oh.chain_id
WHERE po.salesOfficeID = 81
	