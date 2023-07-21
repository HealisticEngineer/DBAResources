-- create intermidiate user
-- Create a login for the intermediate user with a password and default settings
CREATE LOGIN [intermidiate] WITH PASSWORD=N'Passw0rd!', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- Disable the intermediate user login
ALTER LOGIN [intermidiate] DISABLE
GO

-- create intermidiate user in master database
-- Create a user for the intermediate login in the master database
USE [master];
CREATE USER [intermidiate] FOR LOGIN [intermidiate]
GO

-- grant impersonate on intermidiate user to sa
-- Grant the ability to impersonate the intermediate user to the sa login
GRANT IMPERSONATE ON LOGIN::sa TO intermidiate;
GO

-- create procedure that intermidiate user can execute as sa
-- Create a stored procedure that the intermediate user can execute as the sa login
CREATE PROCEDURE sp_database_collection
    @runid nvarchar(100)
AS
BEGIN
    -- SQL statements to be executed
    EXECUTE AS LOGIN = 'sa'
    SELECT name, @runid AS RUNID FROM sys.databases
    REVERT;
END;

-- grant execute on procedure to intermidiate user
-- Grant the ability to execute the stored procedure to the intermediate user
GRANT EXECUTE ON OBJECT::dbo.sp_database_collection TO intermidiate;  
GO

-- create test user
-- Create a login for the test user with a password and default settings
CREATE LOGIN [test] WITH PASSWORD=N'Passw0rd!', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- grant impersonate on login::intermidiate to test;
-- Grant the ability to impersonate the intermediate user to the test login
GRANT IMPERSONATE ON LOGIN::intermidiate TO test;
GO

-- execute procedure as test user
-- Execute the stored procedure as the test user
EXECUTE AS LOGIN = 'intermidiate'
EXEC sp_database_collection @runid = '123'
REVERT;

-- Execute as intermidiate user and create a new database
EXECUTE AS LOGIN = 'intermidiate'
CREATE DATABASE test123;
REVERT;
