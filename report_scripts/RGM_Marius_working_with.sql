SELECT DISTINCT customerid, RGMCode FROM SapRGMInvoiceData  WHERE Customerid = '0084000318'--ORDER BY ChangeDateTime DESC

SELECT * FROM SapRGMInvoiceData-- WHERE customerid IN ('0100010851')
SELECT * FROM SapRGMInvoiceData_bak0905


select * FROM SAPCodeDesc WHERE LOWER(CodeCategory) LIKE '%rgm%' ORDER BY CodeValue DESC