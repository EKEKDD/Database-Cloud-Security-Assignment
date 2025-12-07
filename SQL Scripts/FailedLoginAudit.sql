USE master;
GO

-- Make sure to create the Temp folder first 
CREATE SERVER AUDIT [SecurityAuditFile]
TO FILE 
(	FILEPATH = 'C:\Temp\'

);
GO

-- Creating server audit and server audit specifications and enabling them
ALTER SERVER AUDIT [SecurityAuditFile] WITH (STATE = ON);
GO

-- Record failed logins
CREATE SERVER AUDIT SPECIFICATION [Audit_FailedLogins]
FOR SERVER AUDIT [SecurityAuditFile]
ADD (FAILED_LOGIN_GROUP);
GO

ALTER SERVER AUDIT SPECIFICATION [Audit_FailedLogins] WITH (STATE = ON);
GO

USE SecureEmployeeDB;
GO

-- Record anyone within public group that perform SELECT, INSERT, UPDATE, DELETE on Employees table
CREATE DATABASE AUDIT SPECIFICATION [Audit_SensitiveData_Access]
FOR SERVER AUDIT [SecurityAuditFile]
ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.Employees BY public)
WITH (STATE = ON);

GO

-- Read Audit Log
SELECT * FROM sys.fn_get_audit_file('C:\Temp\SecurityAuditFile*', DEFAULT, DEFAULT) ORDER BY event_time DESC;