/*
===========================================================
Create Database and Schemas
===========================================================
Script Purpose:
	This Scrip creates a new database named-'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreate. Additionally the script sets up the schemas
	within the database : 'bronze', 'silver' and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database  if it exists.
	All data in the database will be permanently deleted. Proceed with caution 
	and ensure you have proper backupn before running the script.
*/


--Drop and Recreate Database 'DataWarehouse'--


IF EXISTS (SELECT 1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' Database--

CREATE DATABASE DataWarehouse;
GO

--Choose The Database--
USE DataWarehouse;
GO

--Create  Schemas---
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

