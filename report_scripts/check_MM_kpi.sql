SELECT * FROM Organization

SELECT * FROM USERS WHERE ID IN (

SELECT userId FROM  Biz_UserDailyKPI WHERE userid IN (
SELECT id FROM users WHERE org_id IN (162,163,164,165,166)))