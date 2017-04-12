SELECT oh.Order_Date, oh.Order_No, '0090037114' as Distributor_Code,p.* FROM [10.0.0.6].CCVN4.dbo.PICK_LIST p
JOIN [10.0.0.6].CCVN4.dbo.order_headers oh ON p.id = oh.pick_list_id 
WHERE p.CHAIN_ID = 1740
ORDER BY 1,2,3