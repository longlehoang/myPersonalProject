SELECT customerid, count(*) FROM cTS_cooler_master
WHERE valid = 1
GROUP BY customerid
HAVING count(*) > 
ORDER BY 2 DESC