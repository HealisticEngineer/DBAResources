SELECT 
	CAST(Pln.query_plan AS XML) AS 'Execution Plan', -- Output as XML
    Txt.query_sql_text, 
    Pln.plan_id as plan_id,
	Qry.query_id,
	Qry.query_hash,
	Qry.last_compile_start_time,
	Qry.last_execution_time,
	Qry.avg_compile_duration,
	RtSt.avg_duration,
	RtSt.avg_cpu_time,
	RtSt.avg_logical_io_reads,
	RtSt.avg_logical_io_writes,
	RtSt.avg_rowcount
FROM sys.query_store_plan AS Pln
INNER JOIN sys.query_store_query AS Qry
    ON Pln.query_id = Qry.query_id
INNER JOIN sys.query_store_query_text AS Txt
    ON Qry.query_text_id = Txt.query_text_id
INNER JOIN sys.query_store_runtime_stats RtSt
    ON Pln.plan_id = RtSt.plan_id