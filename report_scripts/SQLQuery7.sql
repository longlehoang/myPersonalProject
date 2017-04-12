--SELECT TOP 100 * FROM Trans_MeasureTransactionSummary ORDER BY LastUpdate Desc

select suser_sname(owner_sid) from sys.databases

select suser_sname(owner_sid) from sys.databases where name = 'CCVN4'

use CCVN4 EXEC sp_changedbowner 'sa' --CCVNHDB\ebest