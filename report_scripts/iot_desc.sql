DELETE SFACodeDEsc WHERE REC_USER_CODE = 'IOT interface'

INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTAsset', AssetID, CoolerAssetNo, GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts WHERE CoolerAssetNo NOT LIKE '% %'
INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTStatus', 1, 'New', GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts
INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTStatus', 256, 'Acknowledged', GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts
INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTStatus', 255, 'Closed', GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts

INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTType', TypeID, TypeDESC, GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts
INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTSource', SourceID, SourceDesc, GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts
INSERT INTO SFACOdeDESC 
SELECT DISTINCT '*', '*', 'CoolerIOTPriority', PriorityID, PriorityDesc, GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts
--INSERT INTO SFACOdeDESC 
--SELECT DISTINCT '*', '*', 'CoolerIOTLevel', LevelID, LevelDesc, GETDATE(), GETDATE(), 0, 'IOT interface' FROM Alerts

SELECT * FROM SFACodeDEsc WHERE REC_USER_CODE = 'IOT interface'