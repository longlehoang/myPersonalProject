--inactive all customer assign to VN BOS promotion
UPDATE ORDER_PROMOTION_CUSTOMER SET valid = 0 
WHERE promotion_id IN (SELECT ID FROM order_promotion 
                                WHERE REC_USER_CODE = 'BOS Interface' AND org_id = 56 AND valid = 1);
                                
--merge with current product assign for VN BOS promotion
with adj_customer as(
    SELECT DISTINCT op.id as ID, ag.Article as Article FROM bosAdjustment a JOIN Order_promotion op ON op.Code = CONVERT(varchar(10),a.AdjustmentListNumber)
	JOIN bosAdjustmentSublist asub ON  a.AdjustmentListNumber = asub.AdjustmentListNumber
	JOIN bosArticleGroup ag ON ag.ArticleGroupingListName = asub.AdjustmentGroupingListName
	WHERE a.EffectiveToDate >= GETDATE() AND asub.EffectiveToDate >= GETDATE() AND op.END_time >= GETDATE() AND DeleteFlag = 0
)
merge ORDER_PROMOTION_CUSTOMER as target
    using adj_customer as source
    on target.Promotion_ID = source.ID AND target.Product_Code = source.Article
    when matched then
        update set  target.Valid            = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (Promotion_id, OWN_UOM, OWN_QTY, Product_code, Valid, rec_user_code,REC_TIME_STAMP)
        VALUES (source.ID, 'CS', 999, source.Article, 1, 'BOS Interface', getdate());