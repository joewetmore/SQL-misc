http://mitchelsellers.com/blogs/2008/09/12/creating-random-sql-server-test-data.aspx
 
 
 
PROCEDURE1
================================================
Create a database
 
 
PROCEDURE2
================================================
CREATE TABLE dbo.TestTableSize
(
MyKeyField VARCHAR(10) NOT NULL,
MyDate1 DATETIME NOT NULL,
MyDate2 DATETIME NOT NULL,
MyDate3 DATETIME NOT NULL,
MyDate4 DATETIME NOT NULL,
MyDate5 DATETIME NOT NULL
)
 
 
PROCEDURE3
================================================
DECLARE @RowCount INT
DECLARE @RowString VARCHAR(10)
DECLARE @Random INT
DECLARE @Upper INT
DECLARE @Lower INT
DECLARE @InsertDate DATETIME
 
SET @Lower = -730
SET @Upper = -1
SET @RowCount = 0
 
WHILE @RowCount < 2000000
BEGIN
SET @RowString = CAST(@RowCount AS VARCHAR(10))
SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
SET @InsertDate = DATEADD(dd, @Random, GETDATE())
INSERT INTO TestTableSize
(MyKeyField
,MyDate1
,MyDate2
,MyDate3
,MyDate4
,MyDate5)
VALUES
(REPLICATE('0', 10 - DATALENGTH(@RowString)) + @RowString
, @InsertDate
,DATEADD(dd, 1, @InsertDate)
,DATEADD(dd, 2, @InsertDate)
,DATEADD(dd, 3, @InsertDate)
,DATEADD(dd, 4, @InsertDate))
 
SET @RowCount = @RowCount + 1
END
