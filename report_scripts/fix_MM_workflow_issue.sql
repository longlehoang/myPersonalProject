
UPDATE WF_TaskHead SET CurrentStepID = 3, CurrentsenderUserID = 5121, currentSenderUserName = 'Kyaw Kyaw Htoo KA Horeca Manager' 
, currentREceiveUserId = 4987, currentReceiveUserName = 'Thin Yu Nwe' WHERE ID = '61abfb45-47d9-4a25-8c23-4bc6e0018cb6'

UPDATE WF_TASKDetail SET status = 1 where stepid =2 AND  taskheadid = '61abfb45-47d9-4a25-8c23-4bc6e0018cb6'
SELECT * FROM Customers WHERE Code = 'M0500390035191'
SELECT * FROM WF_Taskhead WHERE ID = '61abfb45-47d9-4a25-8c23-4bc6e0018cb6'
SELECT * FROM WF_TaskDetail WHERE taskheadid = '61abfb45-47d9-4a25-8c23-4bc6e0018cb6'