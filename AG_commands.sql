/* Commands from a project to configure DB mirroring between 2 servers where SQL server service is running as localsystem */


/* database mirroring */
SELECT name, role_desc, state_desc, connection_auth_desc, encryption_algorithm_desc   
   FROM sys.database_mirroring_endpoints;

USE master;
GO
CREATE LOGIN [ETHER\SQL2023$] FROM WINDOWS;
GO
GRANT CONNECT on ENDPOINT::Mirroring TO [ETHER\SQL2023$];
GO

  

/* certificate management */

USE master;  
SELECT * FROM sys.certificates;
BACKUP CERTIFICATE SQL2022_cert TO FILE = 'C:\SQL2022_cert.cer';  
GO 

  
USE master;  
CREATE CERTIFICATE SQL2022_cert   
   WITH SUBJECT = 'SQL2022_cert certificate for database mirroring',   
   EXPIRY_DATE = '9/11/2025';  
GO

  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'p@ssw0rd';  
GO


DECLARE @command varchar(1000)
SELECT @command = 'SELECT ''?'', * FROM sys.symmetric_keys'
EXEC sp_MSforeachdb @command


DECLARE @command varchar(1000)
SELECT @command = '
PRINT ''?'';
IF EXISTS(SELECT 1 FROM [?].sys.symmetric_keys)
BEGIN
  USE [?];
  PRINT '' Key(s) found!'';
  SELECT ''?'' AS db_name, *
  FROM sys.symmetric_keys
END
'
EXEC sp_MSforeachdb @command


USE master;  
SELECT * FROM sys.certificates;


