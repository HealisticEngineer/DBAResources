-- create no locks
SET DEADLOCK_PRIORITY -10;
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- query
Declare @vtable table ([Counter] NVARCHAR(26), [In KB] bigint)
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
  'Database Cache Memory (KB)'
);
-- insert memory total minus memory used
insert into @vtable
SELECT Counter ='Remaining Allocated Memory', 
(
  (SELECT CAST(value_in_use AS bigint)*1024 AS 'In KB' FROM sys.configurations WHERE name ='max server memory (MB)' ) -
  (select sum([In KB]/1024) AS 'In KB' from @vtable)
) as [in KB];
-- get total results
Select  TRIM([Counter]) as measurement,servername= REPLACE(@@SERVERNAME, '\', ':'),
type = 'Memory Usage', cast(([in KB]) as nvarchar) As [Value] from @vtable
UNION ALL
select measurement = 'ProductVersion',servername= REPLACE(@@SERVERNAME, '\', ':'),
type = 'SQL Build',LEFT(CAST(SERVERPROPERTY('productversion') as nvarchar),15) AS [Value]