SELECT COUNT(*)
FROM VISITS 
WHERE START_TIME BETWEEN '1-Oct-2015' AND '29-Jan-2016'
AND longitude <> 0

SELECT COUNT(*)
FROM VISITS 
WHERE START_TIME BETWEEN '1-Oct-2015' AND '29-Jan-2016'
AND longitude = 0-- 106.68280

SELECT COUNT(*)
FROM VISITS 
WHERE START_TIME BETWEEN '1-Oct-2015' AND '29-Jan-2016'

-- 53% GPS