/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [CCVN4].[dbo].[Segmentation_Customer] sc JOIN CCVN4.dbo.Customers c ON c.id = sc.id
  --WHERE c.code <> sc.CustomerCode
  AND c.code = 'H0507D0643'

  SELECT *
  FROM [CCVN4].[dbo].[Segmentation_Customer] sc WHERE CustomerCode = 'H0507D0643'

  --SELECT * FROM CCVN4.dbo.Customers WHERE code = 'H0507D0643'

  UPDATE CCVN4.dbo.Customers SET code = '0250070001', REC_USER_CODE = 'Minh', REC_TIME_STAMP = GETDATE() WHERE Code = 'H0507D0643'
