--SELECT TOP 10 * FROM CTS_COOLER_MASTER
-- every customer shipto must belong to 1 customer.
--SELECT * FROM Customer_ship_to WHERE SHIP_TO_CODE NOT IN (SELECT CODE from Customers)

-- 96989 customer has no same SHIP to code, a lot of ID customers.
--4753 customers DD has no ship to code, no need for 1? Because they are dummy DD customer code
--Only 53 customer DD has no shipto code.
--43252 DD customer each have shipto code
--225223 ID customer have shipto code
-- 1332 code customer have shipto code but not dummy.
--SELECT * FROM customers WHERE ID  IN (SELECT customer_id from Customer_ship_to WHERE ship_to_code IN (SELECT Code from customers WHERE org_id IS NULL) ) AND deliverytype = 'DD' AND org_id IS NOT NULL AND valid = 1

--only customer id 28505 (ID customer) have 2 shipto code. Must be a mistake. ID customer have max 1 shipto code.
--5587 shipto code for DD customer need to have dummy
--SELECT st.customer_ID, COUNT(*) co FROM Customer_ship_to st JOIN customers c ON c.id = st.customer_id AND deliverytype = 'DD' GROUP BY st.customer_ID HAVING count(*) > 1 ORDER BY 2 DESC 

SELECT COUNT(*) FROM Customer_ship_to WHERE ship_to_code NOT IN (SELECT Code from customers WHERE org_id IS NOT NULL) 
SELECT customer_id, COUNT(*) FROM customer_ship_to WHERE customer_id NOT IN (SELECT customer_id from Customer_ship_to WHERE ship_to_code IN (SELECT Code from customers 
WHERE org_id IS NULL  AND deliverytype = 'DD' AND valid = 1 )
) GROUP BY customer_ID HAVING count(*) > 1 ORDER BY 2 DESC

SELECT TOP 10 * FROM CTS_Cooler_Master
SELECT co.customerId, COUNT(*) FROM CTS_Cooler_Master co JOIN customers c ON c.id = customerid WHERE c.org_id IS NULL AND co.valid = 1 GROUP BY co.customerid ORDER BY 2 DESC

SELECT customerId, COUNT(*) FROM CTS_Cooler_Master WHERE valid = 1 GROUP BY customerid ORDER BY 2 DESC

SELECT * FROM Customer_ship_to WHERE SHIP_TO_CODE NOT IN (SELECT CODE from Customers)

SELECT C2.CODE, C2.Name, S.* FROM customers C join Customer_ship_to S on C.cODE = S.SHIP_TO_CODE
join CUSTOMERS C2 on C2.ID = S.CUSTOMER_ID
where C.org_id IS NULL order by 1,2,3