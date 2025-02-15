/*
Create a SQL Server script to find unused indexes in SQL Server with creation date and system startup time
Created by: John Hall

Script only list indexes that have not been used since the last system startup time.  And the indexes are older than 2 days.
This give a grace time to find only true unused indexes.

*/

-- if system startup time is more than two days, then find unused indexes in SQL Server with creation date and system startup time
declare @system_startup_time datetime = (SELECT sqlserver_start_time FROM sys.dm_os_sys_info)
if DATEDIFF(DAY, @system_startup_time, GETDATE()) > 2
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- create a table to declare select query into use in memory
    declare @indexes_unused table 
    (
        TableName nvarchar(255),
        IndexName nvarchar(255),
        IndexID int,
        CreationDate datetime,
        Seeks int,
        Scans int
    )

    Insert into @indexes_unused
    -- Query to find unused indexes in SQL Server with creation date
    SELECT 
        OBJECT_NAME(i.object_id) AS TableName,
        i.name AS IndexName,
        i.index_id AS IndexID,
        o.create_date AS CreationDate,
        s.user_seeks as Seeks,
        s.user_scans as Scans
    FROM 
        sys.indexes i WITH (NOLOCK)
        LEFT JOIN sys.dm_db_index_usage_stats s WITH (NOLOCK)
            ON i.object_id = s.object_id 
            AND i.index_id = s.index_id 
            AND s.database_id = DB_ID()
        JOIN sys.objects o WITH (NOLOCK)
            ON i.object_id = o.object_id
    WHERE
        -- object is not system object
        OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
        AND s.user_lookups = 0
        AND s.user_seeks = 0 
        AND s.user_scans = 0
    ORDER BY 
        TableName, IndexName;

    -- select the result where createion date more than 2 days
    select TableName, IndexName from @indexes_unused
    where CreationDate < DATEADD(DAY, -2, GETDATE());
end
