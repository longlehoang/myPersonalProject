SELECT COUNT(*) FROM SapCustomer WHERE DeliveryTYpe = 'ID' 
AND customerid  IN (SELECT installedatcustomer FROM sapCoolerInfo WHERE deleteflag = 0) 
AND sapcustomer.deleteflag = 0-- AND countryID = 'VN'
