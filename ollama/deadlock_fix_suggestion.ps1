# Define connection parameters
$server = "localhost" # replace with name of SQL server
$database = "master"  # Replace with your actual database name
$ollama = "localhost:11434" # replace with Ollama and port
$model = "qwen2.5-coder:14b" # replace with your model


$deadlock_query = "with XmlDeadlockReports as
(
  select convert(xml, event_data) as EventData
   from sys.fn_xe_file_target_read_file(N'system_health*.xel', NULL, NULL, NULL)
  where object_name = 'xml_deadlock_report'
) 
select TOP 1  EventData.value('(event/@timestamp)[1]', 'datetime2(7)') as TimeStamp,
       EventData.query('event/data/value/deadlock') as XdlFile
  from XmlDeadlockReports
 order by TimeStamp desc"

# Create SQL connection
$connectionString = "Server=$server;Database=$database;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
# Create SQL command
$command = $connection.CreateCommand()
$command.CommandText = $deadlock_query
# Open connection
$connection.Open()
# Execute query
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null
# Close connection
$connection.Close()
# Return results
$sql_deadlock = $dataset.Tables[0]

# Create prompt for Ollama
$body = @{
    model  = "$model"
    prompt = @"
Can you explain the following with ASCII tables and diagrams as if I don't know SQL and suggest a fix.

$($sql_deadlock.XdlFile)
"@
    stream = $false
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "http://${ollama}/api/generate" -Method Post -Body $body -ContentType "application/json"
# read the response from Ollama
return $response.response
