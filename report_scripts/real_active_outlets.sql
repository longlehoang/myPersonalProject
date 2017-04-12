SELECT p.country, c.customer_type, COUNT(DISTINCT c.Code) FROM customers c JOIN view_positionorg p ON c.org_id = p.SalesOfficeID JOIN order_headers oh ON oh.customer_id = c.id
WHERE c.valid = 1 AND c.DeliveryType <> 'CD'
AND oh.confirmed_date > '27Dec15'
AND LEN(c.code) < 15
GROUP BY p.Country, c.customer_type

