with adj_product as(
    SELECT op.id, ag.Article FROM bosAdjustment a JOIN Order_promotion op ON op.Code = CONVERT(varchar(10),a.AdjustmentListNumber)
JOIN bosAdjustmentSublist asub ON  a.AdjustmentListNumber = asub.AdjustmentListNumber
JOIN bosArticleGroup ag ON ag.ArticleGroupingListName = asub.AdjustmentGroupingListName
WHERE a.EffectiveToDate >= GETDATE() AND DeleteFlag = 0
)
merge ORDER_PROMOTION_PRODUCT as target
    using adj_product as source
    on target.ID = source.PromotionID
    when matched then
        update set  target.Code             = source.AdjustmentListNumber,
                    target.Name             = source.AdjustmentDescription,
                    target.Start_Time       = source.EffectiveFromDate,
                    target.End_Time         = source.EffectiveToDate,
                    target.Valid            = - (source.deleteFlag - 1),
                    target.IsMultiple       = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (TypeID, Code, Name, Start_Time, End_Time, Remark, Valid, Domain_ID, org_id, rec_user_code,REC_TIME_STAMP, Apply, Exclude, Free_Qty, Free_UOM, Same_Product, Promotion_Form, IsMultiple, IsSingleUse, PromotionClass)
        VALUES (1, AdjustmentListNumber, AdjustmentDescription, EffectiveFromDate, EffectiveToDate,'BOS promotion created from SFA portal', 1, 1,56, 'BOS Interface', getdate(), 1 , 1, 1,'EA', 1, 0, 1, 0 , 2);