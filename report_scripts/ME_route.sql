UPDATE MAS_Customer SET valid = 0 WHERE id IN ( SELECT distinct c.id FROM MAS_ROUTECustomer r JOIN MAS_CUSTOMER c ON r.customerid = c.id WHERE userid IN (817,1183) AND c.longitude IS NULL )-- OR ID IN ()

SELECT * FROM MAS_CUSTOMER WHERE Code IN ( 'V0500130004922', 'V0500130005713' )

UPDATE MAS_ROUTECustomer SET valid = 0 WHERE customerid IN ( SELECT distinct c.id FROM MAS_ROUTECustomer r JOIN MAS_CUSTOMER c ON r.customerid = c.id WHERE userid IN (817,1183) AND c.longitude IS NULL)

SELECT * FROM MAS_ROUTECustomer WHERE customerid IN ( 392534, 428674, 428673)

SELECT c.longitude FROM MAS_ROUTECustomer r JOIN MAS_CUSTOMER c ON r.customerid = c.id WHERE userid IN (817,1183)