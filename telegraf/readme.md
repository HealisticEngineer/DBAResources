# Telegraf SQL Query Configuration

This folder contains configuration and SQL scripts for collecting SQL Server metrics using Telegraf, a plugin-driven server agent for collecting and reporting metrics.

## Files

### [sql_query.conf](sql_query.conf)
- **Purpose**: Configuration file for the Telegraf SQL input plugin.
- **Key Features**:
  - Specifies the database driver (`sqlserver`) and connection details.
  - Points to the SQL script (`script.sql`) for executing queries.
  - Uses a DSN (Data Source Name) to connect to the SQL Server instance.
- **Usage**:
  - Update the `dsn` parameter with your SQL Server connection details.
  - Ensure the `query_script` parameter points to the correct SQL script file.

### [script.sql](script.sql)
- **Purpose**: SQL script to collect memory usage and SQL Server build information.
- **Key Metrics**:
  - **Memory Usage**:
    - Lock Blocks
    - Lock Memory
    - Database Cache Memory
    - Remaining Allocated Memory
  - **SQL Build**:
    - SQL Server product version.
- **Query Details**:
  - Uses `sys.dm_os_performance_counters` to gather memory-related metrics.
  - Calculates remaining allocated memory by subtracting used memory from the maximum server memory configuration.
  - Retrieves the SQL Server product version using `SERVERPROPERTY`.

## Usage Instructions

1. **Configure Telegraf**:
   - Place the `sql_query.conf` file in the appropriate Telegraf configuration directory.
   - Ensure the `query_script` parameter in `sql_query.conf` points to the `script.sql` file.

2. **Run Telegraf**:
   - Start or restart the Telegraf agent to begin collecting metrics.

3. **Analyze Metrics**:
   - The collected metrics will be sent to the configured output plugin in Telegraf (e.g., InfluxDB, Prometheus).

## Notes

- Ensure the SQL Server instance allows connections from the Telegraf agent.
- The SQL script uses `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` to avoid locking; use with caution in production environments.
- Modify the `dsn` and query parameters as needed to suit your environment.

## Author

These files are part of the DBAResources repository maintained by John Hall.