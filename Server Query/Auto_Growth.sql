-- Database growth events
DECLARE @current_tracefilename VARCHAR(500);
DECLARE @0_tracefilename VARCHAR(500);
DECLARE @indx INT;
SELECT @current_tracefilename = path
FROM sys.traces
WHERE is_default = 1;
SET @current_tracefilename = REVERSE(@current_tracefilename);
SELECT @indx = PATINDEX('%\%', @current_tracefilename);
SET @current_tracefilename = REVERSE(@current_tracefilename);
SET @0_tracefilename = LEFT(@current_tracefilename, LEN(@current_tracefilename) - @indx) + '\log.trc';
SELECT DatabaseName, 
       te.name, 
       Filename, 
       CONVERT(DECIMAL(10, 3), Duration / 1000000e0) AS TimeTakenSeconds, 
       StartTime, 
       EndTime, 
       (IntegerData * 8.0 / 1024) AS 'ChangeInSize MB', 
       ApplicationName, 
       HostName, 
       LoginName
FROM ::fn_trace_gettable(@0_tracefilename, DEFAULT) t
     INNER JOIN sys.trace_events AS te ON t.EventClass = te.trace_event_id
WHERE(trace_event_id >= 92
      AND trace_event_id <= 95)
ORDER BY t.StartTime;
