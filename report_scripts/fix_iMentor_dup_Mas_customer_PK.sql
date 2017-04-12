SELECT * FROM MAS_CUSTOMER WHERE ID = 459033

select TOP 3 'SUPV' as DomainCode,c.id,c.code,c.name,ch.code as distribuerCode,ch.DESCRIPTION,c.identity1 as longitude,c.IDENTITY2 as latitude
		,c.Geo_Level_Code,ci.address_line,ci.contactTel,ci.contactMobile,ci.fax,ci.e_mail,ci.ContactFirstName,ci.ContactLastName
		,c.Org_id,ci.Postal_Code,c.TradeChannel,c.SubTradeChannel,c.cooler_Customer,c.CustomerCategory,c.DeliveryType
		,c.customer_type,c.valid,getdate(),'USP_Supv_Init'
	from [CCVNDB].CCVN4.dbo.customers c
		 inner join [CCVNDB].CCVN4.dbo.contact_info ci on c.id = ci.customer_id
		 left join [CCVNDB].CCVN4.dbo.Customer_Chains cc on c.id = cc.customer_id
		 left join [CCVNDB].CCVN4.dbo.Chains ch on cc.chains_id = ch.id	
	where not exists (select 'x' from Mas_Customer mc where c.id = mc.id)
	AND c.ID = 459033
	and c.org_id is not null