DELETE FROM sfaCodeDesc WHERE  CodeCAtegory LIKE '%Status%'

INSERT INTO sfaCodeDESC

SELECT DISTINCT '*', '*', 'CoolerIOTStatus', 1, 'New', GETDATE(), GETDATE() , 0, 'IOT interface' FROM ALERTS
INSERT INTO sfaCodeDESC

SELECT DISTINCT '*', '*', 'CoolerIOTStatus', 256, 'Acknowledged', GETDATE(), GETDATE() , 0, 'IOT interface' FROM ALERTS

INSERT INTO sfaCodeDESC

SELECT DISTINCT '*', '*', 'CoolerIOTStatus', 255,  'Closed', GETDATE(), GETDATE() , 0, 'IOT interface' FROM ALERTS

SELECT * FROM sfaCodeDesc WHERE CodeCAtegory LIKE '%Status%'
