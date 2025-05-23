/*
Nested views can be problematic for several reasons:
Performance Issues: Nested views can lead to complex and inefficient execution plans. Each layer of the view can add additional overhead, making queries slower.
Maintenance Complexity: Managing and understanding nested views can be difficult. Changes in one view can have cascading effects on other views, making debugging and maintenance challenging.
Limited Optimization: The SQL optimizer may not always be able to optimize queries involving nested views effectively, leading to suboptimal performance.
Hidden Logic: Business logic embedded in nested views can be hidden and harder to trace, making it difficult to understand the overall data flow and transformations.
Increased Resource Usage: Nested views can consume more memory and CPU resources, especially if they involve large datasets or complex calculations.
To avoid these issues, direct queries or materialized views are often better, which can provide better performance and maintainability.

Created by John Hall
*/

BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    WITH
    cRefobjects AS (
    -- Anchor level a view which refers to another view
    SELECT DISTINCT
    sed.referencing_id,
    sed.referenced_id,
    s.name AS SchemaName,
    o.name as ViewName,
    Convert(nvarchar(2000), N'>>'+ s.name+'.'+o.name) COLLATE DATABASE_DEFAULT as NestViewPath,
    o.type_desc,
    1 AS level
    FROM sys.sql_expression_dependencies sed
    INNER JOIN sys.objects o ON
    o.object_id = sed.referencing_id and
    o.type_desc ='VIEW'
    INNER JOIN sys.schemas AS s ON
    s.schema_id = o.schema_id
    LEFT OUTER JOIN sys.objects o2 ON
    o2.object_id = sed.referenced_id and
    o2.type_desc IN ('VIEW')
    WHERE
    o2.object_id is null

    UNION ALL
    -- Recursive part, retrieve any higher level views, build the path and increment the level
    SELECT
    sed.referencing_id,
    sed.referenced_id,
    s.name AS sch,
    o.name as viewname,
    Convert(nvarchar(2000),cRefobjects.NestViewPath + N'>' + s.name+'.'+o.name) COLLATE DATABASE_DEFAULT,
    o.type_desc,
    level + 1 AS level
    FROM sys.sql_expression_dependencies AS sed
    INNER JOIN sys.objects o ON
    o.object_id = sed.referencing_id and
    o.type_desc ='VIEW'
    INNER JOIN sys.schemas AS s ON
    s.schema_id = o.schema_id
    INNER JOIN cRefobjects ON
    sed.referenced_id = cRefobjects.referencing_id
    )
    SELECT DISTINCT SchemaName+'.'+ViewName as ViewName, NestViewPath, type_desc, level
    FROM cRefobjects
    WHERE level > 4
    ORDER BY level desc, viewname
    OPTION (MAXRECURSION 32)
END
