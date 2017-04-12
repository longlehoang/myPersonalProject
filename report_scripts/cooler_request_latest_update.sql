SELECT c.code CustomerCode,c.name CustomerName, w.* FROM WF_TaskHead w
INNER JOIN CUSTOMERS c ON w.ParameterValue = c.CODE
WHERE w.CreateDate >= '01-12-2016'
AND WorkFlowID = 10
AND CreateUser != 1947
ORDER BY CreateDate DESC;