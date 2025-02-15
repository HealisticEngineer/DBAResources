/*
This script finds tables with more than 5 indexes, you can change the value to whatever you wish.
I recommend that you have no more than 10 indexes on a table as if there are more needed you should
split the table using the Third Normal Form (3NF)

Created by: John Hall
*/

--- tables with more than 5 indexes
DECLARE @threshold INT;
SET @threshold = 5;
begin
    -- lock nothing
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SELECT [table] = s.name + N'.' + t.name
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s
    ON t.[schema_id] = s.[schema_id]
    WHERE EXISTS
    (
        SELECT 1 FROM sys.indexes AS i
        WHERE i.[object_id] = t.[object_id]
        GROUP BY i.[object_id]
        HAVING COUNT(*) > @threshold
    )
END
