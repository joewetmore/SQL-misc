/*
#####################################################################################################
## Original Create Date: 6/15/05  Original Author: Jonas Irwin
## Current Version: 2.0
## Current Author: Mike Flannery
## 
## Purpose: 
## Grab IO statistics for SQL Server databases and data files over operator specified time interval
## Mods:   
## 12/20/07 - Flannery - Added UNION at end to make the output more end user readable
## 12/20/07 - Flannery - Tested with SQL Server 2005.  Made tables and columns case consistent 
## 3/14/08  - Flannery - Tested with SQL Server 2008
## 3/14/08  - Flannery - Changed SQLIO table from permanent to variable table
## 8/01/08  - Safa . Adjust case in Column calls 
## 8/01/08  - Safa . Validate on SQL 2000 and 2005 	
#####################################################################################################
 
*/
 
DECLARE @total int
DECLARE @now datetime
select @now = getdate()
select @total = 0

DECLARE @SQLIO TABLE
  (dbname  varchar(128) ,
  fname  varchar(2048), 
  startTime  datetime,
  noReads1  int,
  noWrites1  int,
  BytesRead1  bigint , 
  BytesWritten1  bigint ,
  noReads2  int,
  noWrites2  int,
  BytesRead2  bigint , 
  BytesWritten2 bigint, 
  endtime datetime,
  deltawrites  bigint,
  deltareads  bigint,
  timedelta   bigint,
  fileType   bit,
  fileSizeBytes bigint 
  )

USE master

--grab baseline first sample
INSERT INTO @SQLIO 
SELECT 
 cast(DB_Name(a.DbId) as varchar),
 b.filename,
 getdate(),
 cast(NumberReads as int),
 cast(NumberWrites as int),
 cast(a.BytesRead as bigint),
 cast(a.BytesWritten as bigint),
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 'filetype' = case when groupid > 0 then 1 else 0 end,
 cast(b.size as bigint) * 8192
FROM  
 ::fn_virtualfilestats(-1,-1) a ,sysaltfiles b
WHERE
  a.DbId = b.dbid and
  a.FileId = b.fileid
ORDER BY 1
 
/*DELAY AREA  - change time at will */
WAITFOR DELAY '001:00:00'
 

UPDATE @SQLIO 
set 
 BytesRead2=cast(a.BytesRead as bigint),
 BytesWritten2=cast(a.BytesWritten as bigint),
 noReads2 =NumberReads ,
 noWrites2 =NumberWrites,
 endtime= getdate(),
 deltawrites = (cast(a.BytesWritten as bigint)-BytesWritten1),
 deltareads= (cast(a.BytesRead as bigint)-BytesRead1),
        timedelta = (cast(datediff(s,startTime,getdate()) as bigint))
 
FROM ::fn_virtualfilestats(-1,-1) a ,sysaltfiles b
WHERE   fname= b.filename and dbname=DB_Name(a.DbId) and
  a.DbId = b.dbid and
  a.FileId = b.fileid
 

/*dump results to screen - individual results 
SELECT 
 'Transaction Log Size',
 sum(cast(b.size as float) * 8192)/1024/1024
FROM  
 ::fn_virtualfilestats(-1,-1) a ,sysaltfiles b
WHERE
  a.DbId = b.dbid and
  a.FileId = b.fileid and
  groupid = 0
union
SELECT 
 'Database Size',
 sum(cast(b.size as float) * 8192)/1024/1024/1024
FROM  
 ::fn_virtualfilestats(-1,-1) a ,sysaltfiles b
WHERE
  a.DbId = b.dbid and
  a.FileId = b.fileid and
  groupid > 0
union
select 
  'Read IO Percent', 
  (sum(cast(deltareads as float))/(sum(cast(deltawrites as float))+sum(cast(deltareads as float))))*100 
from @SQLIO
union
select
  'Database Read Rate',
  sum(cast(deltareads as float))/max(cast(timedelta as float))/1024/1024
from @SQLIO
union
select
  'Database Write Rate',
  sum(cast(deltawrites as float))/max(cast(timedelta as float))/1024/1024
from @SQLIO
union
select
  'Log Rate',
  (sum(cast(deltawrites as float))/max(cast(timedelta as float))/1024/1024)*3
from @SQLIO
where fileType=0
*/
/*dump results to screen - sizer appropriate results */
select * from @SQLIO
  

