SELECT po.*, c.Code, LTRIM(RTRIM(replace(REPLACE(REPLACE(C.Name, CHAR(13), ''), CHAR(10), ''),',',';'))) CustomerName, isnull(cc.CHAINS_NAME,'x') as Distributor,  isnull(cc.CHAINS_CODE,'x') as DistributorCode, op.* FROM [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po
LEFT JOIN order_headers oh ON po.salesRepID = oh.user_id AND oh.confirmed_date BETWEEN '6Sep16' AND '7Sep16'
JOIN Order_lines op ON oh.order_no = op.order_no AND promotion_typeID IS NOT NULL
JOIN customers c ON c.id = oh.customer_id
LEFT join  [10.0.0.7].CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id
													