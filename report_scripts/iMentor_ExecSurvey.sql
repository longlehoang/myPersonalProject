SELECT CONVERT(date, res.LastUpdate) SurveyDate, AVG (res.Score) REDScore FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY TranS.customerID, TranS.MeasureProfileId ORDER BY TranS.LastUpdate ASC) AS Ranking FROM Trans_MeasureTransactionSummary TranS
WHERE TranS.LastUpdate
	BETWEEN '1-FEB-2017'
		AND '9-APR-2017'
AND TranS.MeasureProfileID IN (19,21)-- AND USERID IN (SELECT ID FROM MAS_USER WHERE GroupCode IN ('TSM','ASM'))
) res WHERE Ranking = 1
GROUP BY CONVERT(date, res.LastUpdate)

											--SELECT * FROM MAS_USER WHERE ID = 2227