SELECT DISTINCT po.*, u.code USER_CODE, CONVERT(date, v.start_time) VISIT_DATE, v.Mobile_platform PLAT_FORM FROM VISITS v JOIN USERS u JOIN [10.0.0.7].CCVN4_Reporting.dbo.View_PositionOrg po ON po.SalesRepID = u.id  ON u.id = v.user_id
WHERE v.start_time BETWEEN '30Apr16' AND '30May16'