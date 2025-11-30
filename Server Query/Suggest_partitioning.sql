
/*==========================================================
Author: John Hall
Date: Novemeber 30, 2025
Purpose: To find all table with 1 million+ rows and their partition info, if they are not partitioned, suggestion to partition
============================================================
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- CTE to get tables with more than 1 million rows
WITH TableRowCounts AS (
    SELECT 
        t.object_id,
        sch.name AS SchemaName,
        t.name AS TableName,
        SUM(p.rows) AS TotalRows
    FROM sys.tables t
    INNER JOIN sys.schemas sch ON t.schema_id = sch.schema_id
    INNER JOIN sys.partitions p ON t.object_id = p.object_id
    INNER JOIN sys.indexes i ON t.object_id = i.object_id AND p.index_id = i.index_id
    WHERE 
        p.index_id IN (0, 1) -- Only heap or clustered index
        AND t.is_ms_shipped = 0 -- Exclude system tables
    GROUP BY t.object_id, sch.name, t.name
    HAVING SUM(p.rows) > 1000000 -- Change to row threshold as needed
)
SELECT 
    trc.SchemaName,
    trc.TableName,
    p.partition_number AS PartitionNumber,
    p.rows AS RowsInPartition,
    trc.TotalRows,
    ps.name AS PartitionScheme,
    pf.name AS PartitionFunction,
    CASE 
        WHEN ps.name IS NULL THEN 'NOT PARTITIONED - Consider partitioning'
        ELSE 'PARTITIONED'
    END AS PartitionStatus,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM TableRowCounts trc
INNER JOIN sys.partitions p ON trc.object_id = p.object_id
INNER JOIN sys.indexes i ON trc.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
LEFT JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
WHERE p.index_id IN (0, 1) -- Only heap or clustered index
ORDER BY trc.TotalRows DESC, trc.SchemaName, trc.TableName, p.partition_number;