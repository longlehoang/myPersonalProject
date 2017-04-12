SELECT MeasureProfileID, MeasureGroupID, MeasureItemID, COUNT(*) FROM Customer_photo 
WHERE MeasureProfileID IN (19,21,36,37)
GROUP BY MeasureProfileID, MeasureGroupID, MeasureItemID
ORDER BY 1,2,4;

SELECT MeasureProfileID, MeasureGroupID, COUNT(*) FROM Customer_photo 
WHERE MeasureProfileID IN (19,21)--,36,37)
GROUP BY MeasureProfileID, MeasureGroupID
ORDER BY 1,2,3;
SELECT * FROM Biz_MeasureProfileDetail WHERE ProfileID = 19