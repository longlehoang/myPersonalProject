UPDATE ORDER_PROMOTION_CUSTOMER SET valid = 0 
WHERE valid = 1 AND promotion_id IN (SELECT ID FROM order_promotion 
                               WHERE Remark = 'BOS promotion created from SFA portal' AND org_id = 56 AND valid = 1);

with adj_customer as(
    SELECT DISTINCT op.id as ID, cg.OutletNumber FROM bosAdjustment a 
    JOIN Order_promotion op ON op.Code = CONVERT(varchar(10),a.AdjustmentListNumber)
    JOIN bosCustomerGroupAdjustmentConnection cgac ON  a.AdjustmentListNumber = cgac.AdjustmentListNumber
    JOIN bosCustomerGroup cg ON cg.CustomerGroupName = cgac.CustomerGroupName
    WHERE DeleteFlag = 0 AND a.CurrencyCode = 'VND' AND op.org_id = 56 AND op.valid = 1
    AND EXISTS (SELECT 1 FROM CUSTOMERS WHERE CUSTOMERS.ID = cg.OutletNumber)
)
merge ORDER_PROMOTION_CUSTOMER as target
    using adj_customer as source
    on target.Promotion_ID = source.ID AND target.CUSTOMER_ID = source.OutletNumber
    when matched then
        update set  target.Valid            = 1,
                    target.rec_user_code    = 'BOS Interface',
                    target.REC_TIME_STAMP   = getdate()
    when not matched by target then
        INSERT (Promotion_id, Customer_id, rec_user_code,REC_TIME_STAMP, valid)
        VALUES (source.ID, source.OutletNumber, 'BOS Interface', getdate(),1);

