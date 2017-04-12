SELECT * FROM USERS WHERE COde = '00051456'

SELECT * FROM ROUTE_CUSTOMERS WHERE USER_ID = 254

SELECT * FROM Biz_UserDailyKPI WHERE userid = 254
SELECT * FROM Biz_UserWeekKPI WHERE userid = 254

select rc.USER_ID,count(distinct c.id) as PlannedCalls
			,count(distinct (case when (c.cooler_Customer is not null and c.Cooler_Customer <>'') then c.id else null end)) as CoolerCustomer
			,count(distinct (case when (c.customer_type is not null and c.customer_type <>'') then c.id else null end)) as RedCustomer
		from ROUTE_CUSTOMERS rc,CUSTOMERS c
		where rc.CUSTOMER_ID = c.ID
		AND rc.VALID = '1'
		AND c.VALID = '1'
		AND rc.USER_ID = 254
		AND rc.route_number = DATEPART(WEEKDAY,GETDATE() - 1)
		AND DATEDIFF(week, rc.start_time,GETDATE())% ( CASE WHEN ( frequence / 7 ) = 0 THEN 1 ELSE ( frequence / 7 )END ) = 0
		AND DATEDIFF(day, rc.start_time,GETDATE()) >= 0
		group by rc.USER_ID

		SELECT * FROM USERS WHERE ID IN (
		select DISTINCT oh.user_ID
		from order_headers oh with(nolock)inner join customers c on oh.CUSTOMER_ID =  c.id
							  left join visits v with(nolock) on oh.VISIT_ID = v.id and v.start_time >= cast(convert(varchar(10),getdate(),120) as datetime)
		where ORDER_date >= cast(convert(varchar(10),getdate(),120) as datetime)
		AND oh.USER_ID IN (SELECT ID FROM USERS WHERE GROUP_ID  = 3 AND id not in (SELECT DISTINCT USERID FROM Biz_UserDailyKPI) AND valid = 1))
		--group by oh.USER_ID