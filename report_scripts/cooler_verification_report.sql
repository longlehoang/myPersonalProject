with res as(SELECT    
  po.*,
  isnull(cc.CHAINS_NAME,'x') as Distributor,
  isnull(cc.CHAINS_CODE,'x') as DistributorCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.name, CHAR(13), ''), CHAR(10), ''),',',';'))) as Customer,
  c.code as  CustomerCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) as CustomerAddress,
  rs.GUID VerificationID,
  CASE WHEN rs.Equipment_No IS NOT NULL THEN rs.RFID ELSE NULL END Matched_AssetNo,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(rs.RFID, CHAR(13), ''), CHAR(10), ''),',',';'))) as Real_AssetNo,
  rs.Scan_Time VerifyTime,
  CASE WHEN rs.RFID IS NULL THEN 0 ELSE 1- rs.IS_Normal END VerifyStatus,
  rs.Exception_Lvl,
  rs.Reason_Code,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(rs.Remark, CHAR(13), ''), CHAR(10), ''),',',';'))) as Note,
  cooler.Barcode SAP_AssetNo,
  cooler.EquipmentModel SAP_Model,
  cooler.SerialNo SAP_SerialNumber,
  '=HYPERLINK("http://ccvniis.cloudapp.net/IndoChina/Photo/ImgHelper.aspx?id=' + CP.ID + '")' PictureLink
FROM [10.0.0.6].[CCVN4].[dbo].[CTS_Result] rs
    join CCVN4_Reporting.dbo.Customers c on rs.customer_id=c.id 
    join CCVN4_Reporting.dbo.Users u on rs.USER_ID=u.USER_ID 
    join CCVN4_Reporting.dbo.CUSTOMER_CHAINS cc on rs.customer_id=cc.customer_id
	JOIN CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = rs.User_ID
	full outer JOIN [10.0.0.6].[CCVN4].[dbo].CTS_Cooler_Master cooler ON cooler.customerID = c.id AND rs.RFID = cooler.BarCode
    LEFT JOIN [10.0.0.6].[CCVN4].[dbo].[Customer_Photo] CP ON CP.User_Id = rs.user_id AND cp.customer_id = rs.customer_id AND CP.visit_Id = rs.visit_id
WHERE 1=1
AND cp.Photo_Type = 1 AND cp.valid = 1
AND rs.REC_TIME_STAMP > '15-Feb-2016'
AND po.countryID = 8
--AND rs.GUID IS NULL
)

SELECT DISTINCT   
  po.*,
  isnull(cc.CHAINS_NAME,'x') as Distributor,
  isnull(cc.CHAINS_CODE,'x') as DistributorCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.name, CHAR(13), ''), CHAR(10), ''),',',';'))) as Customer,
  c.code as  CustomerCode,
  LTRIM(RTRIM(replace(REPLACE(REPLACE(c.address_line, CHAR(13), ''), CHAR(10), ''),',',';'))) as CustomerAddress,
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