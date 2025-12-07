USE master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'TDEmasterkeypassword';
GO

CREATE CERTIFICATE MyServerCert WITH SUBJECT = 'DEK Certificate';
GO

USE SecureEmployeeDB;
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;
GO

ALTER DATABASE SecureEmployeeDB
SET ENCRYPTION ON;
GO

USE master;
GO

-- Also remember to create the Temp folder first
-- Back up the Certificate (The Public Key)
BACKUP CERTIFICATE MyServerCert
TO FILE = 'C:\Temp\MyServerCert.cer'
WITH PRIVATE KEY (
    -- Back up the Private Key (The Secret)
    FILE = 'C:\Temp\MyServerCert.pvk',
    ENCRYPTION BY PASSWORD = 'backuppassword'
);
GO

-- Verify the Encryption
SELECT
	db.name,
	db.is_encrypted,
	dm.encryption_state,
	dm.percent_complete
FROM sys.databases db
LEFT JOIN sys.dm_database_encryption_keys dm
ON db.database_id = dm.database_id
