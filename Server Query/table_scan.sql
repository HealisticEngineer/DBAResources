BEGIN
    --Do not lock anything, and do not get held up by any locks.
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SELECT TOP 20 
    @@SERVERNAME As Container,
    st.text AS [SQL], cp.cacheobjtype,
    cp.objtype, DB_NAME(st.dbid)AS [DatabaseName],
    cp.usecounts AS [Plan usage], qp.query_plan
    FROM sys.dm_exec_cached_plans cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
    CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
    --Find Table Scans change the like for IndexSeek to see indexes that could be improved 
    WHERE CAST(qp.query_plan AS NVARCHAR(MAX))LIKE '%TableScan%' 
    AND DB_NAME(st.dbid) not in ('master','msdb')
    AND cp.usecounts > 1
    ORDER BY cp.usecounts DESC
END
