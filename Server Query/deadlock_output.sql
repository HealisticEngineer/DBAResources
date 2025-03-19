-- Deadlock on Azure SQL
 with XmlDeadlockReports as
 (
	select convert(xml, event_data) as EventData

	FROM sys.fn_xe_telemetry_blob_target_read_file('dl', NULL, NULL, NULL)
	WHERE object_name = 'database_xml_deadlock_report'
 )
 select TOP 1  EventData.value('(event/@timestamp)[1]', 'datetime2(7)') as TimeStamp,
       EventData.query('event/data/value/deadlock') as XdlFile
  from XmlDeadlockReports
 order by TimeStamp desc


 -- Deadlock on SQL Server
 with XmlDeadlockReports as
(
  select convert(xml, event_data) as EventData
   from sys.fn_xe_file_target_read_file(N'system_health*.xel', NULL, NULL, NULL)
  where object_name = 'xml_deadlock_report'
) 
select TOP 1  EventData.value('(event/@timestamp)[1]', 'datetime2(7)') as TimeStamp,
       EventData.query('event/data/value/deadlock') as XdlFile
  from XmlDeadlockReports
 order by TimeStamp desc
