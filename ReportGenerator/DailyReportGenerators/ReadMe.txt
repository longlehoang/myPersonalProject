sẵn m online gửi m cái này :D
script để export cái mớ đó ra

verification report, cooler report chạy 10.0.0.7 CCVN_Reporting DB
EXEC COde chạy 10.0.0.6 CCVN4 DB xuất vào file MTD
EXEC_Reporting chỉnh lại date thành hôm nay rồi chạy xuất vào REDdaily, route compliance chạy 10.0.0.7 CCVN_iMentor DB
tối nay giúp t chạy report rồi gửi ra mail theo mail m nhận dc mỗi ngày nhe
copy file xuất xong lên CCVNQAS server

[10.0.0.7]CCVN4_Reporting
	+ cooler_report_v2.sql ==> CoolerWFReport.xlsx
	+ verification_report_v2.sql ==> CoolerVerification.xlsx
	+ verification_report_NoPicture_v2.sql ==> CoolerVerification_NoPicture.xlsx

[10.0.0.7]CCVN_iMentor
	+ survey_report_sr_EXEC_Reporting_picture.sql ==> REDSurvey.xlsx (need to modify survey date in the script)
	+ route_compliance.sql ==> RouteCompliance_Export.xlsx
	
[10.0.0.6]CCVN4
	+ survey_report_sr_EXEC_Code ==> REDCustomerCodeMTD.xlsx
    
TEMP_RPT_VN_CoolerWFReport
TEMP_RPT_VN_CoolerVerification
TEMP_RPT_VN_CoolerVerification_NoPicture
TEMP_RPT_VN_REDSurvey
TEMP_RPT_VN_RouteCompliance_Export
TEMP_RPT_VN_REDCustomerCodeMTD