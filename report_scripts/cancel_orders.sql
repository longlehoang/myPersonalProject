UPDATE ORDER_HEADERS SET STATUS = 8 , REC_USER_CODE = 'Minh', REC_TIME_STAMP = GETDATE() WHERE ORDER_NO IN ('19471701251208501')
UPDATE ORDER_LINES SET OrderLineStatus = 3, CANCELLED = 'Y' , REC_USER_CODE = 'Minh', REC_TIME_STAMP = GETDATE() 
WHERE ORDER_NO IN ('19471701251208501')