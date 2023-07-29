-- Create a login for the superuser with a password and default settings
CREATE LOGIN superuser WITH PASSWORD=N'Passw0rd!', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;

-- Grant the ability to impersonate the sa login to the superuser login
GRANT IMPERSONATE ON LOGIN::sa TO superuser;

-- Create a user for the superuser login in the current database
CREATE USER superuser FOR LOGIN superuser;

-- Disable the superuser login
ALTER LOGIN superuser DISABLE;

-- Create a stored procedure that the intermediate user can execute as the sa login
CREATE PROCEDURE sp_database_collection 
    @runid nvarchar(100) WITH EXECUTE AS 'superuser'
AS
BEGIN
    -- SQL statements to be executed
    SELECT name, @runid AS RUNID FROM sys.databases
END;


-- Create a login for the test user with a password and default settings
CREATE LOGIN [test] WITH PASSWORD=N'Passw0rd!', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- grant test user access to master database so can execute stored procedure
create user test for login test;

-- Grant the ability to execute the stored procedure to the intermediate user
GRANT EXECUTE ON OBJECT::dbo.sp_database_collection TO test;  
GO

-- Execute the stored procedure as the test user
EXEC sp_database_collection @runid = '123'

-- Execute as sa user and create a new database
EXECUTE AS LOGIN = 'superuser'
CREATE DATABASE test123;
REVERT;
