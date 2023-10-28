--- tables with more than 5 indexes
DECLARE @threshold INT;
SET @threshold = 5;

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
  );
