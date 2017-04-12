execute as login = 'sa'
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'CCVN4 Reporting',
    @recipients = 'dhai@coca-cola.com.vn; bkthang@coca-cola.com.vn; hatu@coca-cola.com.vn; nhbang@coca-cola.com.vn; dntrong@coca-cola.com.vn; dtlong@coca-cola.com.vn; ngpbtan@coca-cola.com.vn; nkngan@coca-cola.com.vn; pknguyen@coca-cola.com.vn; nmtien@coca-cola.com.vn; ptri@coca-cola.com.vn; hbtien@coca-cola.com.vn; phdieu@coca-cola.com.vn; vhai@coca-cola.com.vn; nvdung@coca-cola.com.vn; ngkquynh@coca-cola.com.vn; ngtminh@coca-cola.com.vn;minhdoanw@gmail.com',
    @query = 
'SET NOCOUNT ON; 
with res as(SELECT    
  po.*,
  isnull(cc.CHAINS_NAME,''x'') as Distributor,
  isnull(cc.CHAINS_CODE,''x'') as DistributorCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.name, CHAR(13), ''''), CHAR(10), ''''),'','','';''))) as Customer,
  c.code as  CustomerCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''''), CHAR(10), ''''),'','','';''))) as CustomerAddress,
  rs.GUID VerificationID,
  CASE WHEN rs.Equipment_No IS NOT NULL THEN rs.RFID ELSE NULL END Matched_AssetNo,
  rs.RFID Real_AssetNo,
  rs.Scan_Time VerifyTime,
  CASE WHEN rs.RFID IS NULL THEN 0 ELSE 1- rs.IS_Normal END VerifyStatus,
  rs.Exception_Lvl,
  rs.Reason_Code,
  rs.Remark Note,
  cooler.Barcode SAP_AssetNo,
  cooler.EquipmentModel SAP_Model,
  cooler.SerialNo SAP_SerialNumber,
  ''=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id='' + CP.ID + ''")'' PictureLink
FROM [10.0.0.6].[CCVN4].[dbo].[CTS_Result] rs
    join CCVN4_Reporting.dbo.Customers c on rs.customer_id=c.id 
    join CCVN4_Reporting.dbo.Users u on rs.USER_ID=u.USER_ID 
    join CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on rs.customer_id=cc.customer_id
	JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = rs.User_ID
	full outer JOIN [10.0.0.6].[CCVN4].[dbo].CTS_Cooler_Master cooler ON cooler.customerID = c.id AND rs.RFID = cooler.BarCode
    LEFT JOIN [10.0.0.6].[CCVN4].[dbo].[Customer_Photo] CP ON CP.User_Id = rs.user_id AND cp.customer_id = rs.customer_id AND CP.visit_Id = rs.visit_id
WHERE 1=1
AND cp.Photo_Type = 1 AND cp.valid = 1
AND rs.REC_TIME_STAMP > ''15-Feb-2016''
AND po.countryID = 8
--AND rs.GUID IS NULL
)

SELECT DISTINCT   
  po.*,
  isnull(cc.CHAINS_NAME,''x'') as Distributor,
  isnull(cc.CHAINS_CODE,''x'') as DistributorCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.name, CHAR(13), ''''), CHAR(10), ''''),'','','';''))) as Customer,
  c.code as  CustomerCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''''), CHAR(10), ''''),'','','';''))) as CustomerAddress,
  NULL VerificationID,
  NULL Matched_AssetNo,
  NULL Real_AssetNo,
  NULL VerifyTime,
  9999 VerifyStatus,
  NULL Exception_Lvl,
  NULL Reason_Code,
  NULL Note,
  cooler.Barcode SAP_AssetNo,
  cooler.EquipmentModel SAP_Model,
  cooler.SerialNo SAP_SerialNumber,
  NULL PictureLink
FROM CCVN4_Reporting.dbo.Customers c
    JOIN CCVN4_Reporting.dbo.ROUTE_CUSTOMERS rc ON rc.customer_id = c.id
	join CCVN4_Reporting.dbo.Users u on u.user_id = rc.USER_ID
	join CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on c.id=cc.customer_id
	JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = u.user_id
	full outer JOIN [10.0.0.6].[CCVN4].[dbo].CTS_Cooler_Master cooler ON cooler.customerID = c.id
    WHERE po.countryID = 8
	AND c.id IN (SELECT DISTINCT customer_id FROM [10.0.0.6].[CCVN4].[dbo].[CTS_Result])
	AND cooler.BarCode NOT IN (SELECT DISTINCT RFID FROM [10.0.0.6].[CCVN4].[dbo].[CTS_Result] WHERE RFID IS NOT NULL)
UNION ALL SELECT * FROM res
ORDER BY 1,2,3,4,5,6,11,12,13;
SET NOCOUNT OFF;' ,
    @subject = 'Cooler Verification daily report',
       @body = 
'Hi all,
       
Please see attached report for Cooler Verification from 15/02/2016. Status 9999 is cooler which is NOT VERIFIED.
       
Regards,
Minh',
       @attach_query_result_as_file = 1,
       @query_attachment_filename = 'CoolerVerificationDaily.csv',
       @query_result_separator = '	',
       @query_result_no_padding= 1,
       @query_result_width= 10000,
       @exclude_query_output =1
revert