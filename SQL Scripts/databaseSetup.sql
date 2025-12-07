-- 1. Create the Database
CREATE DATABASE SecureEmployeeDB;
GO

USE SecureEmployeeDB;
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL, -- Storing password hash, not plaintext
    Role NVARCHAR(20) DEFAULT 'User'
);
GO

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    
    -- Non-admins will only see XXX-XXX-1234 format
    ICNumber NVARCHAR(20) MASKED WITH (FUNCTION = 'partial(0, "XXX-XXX", 4)') NULL UNIQUE,
    
    -- Non-admins will see 0
    Salary DECIMAL(10, 2) MASKED WITH (FUNCTION = 'default()') NULL,
    
    Position NVARCHAR(50)
);
GO

-- Create a Least-Privilege web app user and this limits the web app so it cannot DROP tables, only Read/Write data.
-- So even if this AppWoker account is hacked, the hacker cannot drop tables or see sensitive info in plaintext
CREATE LOGIN AppWorker WITH PASSWORD = 'veryverystrongpassword';
CREATE USER AppWorker FOR LOGIN AppWorker;
GRANT SELECT, INSERT, UPDATE, DELETE ON Users TO AppWorker;
GRANT SELECT, INSERT, UPDATE, DELETE ON Employees TO AppWorker;
GO

-- Password is 'admin123' 'sam123'
INSERT INTO Users (Username, PasswordHash, Role) 
VALUES ('admin', 'scrypt:32768:8:1$neW3YKS6jXk3GLS6$94aa81a16cb4bc338981e55c0acfaed29ffb73b93dee8359a2061ca57a1282c9ffa0db84a63cebdedb8b2bf6d26dd42537fe8288cf2974e558fe6e18ca318be8', 'Admin'),

-- Sam here is web Sam, different from SQL Sam. This Sam can login to web app, but will see Access Denied.
-- So if someone stole or hacked web sam's account, no harm will be done
VALUES ('sam', 'scrypt:32768:8:1$Bez8FzrN6pbBDqgy$c76435ad7cc221e918465caf56b967836fe0b4101b32dda5f65105c0e6a98ba1d0fff597a7857e63fc41400a2c280c1a3a839bfdadb8349a7b245b5959f39fff', 'User');


INSERT INTO Employees (FullName, ICNumber, Salary, Position)
VALUES 
('John', '900101-14-5555', 6000.00, 'Manager'),
('Doe', '950505-10-1234', 4000.00, 'Executive'),
('Sam', '930714-12-1567', 3000.00, 'Analyst');


GO
