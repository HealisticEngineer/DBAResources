/*
For best performances, you should have the same colation as the master database and use the same compatibility level if possible.
You should also use mixed page allocation this script shows all databases that don't match.
It also checks if the query store is on or off (recommend it on)
*/
--compare server to database compatibility
DECLARE @version INT
SET @version = (SELECT compatibility_level FROM sys.databases where name = 'master')
SELECT name, compatibility_level,collation_name,
CASE
When (is_query_store_on) = 1 Then 'ON'
When (is_query_store_on) = 0 Then 'OFF'
End as [Query_Store],
CASE
When (is_mixed_page_allocation_on) = 1 Then 'ON'
When (is_mixed_page_allocation_on) = 0 Then 'OFF'
End as [Mixed_Page_Allocation],
CASE
When (compatibility_level) = @version Then 'Match'
When (compatibility_level) != @version Then 'Lower Version'
End as [compatibility_level]
FROM sys.databases where database_id > 4
