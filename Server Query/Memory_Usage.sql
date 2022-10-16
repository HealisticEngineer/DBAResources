/*
This script collects the memory and compares it to the memory allocated to show you the remaining memory.
Allowing you to see if joins, locks or databases are consuming all of the memory
*/
Declare @vtable table ([Counter] NVARCHAR(128), [In KB] bigint)
-- insert memory used
insert into @vtable
SELECT
  [counter_name] As Counter,
  cntr_value AS 'In KB'
FROM sys.dm_os_performance_counters
WHERE [counter_name] in (
  'Lock Blocks',
  'Lock Blocks Allocated',
  'Lock Memory (KB)',
  'Lock Owner Blocks',
  'Database Cache Memory (KB)                                                                                                      '
);
-- insert memory total minus memory used
insert into @vtable
SELECT Counter ='Remaining Allocated Memory', 
(
  (SELECT CAST(value_in_use AS bigint)*1024 AS 'In KB' FROM sys.configurations WHERE name ='max server memory (MB)' ) -
  (select sum([In KB]) AS 'In KB' from @vtable)
) as [in KB];
-- get total results
Select [Counter], [in KB] from @vtable
