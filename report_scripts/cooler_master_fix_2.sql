SELECT co.* FROM Customers c JOIN ROUTE_CUSTOMERS rc ON c.id = rc.customer_id
JOIN CTS_Cooler_Master co ON co.customer_id = c.id
WHERE user_id IN (1206, 900)