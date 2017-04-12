DELETE FROM sfaCodeDesc WHERE REC_USER_CODE = 'IOT interface' AND CodeCAtegory LIKE '%TYpe%'

INSERT INTO sfaCodeDESC

SELECT DISTINCT '*', '*', 'CoolerIOTType',  TYpeID, Label, GETDATE(), GETDATE() , 0, 'IOT interface' FROM ALERTS

SELECT * FROM sfaCodeDesc WHERE REC_USER_CODE = 'IOT interface' AND CodeCAtegory LIKE '%TYpe%'
