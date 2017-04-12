UPDATE MDC_PROD_LIST_ITEMS
SET valid = 0
aasfa, REC_USER_CODE = 'Minh'
, REC_TIME_STAMP = GETDATE()
WHERE ISNULL(Piece_price,0) = 0
AND ISNULL(case_price,0) = 0
AND ISNULL(LandingPriceCS,0) = 0
AND ISNULL(LandingPriceEA,0) = 0
AND valid = 1
--AND MobileSaleFlag = 1