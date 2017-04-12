with visit as(
	SELECT m1.customer_id, m1.longitude, m1.latitude
	FROM (SELECT * FROM Visits WHERE start_time > '1Jan15' AND longitude <> 0) m1 
	LEFT JOIN (SELECT * FROM Visits WHERE start_time > '1Jan15' AND  longitude <> 0) m2
	 ON (m1.customer_id  = m2.customer_id AND m1.start_time < m2.start_time)
	WHERE m2.id IS NULL
)
merge Customers as target
    using visit as source
    on target.id = source.customer_id AND target.identity1 IS NULL
    when matched then
        update set  target.identity1             = source.longitude,
                    target.identity2             = source.latitude,
                    target.rec_user_code    = 'Minh-GPS',
                    target.REC_TIME_STAMP   = getdate();