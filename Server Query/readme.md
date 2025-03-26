# Server Query Scripts

This folder contains a collection of SQL scripts designed to assist database administrators in analyzing and optimizing SQL Server environments. Each script addresses specific aspects of database performance, maintenance, and troubleshooting.

## Scripts Overview

### [CountVLF.sql](CountVLF.sql)
- **Purpose**: Identifies databases with a high number of Virtual Log Files (VLFs), which can impact transaction log backups and restore performance.
- **Key Metrics**: VLF count, active/inactive VLFs, and their sizes.

### [Unused_Indexes.sql](Unused_Indexes.sql)
- **Purpose**: Finds unused indexes that have not been accessed since the last system startup and are older than two days.
- **Key Metrics**: Index creation date, seeks, and scans.

### [too_many_indexes.sql](too_many_indexes.sql)
- **Purpose**: Identifies tables with more than a specified number of indexes (default is 5), which could indicate potential performance issues.
- **Recommendation**: Normalize tables with excessive indexes.

### [table_scan.sql](table_scan.sql)
- **Purpose**: Detects queries causing table scans, which can lead to performance bottlenecks.
- **Key Metrics**: Query text, database name, and execution plan.

### [Nested_View.sql](Nested_View.sql)
- **Purpose**: Identifies nested views with more than four levels of dependency, which can lead to performance and maintenance challenges.
- **Key Metrics**: View hierarchy and nesting levels.

### [Memory_Usage.sql](Memory_Usage.sql)
- **Purpose**: Analyzes memory usage by locks, joins, and databases, and calculates remaining allocated memory.
- **Key Metrics**: Memory usage by category and remaining memory.

### [Impersonate_example.sql](Impersonate_example.sql)
- **Purpose**: Demonstrates how to use SQL Server impersonation to execute stored procedures with elevated privileges securely.
- **Key Features**: Creates logins, users, and a stored procedure with impersonation.

### [deadlock_output.sql](deadlock_output.sql)
- **Purpose**: Retrieves the most recent deadlock reports from SQL Server or Azure SQL for analysis.
- **Key Output**: Deadlock XML data and timestamps.

### [DatabaseSettings.sql](DatabaseSettings.sql)
- **Purpose**: Checks database settings for compatibility level, collation, query store status, and mixed page allocation.
- **Recommendation**: Align settings with best practices for optimal performance.

## Usage

1. Open the desired script in your SQL Server Management Studio (SSMS) or preferred SQL client.
2. Execute the script against your SQL Server instance.
3. Review the output to identify potential issues or areas for optimization.

## Notes

- Ensure you have appropriate permissions to execute these scripts.
- Some scripts use `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` to avoid locking; use with caution in production environments.
- Modify thresholds and parameters as needed to suit your environment.

## Author

These scripts were created and maintained by John Hall. Contributions and feedback are welcome.