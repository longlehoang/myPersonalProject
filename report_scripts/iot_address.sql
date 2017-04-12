

UPDATE Customers SET Name = N'CAFE TRẦN THỊ BUÔNG', identity1 = 106.792483, identity2 = 10.860855, REC_TIME_STAMP = GETDATE() WHERE Code = '0070178160'
UPDATE Customers SET Name = N'CAFE VÂN THỦY', identity1 = 106.792489, identity2 = 10.860859 , REC_TIME_STAMP = GETDATE() WHERE Code = '0070178161'

UPDATE Contact_INFO SET Address_Line = N'485 Xa lộ Hà Nội - Phường Linh Trung - Quận Thủ Đức' , REC_TIME_STAMP = GETDATE() WHERE Customer_id = 206367
UPDATE Contact_INFO SET Address_Line = N'462 Xa lộ Hà Nội - Phường Linh Trung - Quận Thủ Đức' , REC_TIME_STAMP = GETDATE() WHERE Customer_id = 206368

SELECT * FROM Customers WHERE Code IN ('0070178160','0070178161')
SELECT * FROM CONTACT_INFO WHERE customer_id IN (206367, 206368)