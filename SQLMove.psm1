<#
# use example
# SQL-Move -Source server\instance1 -Destination server\instance2 -oldname myolddb -newname mynewdb
#>
function Invoke-SQLMove{ 
[cmdletbinding()] 
param(
[Parameter(Mandatory=$true)][string]$Source,
[Parameter(Mandatory=$true)][string]$Destination,
[Parameter(Mandatory=$true)][string]$oldname,
[Parameter(Mandatory=$true)][string]$newname
) 

Import-Module SQLPS
 
# Backup file location
$BackupFile = "\\server1\share\$oldname.bak"
Backup-SqlDatabase -ServerInstance $Source -Database $oldname -BackupFile $BackupFile -CopyOnly

# Connection to destincation server
$SMOServer = new-object ('Microsoft.SqlServer.Management.Smo.Server') $Destination
  
# Get the Default File Locations 
$DefaultFileLocation = $SMOServer.Settings.DefaultFile 
$DefaultLogLocation = $SMOServer.Settings.DefaultLog 
if ($DefaultFileLocation.Length -eq 0)  
    {  
        $DefaultFileLocation = $SMOServer.Information.MasterDBPath  
    } 
if ($DefaultLogLocation.Length -eq 0)  
    {  
        $DefaultLogLocation = $SMOServer.Information.MasterDBLogPath  
    } 
 
#initialize internal variables 
$relocate = @() 
$dbfiles = Invoke-Sqlcmd -ServerInstance $Destination -Database tempdb -Query "RESTORE FILELISTONLY FROM DISK='$BackupFile';" 
foreach($dbfile in $dbfiles){ 
    $DbFileName = $dbfile.PhysicalName | Split-Path -Leaf 
    if($dbfile.Type -eq 'L'){ 
        $newfile = Join-Path -Path $DefaultLogLocation -ChildPath $DbFileName 
    } else { 
        $newfile = Join-Path -Path $DefaultFileLocation -ChildPath  $DbFileName 
    } 
    $relocate += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile ($dbfile.LogicalName,$newfile) 
} 
Restore-SqlDatabase -ServerInstance $Destination -Database $newname -RelocateFile $relocate -BackupFile "$BackupFile" -RestoreAction Database
Remove-Item $BackupFile
} 