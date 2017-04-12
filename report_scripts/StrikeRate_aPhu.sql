SELECT Month, Year, uc.CHAINS_ID, AVG(kpi.StrikeRate) FROM USER_CHAINS uc JOIN Biz_UserMonthKPI kpi ON uc.user_id = kpi.userid
WHERE uc.CHAINS_ID IN (918,1754)
GROUP BY Month, Year, uc.CHAINS_ID

SELECT TOP 10 * FROM BIz_UserDailyKPI ORDER BY  Date 

SELECT * FROM CHAINS WHERE ID = 1754
