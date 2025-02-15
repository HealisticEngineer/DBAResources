# DBAResources

DBAResources is a repository containing scripts that can help identify issues in SQL Server environments, such as unused indexes and nested views. These scripts are intended to be used as part of a health check for the environment.

## Scripts

The following scripts are available in this repository:

- [Unused_Indexes.sql](https://github.com/HealisticEngineer/DBAResources/tree/main/Server%20Query/Unused_Indexes.sql): Identifies unused indexes in the database.
- [Nested_View.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/Nested_View.sql): Identifies nested views (views that reference other views) in the database.
- [Memory_Usage.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/Memory_Usage.sql): Shows memory usage by databases but also locks and blocked processes.
- [table_scan.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/table_scan.sql): Helps to find queries that create table scans.
- [CountVLF.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/CountVLF.sql): Find truncated virtual log files can cause transaction log backup to slow down as well as the database restore process.
- [too_many_indexes.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/too_many_indexes.sql): Find tables that have large number of indexes and could create I/O overhead for Insert/Update and Delete transactions.
- [DatabaseSettings.sql](https://github.com/HealisticEngineer/DBAResources/blob/main/Server%20Query/DatabaseSettings.sql): Checks some basic best practices like database compatablity, query store settigs and mixed page allocation.

## Usage

To use these scripts, simply download them from the repository and run them against your SQL Server instance. The results will be returned as a result set, which you can then analyze to identify any issues with the environment.

## Maintainer

DBAResources is maintained by John Hall (HealisticEngineer on GitHub).

Please feel free to contribute to this repository by submitting pull requests or opening issues for bugs and feature requests.
