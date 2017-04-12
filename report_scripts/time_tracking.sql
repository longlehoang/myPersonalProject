SELECT po.*, a.attendance_date, attendance_type, attendance_value 
FROM ATTENDANCE_RESULT a JOIN Users u ON a.user_id = u.id
JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = u.id
WHERE a.Attendance_date > '1Jan16'
AND countryID = 155
ORDER BY 2,4,6,10,15,17