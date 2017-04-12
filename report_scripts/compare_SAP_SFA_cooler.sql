SELECT COUNT(*) SAPTotalActiveCooler FROM sapCoolerINFO co JOIN SAPcustomer c ON c.customerid = co.installedATcustomer
WHERE co.deleteflag = 0
AND c.deleteflag = 0
AND co.installedATcustomer IS NOT NULL


SELECT COUNT(*) SFATotalActiveCooler FROM CTS_Cooler_Master WHERE valid = 1

