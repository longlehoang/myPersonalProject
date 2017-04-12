--merge with MM BOS adjustment
with adj as(
    select * from bosAdjustment 
    WHERE AdjustmentListNumber BETWEEN 2000 AND 3000 AND CurrencyCode = 'MMK'            AND DeleteFlag = 0
)
merge ORDER_PROMOTION as target
    using adj as source
    on target.Code = CONVERT(varchar,source.AdjustmentListNumber) AND target.Remark = 'BOS promotion created from SFA portal'  AND target.org_id = 157
    when matched then
        update set  target.Code             = source.AdjustmentListNumber,
                    target.Name             = source.AdjustmentDescription,
                    target.Start_Time       = source.EffectiveFromDate,
                    target.End_Time         = source.EffectiveToDate,
                    --target.Valid            = - (source.deleteFlag - 1),
                    target.IsMultiple       = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (TypeID, Code, Name, Start_Time, End_Time, Remark, Valid, Domain_ID, org_id, rec_user_code,REC_TIME_STAMP, Apply, Exclude, Free_Qty, Free_UOM, Same_Product, Promotion_Form, IsMultiple, IsSingleUse, PromotionClass)
        VALUES (1, AdjustmentListNumber, AdjustmentDescription, EffectiveFromDate, EffectiveToDate,'BOS promotion created from SFA portal', 1, 1,157, 'BOS Interface', getdate(), 1 , 1, 1,'EA', 1, 0, 1, 0 , 2);


--merge with MM BOS adjustment for Mandalay
with adj as(
    select * from bosAdjustment 
    WHERE AdjustmentListNumber BETWEEN 2000 AND 3000 AND CurrencyCode = 'MMK'            AND DeleteFlag = 0
)
merge ORDER_PROMOTION as target
    using adj as source
    on target.Code = CONVERT(varchar,source.AdjustmentListNumber) AND target.Remark = 'BOS promotion created from SFA portal'  AND target.org_id = 160
    when matched then
        update set  target.Code             = source.AdjustmentListNumber,
                    target.Name             = source.AdjustmentDescription,
                    target.Start_Time       = source.EffectiveFromDate,
                    target.End_Time         = source.EffectiveToDate,
                    --target.Valid            = - (source.deleteFlag - 1),
                    target.IsMultiple       = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (TypeID, Code, Name, Start_Time, End_Time, Remark, Valid, Domain_ID, org_id, rec_user_code,REC_TIME_STAMP, Apply, Exclude, Free_Qty, Free_UOM, Same_Product, Promotion_Form, IsMultiple, IsSingleUse, PromotionClass)
        VALUES (1, AdjustmentListNumber, AdjustmentDescription, EffectiveFromDate, EffectiveToDate,'BOS promotion created from SFA portal', 1, 1,160, 'BOS Interface', getdate(), 1 , 1, 1,'EA', 1, 0, 1, 0 , 2);

--merge with MM BOS adjustment for Mawlamyaing
with adj as(
    select * from bosAdjustment 
    WHERE AdjustmentListNumber BETWEEN 2000 AND 3000 AND CurrencyCode = 'MMK'            AND DeleteFlag = 0
)
merge ORDER_PROMOTION as target
    using adj as source
    on target.Code = CONVERT(varchar,source.AdjustmentListNumber) AND target.Remark = 'BOS promotion created from SFA portal'  AND target.org_id = 177
    when matched then
        update set  target.Code             = source.AdjustmentListNumber,
                    target.Name             = source.AdjustmentDescription,
                    target.Start_Time       = source.EffectiveFromDate,
                    target.End_Time         = source.EffectiveToDate,
                    --target.Valid            = - (source.deleteFlag - 1),
                    target.IsMultiple       = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (TypeID, Code, Name, Start_Time, End_Time, Remark, Valid, Domain_ID, org_id, rec_user_code,REC_TIME_STAMP, Apply, Exclude, Free_Qty, Free_UOM, Same_Product, Promotion_Form, IsMultiple, IsSingleUse, PromotionClass)
        VALUES (1, AdjustmentListNumber, AdjustmentDescription, EffectiveFromDate, EffectiveToDate,'BOS promotion created from SFA portal', 1, 1,177, 'BOS Interface', getdate(), 1 , 1, 1,'EA', 1, 0, 1, 0 , 2);
        
--merge with VN BOS adjustment
with adj as(
    select * from bosAdjustment 
    WHERE AdjustmentListNumber BETWEEN 1000 AND 7000 AND CurrencyCode = 'VND'            AND DeleteFlag = 0
)
merge ORDER_PROMOTION as target
    using adj as source
    on target.Code = CONVERT(varchar,source.AdjustmentListNumber) AND target.Remark = 'BOS promotion created from SFA portal'  AND target.org_id = 56 
    when matched then
        update set  target.Code             = source.AdjustmentListNumber,
                    target.Name             = source.AdjustmentDescription,
                    target.Start_Time       = source.EffectiveFromDate,
                    target.End_Time         = source.EffectiveToDate,
                    --target.Valid            = - (source.deleteFlag - 1),
                    target.IsMultiple       = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (TypeID, Code, Name, Start_Time, End_Time, Remark, Valid, Domain_ID, org_id, rec_user_code,REC_TIME_STAMP, Apply, Exclude, Free_Qty, Free_UOM, Same_Product, Promotion_Form, IsMultiple, IsSingleUse, PromotionClass)
        VALUES (1, AdjustmentListNumber, AdjustmentDescription, EffectiveFromDate, EffectiveToDate,'BOS promotion created from SFA portal', 1, 1,56, 'BOS Interface', getdate(), 1 , 1, 1,'EA', 1, 0, 1, 0 , 2);
       
--inactive all product assign to VN BOS promotion
--UPDATE ORDER_PROMOTION_PRODUCT SET valid = 0 
--WHERE valid = 1 AND promotion_id IN (SELECT ID FROM order_promotion 
--                               WHERE Remark = 'BOS promotion created from SFA portal' AND org_id = 56 AND valid = 1);
                                

--merge with current product assign for VN BOS promotion
/*with adj_product as(
    SELECT DISTINCT op.id as ID, ag.Article as Article FROM bosAdjustment a JOIN Order_promotion op ON op.Code = CONVERT(varchar(10),a.AdjustmentListNumber)
	JOIN bosAdjustmentSublist asub ON  a.AdjustmentListNumber = asub.AdjustmentListNumber
	JOIN bosArticleGroup ag ON ag.ArticleGroupingListName = asub.AdjustmentGroupingListName
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
*/