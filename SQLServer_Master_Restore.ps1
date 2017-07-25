## SQL Server DR Auto Recovery. ##
Import-Module SQLPS

# getting SQL server information
$SQL = Get-WmiObject win32_service | ?{$_.Name -like 'mssql*'} | select Name, DisplayName, State, PathName
$a = $SQL.Name
$service = get-service | Where-Object {$_.Name -like "MSSQL*"}

if($SQL.status -eq "Running") {
# Find SQL and stop it.
Stop-Service $service
} else {
    Write-output "SQL Server is not running"
}

# formating instance name with computer
$text = $a
$separator = "$" # you can put many separator like this "; : ,"
$parts = $text.split($separator)
$instance = $env:COMPUTERNAME+"\"+$parts[1]

# Start SQL with -M switch
net start $a /m

# Run database restore
Restore-SQLDatabase -ServerInstance $instance -Database "Master" -ReplaceDatabase -BackupFile "C:\Backup\master.bak"
#Backup-SqlDatabase -ServerInstance "WIN-UGKOS30H3TJ\YODA" -Database "Master" -BackupFile "C:\Backup\master.bak"
#Restore-SQLDatabase -ServerInstance "WIN-UGKOS30H3TJ\YODA" -Database "Master" -ReplaceDatabase -BackupFile "C:\Backup\master.bak"

# stop service and restart as normal
Start-Sleep 3 #wait for sql to stop
start-Service $service
Get-WmiObject win32_service | ?{$_.Name -like 'mssql*'} | select State, name
#Done