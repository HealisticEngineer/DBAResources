# DBAResources

DBAResources is a repository containing scripts that can help identify issues in SQL Server environments, such as unused indexes and nested views. These scripts are intended to be used as part of a health check for the environment.

## Database Creation Scripts

### Create_Database_Native.ps1
A PowerShell script that creates a SQL Server database using the native .NET SQL Client library (System.Data.SqlClient) instead of SMO. This script creates a database with best practices built-in:

**Features:**
- Creates PRIMARY filegroup for system objects (5MB, no growth)
- Creates UserFG filegroup with 4 NDF files for user objects (5MB each, grows by 100MB, max unlimited per file)
- Creates log file (5MB, grows by 128MB)
- Automatically enables Query Store with standard configuration (30-day retention, 1000MB max storage)
- Automatically enables Mixed Page Allocation
- Automatically enables Read Committed Snapshot Isolation (prevents read/write blocking)
- Configurable recovery model (SIMPLE or FULL) defaults to FULL
- Supports both Windows and SQL Server Authentication
- Works with SQL Server on Windows and Linux

**Usage:**
```powershell
# Windows Authentication
.\Create_Database_Native.ps1 -Instance "localhost" -MyDBName "MyDatabase"

# SQL Server Authentication
$pass = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
.\Create_Database_Native.ps1 -Instance "localhost" -MyDBName "MyDatabase" -Username "sa" -Password $pass

# With FULL recovery model
.\Create_Database_Native.ps1 -Instance "localhost" -MyDBName "MyDatabase" -Username "sa" -Password $pass -RecoveryModel "FULL"
```

### Create Database.ps1
Original database creation script using SQL Server Management Objects (SMO). Requires the SQLServer PowerShell module.

## Diagnostic Scripts

The following scripts are available in this repository:

- [Unused_Indexes.sql](https://github.com/HealisticEngineer/DBAResources/tree/main/Server%20Query/Unused_Indexes.sql): Identifies unused indexes in the database.
- [Nested_View.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/Nested_View.sql): Identifies nested views (views that reference other views) in the database.
- [Memory_Usage.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/Memory_Usage.sql): Shows memory usage by databases but also locks and blocked processes.
- [table_scan.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/table_scan.sql): Helps to find queries that create table scans.
- [CountVLF.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/CountVLF.sql): Find truncated virtual log files can cause transaction log backup to slow down as well as the database restore process.
- [too_many_indexes.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/too_many_indexes.sql): Find tables that have large number of indexes and could create I/O overhead for Insert/Update and Delete transactions.
- [DatabaseSettings.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/DatabaseSettings.sql): Checks some basic best practices like database compatablity, query store settigs and mixed page allocation.
- [Suggest_partitioning.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/Suggest_partitioning.sql): Identifies tables with over 1 million rows and shows their partition status, suggesting candidates for table partitioning. Uses snapshot isolation to prevent locking.
- [sql_query.conf](https://github.com/HealisticEngineer/DBAResources/blob/main/telegraf/sql_query.conf): Configuration file for Telegraf to collect SQL Server metrics using custom queries.
- [query_store.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Query_store/query_store.sql): Retrieves query execution statistics and execution plans from the Query Store.

## Usage

To use these scripts, simply download them from the repository and run them against your SQL Server instance. The results will be returned as a result set, which you can then analyze to identify any issues with the environment.

## Maintainer

DBAResources is maintained by John Hall (HealisticEngineer on GitHub).

Please feel free to contribute to this repository by submitting pull requests or opening issues for bugs and feature requests.
