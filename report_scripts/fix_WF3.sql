--SELECT * FROM Customers WHERE Code IN ('M0500390050164','M0500390032557','M0500390022908','M0500390048433')
--SELECT * FROM WF_TASKHEAD WHERE ParameterValue IN ('M0500390050164','M0500390032557','M0500390022908','M0500390048433')
SELECT * FROM WF_TASKHEAD WHERE ID = '876A6B02-33A9-4F15-A7F6-7DE2018CEECA'
SELECT * FROM WF_TASKDETAIL WHERE TASKHEADID IN ( '876A6B02-33A9-4F15-A7F6-7DE2018CEECA','ACE644DB-5559-4C14-B829-66B830F12F78','6EF3D3EC-91E8-4B1C-8E1F-657C1F742676')
AND stepID = 3
SELECT * FROM WF_TASKDETAIL WHERE stepID = 3 AND stepName = 'ASM approval'  and receiveUserID IS NULL
--UPDATE WF_TASKDETAIL SET receiveUserID =  4987, receiveUserName = 'Thin Yu Nwe' WHERE stepID = 3 AND stepName = 'ASM approval'  and receiveUserID IS NULL