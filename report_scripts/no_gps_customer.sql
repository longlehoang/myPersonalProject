SELECT distinct c.id,c.code FROM Customers c JOIN visits v on c.id = v.customer_id WHERE identity1 IS NULL And valid =1
