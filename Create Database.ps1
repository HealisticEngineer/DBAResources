[CmdletBinding()]
param 
(
[Parameter(Mandatory = $True)][string]$Instance,
[Parameter(Mandatory = $True)][string]$MyDBName
)

Import-Module SQLServer


$server = New-Object ('Microsoft.SqlServer.Management.SMO.Server') $Instance
 
$MyDB = $server.Databases[$MyDBName]
#if ($MyDB) {$MyDB.Drop()}
 
if (!($MyDB)) # database doesn't exist yet, so create it
{
    Write-Host "Creating database: $MyDBName"
 
    # First, get the default locations for the data / log files.
    $DataLoc = $server.Settings.DefaultFile
    $LogLoc = $server.Settings.DefaultLog
 
    # If these are not set, then use the location of the master db mdf/ldf
    if ($DataLoc.Length -EQ 0) {$DataLoc = $server.Information.MasterDBPath}
    if ($LogLoc.Length -EQ 0) {$LogLoc = $server.Information.MasterDBLogPath}
 
    # If these paths don't end with a backslash character, add one.
    if (!$DataLoc.EndsWith("\")) {$DataLoc = $DataLoc + "\"}
    if (!$LogLoc.EndsWith("\")) {$LogLoc = $LogLoc + "\"}
 
    # Get a new database object
    $MyDB = New-Object ('Microsoft.SqlServer.Management.SMO.Database') ($server, $MyDBName)
 
    # Get a new filegroup object
    $MyPrimaryDBFG = New-Object ('Microsoft.SqlServer.Management.SMO.FileGroup') ($MyDB, 'PRIMARY')
    # Add the filegroup object to the database object
    $MyDB.FileGroups.Add($MyPrimaryDBFG)
 
    # Best practice is to separate the system objects from the user objects.
    # Get another filegroup to separate system stuff from user stuff
    $MySecondaryDBFG= New-Object ('Microsoft.SqlServer.Management.SMO.FileGroup') ($MyDB, 'UserFG')
    # Add the filegroup object to the database object
    $MyDB.FileGroups.Add($MySecondaryDBFG)
 
    # Create the database files
    # First, create the data file for holding the system objects, on the primary filegroup.
    # (also... need to set the primary filegroup to be the default)
    $MyDBSystemFile = $MyDBName + "_System"
    # Get a new datafile object
    $DBSysFile = New-Object ('Microsoft.SqlServer.Management.SMO.DataFile') ($MyPrimaryDBFG, $MyDBSystemFile)
    # Add it to the Primary filegroup
    $MyPrimaryDBFG.Files.Add($DBSysFile)
    # Set the file name to put this file in the same place as the master db files
    $DBSysFile.FileName = $DataLoc + $MyDBSystemFile + ".MDF"
    # Make the file size 5MB (sizes are in KB, so multiply here to MB)
    $DBSysFile.Size = [double](5.0 * 1024.0)
    # No growth on this file
    $DBSysFile.GrowthType = "None"
    # Make this the primary file
    $DBSysFile.IsPrimaryFile = 'True'
 
    # Now create the data file for the user objects
    $MyDBUserFile = $MyDBName + "_User"
    # Get a new datafile object
    $DBUserFile = New-Object ('Microsoft.SqlServer.Management.SMO.Datafile') ($MySecondaryDBFG, $MyDBUserFile)
    # Add this to the application filegroup
    $MySecondaryDBFG.Files.Add($DBUserFile)
    # Set the file name, same path as the system file above
    $DBUserFile.FileName = $DataLoc + $MyDBUserFile + ".NDF"
    # We're just playing around, so make this file size 5mb also.
    $DBUserFile.Size = [double] (5.0 * 1024.0)
    # Set the file growth to 5mb also.
    $DBUserFile.GrowthType = "KB"
    $DBUserFile.Growth = [double] (5.0 * 1024.0)
    # Set a max size of 100 MB
    $DBUserFile.MaxSize = [double] (100.0 * 1024.0)
 
    # Now we need a log file for this database
    $MyDBLogFile = $MyDBName + "_Log"
    $DBLogFile = New-Object ('Microsoft.SqlServer.Management.SMO.LogFile') ($Mydb, $MyDBLogFile)
    # Add this file to the database
    $MyDB.LogFiles.Add($DBLogFile)
    # Set the filename, size, growth
    $DBLogFile.FileName = $LogLoc + $MyDBLogFile + ".LDF"
    $DBLogFile.Size = [double] (5.0 * 1024.0)
    $DBLogFile.GrowthType = "KB"
    $DBLogFile.Growth = [double] (5.0 * 1024.0)
 
    #Create the database in the simple recovery model
    $MyDB.RecoveryModel = "SIMPLE"
    #Okay, now we are ready to create the database
    $MyDB.Create()
 
    #And the last step is to make the user filegroup the default
    $MySecondaryDBFG = $MyDB.FileGroups['UserFG']
    $MySecondaryDBFG.IsDefault = $true
    $MySecondaryDBFG.Alter()
    $MyDB.Alter()
}
 
#Let's see what we've got:
$MyDB |  `
    Select-Object Parent, Name, AutoShrink, LastBackupDate, PageVerify, RecoveryModel |`
    Format-Table -AutoSize
 
#show the filegroups
$MyDB.FileGroups |`
    Select-Object Parent, Name, IsDefault, IsFileStream, ReadOnly |`
    Format-Table -AutoSize
 
#show the files in the filegroups
$MyDB.FileGroups.Files | `
    Select-Object Parent, Name, Size, GrowthType, Growth, FileName |`
    Format-Table -AutoSize
 
#show the database log files
$MyDB.LogFiles |`
    Select-Object Parent, Name, Size, GrowthTYpe, Growth, Filename |`
    Format-Table -AutoSize