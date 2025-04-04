# Query Store SQL Script

This folder contains a SQL script designed to query and analyze data from the SQL Server Query Store. The Query Store is a feature in SQL Server that captures a history of queries, plans, and runtime statistics, making it easier to troubleshoot performance issues.

## File: [query_store.sql](query_store.sql)

### Purpose
The `query_store.sql` script retrieves detailed information about query execution plans, query text, and runtime statistics from the Query Store.

### Key Features
- **Execution Plan**: Outputs the execution plan in XML format for detailed analysis.
- **Query Details**:
  - Query text.
  - Query ID and hash for identifying and grouping queries.
  - Last compile and execution times.
- **Performance Metrics**:
  - Average compile duration.
  - Average execution duration.
  - Average CPU time.
  - Average logical I/O reads and writes.
  - Average row count.

### Query Logic
- Joins the following Query Store system views:
  - `sys.query_store_plan`: Provides information about query execution plans.
  - `sys.query_store_query`: Links queries to their plans and provides metadata.
  - `sys.query_store_query_text`: Contains the text of the queries.
  - `sys.query_store_runtime_stats`: Provides runtime statistics for executed queries.
- Filters and organizes the data to provide a comprehensive view of query performance.

### Usage Instructions
1. **Enable Query Store**:
   - Ensure the Query Store is enabled on the SQL Server database you want to analyze.
   - Use the following command to enable it if necessary:
     ```sql
     ALTER DATABASE [YourDatabaseName] SET QUERY_STORE = ON;
     ```

2. **Run the Script**:
   - Execute the `query_store.sql` script in SQL Server Management Studio (SSMS) or any SQL client connected to your SQL Server instance.

3. **Analyze Results**:
   - Review the output to identify queries with high resource usage or performance bottlenecks.
   - Use the execution plan XML for deeper analysis in SSMS or other tools.

### Notes
- The script assumes that Query Store is enabled and actively collecting data.
- Ensure you have appropriate permissions to access Query Store views.
- Modify the script as needed to filter or sort the results based on your requirements.

## Author
This script is part of the DBAResources repository maintained by John Hall.