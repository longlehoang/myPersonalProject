-- SR
SELECT distinct p.*, LEFT(v.Mobile_platform,7) FROM [10.0.0.7].CCVN4_REporting.dbo.view_positionorg p JOIN (SELECT * FROM Visits WHERE REC_TIME_STAMP > '1Jun16') v ON p.SalesRepid = v.user_id
--WHERE u.VALID = 1
--AND LEN(c.code) < 15
--GROUP BY p.*, c.Code,  LEFT(v.Mobile_platform,5)