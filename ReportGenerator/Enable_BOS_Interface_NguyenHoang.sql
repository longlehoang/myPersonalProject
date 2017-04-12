select *
from CCVN4.dbo.BOS_DISTRIBUTORS
where chain_id=1778;

--INSERT INTO CCVN4.dbo.BOS_DISTRIBUTORS (
	CHAIN_ID,valid
) VALUES (
	1778,'1'
);

select *
from user

select id
from customers
where id in (select top 100 customer_id
from customer_chains
where chains_id=1778)

select top 100 *
from [dbo].[ROUTE_CUSTOMERS]
where 1=1 --user_id=1947
and customer_id in (
select top 100 customer_id
from customer_chains
where chains_id=1778
)

select *
from [dbo].[bosCustomerGroup]

select top 100 *
from ORDER_PROMOTION_CUSTOMER
order by rec_time_stamp desc

select top 100 *
from [dbo].[PROMOTIONS]
where id=5003
order by start_time desc

select top 100 *
from [dbo].[ezEventBOS_VN]
where eventDateTIme >='30mar17'

select *
from [dbo].[ezEvent]
order by eventDateTime desc

 select * from bosAdjustment 
    WHERE AdjustmentListNumber BETWEEN 1000 AND 7000 AND CurrencyCode = 'VND'           
	 AND DeleteFlag = 0

select top 100 *
from [dbo].[ezEventHistory]
order by eventdatetime desc

[dbo].[ezEvent]

select top 100 *
from [dbo].[Error_Log]
order by crtdat desc

select *
from ORDER_PROMOTION 
where code between CONVERT(varchar,1100000) AND CONVERT(varchar,1100018)
order by code


select *
from ORDER_PROMOTION_PRODUCT
where promotion_id in (select id
from ORDER_PROMOTION 
where code between CONVERT(varchar,1100000) AND CONVERT(varchar,1100018))
order by promotion_id

select * from bosAdjustment 
WHERE AdjustmentListNumber BETWEEN 1100001 AND 1199999 AND CurrencyCode = 'VND'
	AND DeleteFlag = 0
 order by AdjustmentListNumber desc

select *
from [dbo].[bosCustomerGroup]

select c.CODE CUSTOMER_CODE,c.ID
from CUSTOMERS c
	INNER JOIN CUSTOMER_CHAINS cc ON c.ID = cc.CUSTOMER_ID
	INNER JOIN CHAINS ch on cc.CHAINS_ID = ch.ID
WHERE ch.CODE='0070295851'

select c.CODE CUSTOMER_CODE,c.ID
from CUSTOMERS c
	INNER JOIN CUSTOMER_CHAINS cc ON c.ID = cc.CUSTOMER_ID
	INNER JOIN CHAINS ch on cc.CHAINS_ID = ch.ID
WHERE c.CODE IN (
	'V0500130106752'
,'V0500130106751'
,'0070330328'
,'0070330325'
,'0070330324'
,'0070330320'
,'0070330079'
,'0070330061'
,'0070330057'
,'0070330056'
,'0070330055'
,'0070330054'
,'0070232641'
,'0070232639'
,'0070232638'
,'0070232637'
,'0070232636'
,'0070232635'
,'0070232634'
,'0070232633'
,'0070232632'
,'0070232630'
,'0070132554'
,'0070132551'
,'0070132550'
,'0070132516'
,'0070131947'
,'0070131932'
,'0070131922'
,'0070131760'
,'0070131759'
,'0070131756'
,'0070131711'
,'0070131688'
,'0070131684'
,'0070131682'
,'0070131648'
,'0070131591'
,'0070131474'
,'0070111423'
,'0070061534'
,'0070343159'
,'0070330336'
,'0070330335'
,'0070330334'
,'0070330333'
,'0070330332'
,'0070330331'
,'0070330330'
,'0070330329'
,'0070330327'
,'0070330326'
,'0070330323'
,'0070330322'
,'0070330321'
,'0070330319'
,'0070330318'
,'0070330317'
,'0070330316'
,'0070330315'
,'0070330314'
,'0070330060'
,'0070330059'
,'0070330058'
,'0070132269'
,'0070132268'
,'0070132179'
,'0070131989'
,'0070131952'
,'0070131950'
,'0070131903'
,'0070131385'
,'0070111426'
,'0070330357'
)