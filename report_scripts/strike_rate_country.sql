SELECT CONVERT(DAte,v.START_TIME), count(distinct case when (oh.OrderType = 0 ) then oh.CUSTOMER_ID else null end) as SalesCalls
from order_headers oh with(nolock) inner join customers c on oh.CUSTOMER_ID =  c.id 
	 INNER JOIN Biz_UserDailyKPI ukpi ON ukpi.userid = oh.user_id AND ukpi.DAte = CONVERT(Date,oh.order_date)
	 left join visits v on oh.VISIT_ID = v.id and v.start_time >= cast(convert(varchar(10),getdate(),120) as datetime)
where ORDER_date >= cast(convert(varchar(10),getdate(),120) as datetime)
group by CONVERT(Date,v.START_TIME)