UPDATE ORDER_PROMOTION_PRODUCT SET valid = 0 
WHERE valid = 1 AND promotion_id IN (SELECT ID FROM order_promotion 
                               WHERE LEN(Code) = 4 AND org_id = 56 AND valid = 1);

with adj_product as(
    SELECT DISTINCT op.id as ID, ag.Article as Article FROM bosAdjustment a JOIN Order_promotion op ON op.Code = CONVERT(varchar(10),a.AdjustmentListNumber)
	JOIN bosAdjustmentSublist asub ON  a.AdjustmentListNumber = asub.AdjustmentListNumber
	JOIN bosArticleGroup ag ON ag.ArticleGroupingListName = asub.BreakPointGroupingListName
	WHERE DeleteFlag = 0 AND a.CurrencyCode = 'VND' AND op.org_id = 56 AND op.valid = 1
)
merge ORDER_PROMOTION_PRODUCT as target
    using adj_product as source
    on target.Promotion_ID = source.ID AND target.Product_Code = source.Article
    when matched then
        update set  target.Valid            = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (Promotion_id, OWN_UOM, OWN_QTY, Product_code, Valid, rec_user_code,REC_TIME_STAMP)
        VALUES (source.ID, 'CS', 999, source.Article, 1, 'BOS Interface', getdate());