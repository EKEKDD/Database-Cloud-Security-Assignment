USE SecureEmployeeDB
GO

-- Create SQL User Sam
-- This SQL Sam is different from the web app Sam. This is for holding internal threat actor from accessing other employees' data
CREATE LOGIN SQLSam WITH PASSWORD = 'userpassword';
GO

CREATE USER Sam FOR LOGIN SQLSam;
GO

GRANT SELECT ON Employees TO Sam;
DENY SELECT ON Users TO Sam;

GRANT UNMASK TO Sam;
GO

CREATE SCHEMA Security;
GO

-- When filtering, allow AppWorker to see all rows, dbo to see all rows, and Sam only see his own entry in plaintext
-- If match name, then return 1
CREATE FUNCTION Security.fn_securitypredicate(@FullName AS NVARCHAR(100))
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS fn_securitypredicate_result
    WHERE 
        DATABASE_PRINCIPAL_ID() = DATABASE_PRINCIPAL_ID('AppWorker')
        OR 
        DATABASE_PRINCIPAL_ID() = DATABASE_PRINCIPAL_ID('dbo')
        OR 
        @FullName = USER_NAME();
GO

-- Create a policy to bind the RLS function to Employees table
CREATE SECURITY POLICY Security.EmpSecurityPolicy
    ADD FILTER PREDICATE Security.fn_securitypredicate(FullName) ON dbo.Employees
    WITH (STATE = ON);
GO
