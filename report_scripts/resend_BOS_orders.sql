update ezEventBOS_VN set EventStatus = 'RELE' where 
EventKey in (select ID from ORDER_HEADERS(nolock) where 
order_no = '10701612291509291')