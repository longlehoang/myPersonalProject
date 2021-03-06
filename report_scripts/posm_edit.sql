/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [FormHeadID]
      ,[DetailNo]
      ,[FieldName]
      ,[FieldType]
      ,[Script]
      ,[EditbaleFlag]
      ,[MandetoryFlag]
      ,[Sequence]
      ,[Status]
      ,[CreateDate]
      ,[CreateUser]
      ,[UpdateDate]
      ,[UpdateUser]
  FROM [CCVN4].[dbo].[WF_FormDetail] WHERE FormHeadId IN
   ('D1FE550B-7467-4E92-991D-243A8F93EE71','5C12A337-5769-49B7-9C83-51356FC289A0','4AD342F8-770D-4351-B415-0C438F96A303')
   AND sequence IN (7,11)