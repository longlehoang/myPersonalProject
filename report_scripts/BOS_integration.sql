SELECT * FROM CHAINS WHERE CODE IN ('0090032412', '0090019279')

SELECT * FROM User_chains where chains_id = 207
SELECT * FROM customer_chains cc JOIN customers c ON c.id = cc.customer_id where chains_id = 207 AND c.code IN ('M0500370400440','M0500370300931')