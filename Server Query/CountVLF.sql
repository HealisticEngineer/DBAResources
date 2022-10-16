/*
VLF stands for Virtual Log File. In SQL Server transaction log file is made up of one or more number of virtual log files.
Too many virtual log files can cause transaction log backup to slow down as well as the database restore process
*/
SELECT s.name AS 'Database Name',
lf.name as 'LogFile',
COUNT(li.database_id) AS 'VLF Count',
SUM(li.vlf_size_mb) AS 'VLF Size (MB)',
SUM(CAST(li.vlf_active AS INT)) AS 'Active VLF',
SUM(li.vlf_active*li.vlf_size_mb) AS 'Active VLF Size (MB)',
COUNT(li.database_id)-SUM(CAST(li.vlf_active AS INT)) AS 'Inactive VLF',
SUM(li.vlf_size_mb)-SUM(li.vlf_active*li.vlf_size_mb) AS 'Inactive VLF Size (MB)'
FROM sys.databases s
CROSS APPLY sys.dm_db_log_info(s.database_id) li
join (SELECT name, database_id FROM sys.master_files WHERE  type = 1) lf on lf.database_id = li.database_id
GROUP BY s.name,lf.name
having COUNT(li.database_id) >250
ORDER BY COUNT(li.database_id) DESC
