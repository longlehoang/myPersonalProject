SELECT c.Code CustomerCode, LTRIM(RTRIM(replace(REPLACE(REPLACE(c.Name, CHAR(13), ''), CHAR(10), ''),'"','')))  CustomerName, c.Valid CustomerStatus, og.id, og.name, og.code, co.* FROM Customers c JOIN CTS_COOLER_MASTER co ON c.id = co.customerid
JOIN ORGANIZATION og ON og.id = c.org_id
WHERE og.code LIKE '%V%'