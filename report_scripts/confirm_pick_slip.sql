/****** Script for SelectTopNRows command from SSMS  ******/
UPDATE [CCVN4].[dbo].[PICK_LIST]
SET status = 1, REC_USER_CODE = 'Minh'
, REC_TIME_STAMP = GETDATE()
  WHERE ID IN (165613)