[CmdletBinding()]
param 
(
    [Parameter(Mandatory = $True)][string]$Instance,
    [Parameter(Mandatory = $True)][string]$MyDBName,
    [Parameter(Mandatory = $False)][string]$Username,
    [Parameter(Mandatory = $False)][SecureString]$Password,
    [Parameter(Mandatory = $False)]
    [ValidateSet("SIMPLE", "FULL")]
    [string]$RecoveryModel = "FULL"
)

# Load the SQL Client assembly
Add-Type -AssemblyName "System.Data"

# Build connection string based on authentication type
if ($Username -and $Password) {
    # SQL Server Authentication
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $connectionString = "Server=$Instance;Database=master;User Id=$Username;Password=$PlainPassword;TrustServerCertificate=True;Encrypt=True"
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
} else {
    # Windows Authentication - use multiple connection string variations to handle SSPI issues
    $connectionString = "Server=$Instance;Database=master;Integrated Security=SSPI;TrustServerCertificate=True;Encrypt=Optional"
}

try {
    # Create SQL connection
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    
    Write-Host "Attempting to connect to: $Instance"
    if ($Username) {
        Write-Host "Using SQL Server Authentication"
    } else {
        Write-Host "Using Windows Authentication"
    }
    
    $connection.Open()
    Write-Host "Connected successfully to server: $Instance"
    
    # Check if database exists
    $checkDbCmd = $connection.CreateCommand()
    $checkDbCmd.CommandText = "SELECT database_id FROM sys.databases WHERE name = @dbname"
    $checkDbCmd.Parameters.AddWithValue("@dbname", $MyDBName) | Out-Null
    $dbExists = $checkDbCmd.ExecuteScalar()
    
    if ($dbExists) {
        Write-Host "Database '$MyDBName' already exists"
        $connection.Close()
        return
    }
    
    Write-Host "Creating database: $MyDBName"
    
    # Get default file locations
    $getPathsCmd = $connection.CreateCommand()
    $getPathsCmd.CommandText = @"
SELECT 
    ISNULL(CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260)), 
           SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)) AS DataPath,
    ISNULL(CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS NVARCHAR(260)),
           SUBSTRING(physical_name, 1, CHARINDEX(N'mastlog.ldf', LOWER(physical_name)) - 1)) AS LogPath
FROM sys.master_files 
WHERE database_id = 1 AND type = 0
"@
    
    $reader = $getPathsCmd.ExecuteReader()
    $reader.Read() | Out-Null
    $DataLoc = $reader["DataPath"].ToString()
    $LogLoc = $reader["LogPath"].ToString()
    $reader.Close()
    
    # Ensure paths end with backslash
    if (!$DataLoc.EndsWith("\")) { $DataLoc = $DataLoc + "\" }
    if (!$LogLoc.EndsWith("\")) { $LogLoc = $LogLoc + "\" }
    
    Write-Host "Data location: $DataLoc"
    Write-Host "Log location: $LogLoc"
    
    # Build file names
    $SystemFileName = "${MyDBName}_System"
    $UserFileName1 = "${MyDBName}_User1"
    $UserFileName2 = "${MyDBName}_User2"
    $UserFileName3 = "${MyDBName}_User3"
    $UserFileName4 = "${MyDBName}_User4"
    $LogFileName = "${MyDBName}_Log"
    
    # Create the database with T-SQL
    $createDbCmd = $connection.CreateCommand()
    $createDbCmd.CommandText = @"
CREATE DATABASE [$MyDBName]
ON PRIMARY 
(
    NAME = N'$SystemFileName',
    FILENAME = N'${DataLoc}${SystemFileName}.MDF',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 0
),
FILEGROUP [UserFG]
(
    NAME = N'$UserFileName1',
    FILENAME = N'${DataLoc}${UserFileName1}.NDF',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 100MB
),
(
    NAME = N'$UserFileName2',
    FILENAME = N'${DataLoc}${UserFileName2}.NDF',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 100MB
),
(
    NAME = N'$UserFileName3',
    FILENAME = N'${DataLoc}${UserFileName3}.NDF',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 100MB
),
(
    NAME = N'$UserFileName4',
    FILENAME = N'${DataLoc}${UserFileName4}.NDF',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 100MB
)
LOG ON
(
    NAME = N'$LogFileName',
    FILENAME = N'${LogLoc}${LogFileName}.LDF',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 128MB
)
"@
    
    $createDbCmd.ExecuteNonQuery() | Out-Null
    Write-Host "Database created successfully"
    
    # Set recovery model
    $recoveryCmd = $connection.CreateCommand()
    $recoveryCmd.CommandText = "ALTER DATABASE [$MyDBName] SET RECOVERY $RecoveryModel"
    $recoveryCmd.ExecuteNonQuery() | Out-Null
    Write-Host "Recovery model set to: $RecoveryModel"
    
    # Set UserFG as default filegroup
    $defaultFgCmd = $connection.CreateCommand()
    $defaultFgCmd.CommandText = "ALTER DATABASE [$MyDBName] MODIFY FILEGROUP [UserFG] DEFAULT"
    $defaultFgCmd.ExecuteNonQuery() | Out-Null
    
    # Enable mixed page allocation (always on)
    $mixedPageCmd = $connection.CreateCommand()
    $mixedPageCmd.CommandText = "ALTER DATABASE [$MyDBName] SET MIXED_PAGE_ALLOCATION ON"
    $mixedPageCmd.ExecuteNonQuery() | Out-Null
    
    # Enable Query Store (always on)
    $queryStoreCmd = $connection.CreateCommand()
    $queryStoreCmd.CommandText = @"
ALTER DATABASE [$MyDBName] SET QUERY_STORE = ON
(
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
)
"@
    $queryStoreCmd.ExecuteNonQuery() | Out-Null
    
    Write-Host "Database configuration completed (Query Store and Mixed Page Allocation enabled)"
    
    # Now query and display the database information
    $connection.ChangeDatabase($MyDBName)
    
    # Show database properties
    Write-Host "`nDatabase Properties:"
    $dbInfoCmd = $connection.CreateCommand()
    $dbInfoCmd.CommandText = @"
SELECT 
    DB_NAME() AS Name,
    @@SERVERNAME AS Parent,
    CASE WHEN is_auto_shrink_on = 1 THEN 'True' ELSE 'False' END AS AutoShrink,
    (SELECT TOP 1 backup_finish_date FROM msdb.dbo.backupset WHERE database_name = DB_NAME() ORDER BY backup_finish_date DESC) AS LastBackupDate,
    page_verify_option_desc AS PageVerify,
    recovery_model_desc AS RecoveryModel
FROM sys.databases 
WHERE name = DB_NAME()
"@
    
    $reader = $dbInfoCmd.ExecuteReader()
    $dbInfo = @()
    while ($reader.Read()) {
        $dbInfo += [PSCustomObject]@{
            Parent = $reader["Parent"]
            Name = $reader["Name"]
            AutoShrink = $reader["AutoShrink"]
            LastBackupDate = if ($reader["LastBackupDate"] -eq [DBNull]::Value) { $null } else { $reader["LastBackupDate"] }
            PageVerify = $reader["PageVerify"]
            RecoveryModel = $reader["RecoveryModel"]
        }
    }
    $reader.Close()
    $dbInfo | Format-Table -AutoSize
    
    # Show filegroups
    Write-Host "Filegroups:"
    $fgCmd = $connection.CreateCommand()
    $fgCmd.CommandText = @"
SELECT 
    DB_NAME() AS Parent,
    name AS Name,
    CASE WHEN is_default = 1 THEN 'True' ELSE 'False' END AS IsDefault,
    CASE WHEN type_desc = 'FILESTREAM_DATA_FILEGROUP' THEN 'True' ELSE 'False' END AS IsFileStream,
    CASE WHEN is_read_only = 1 THEN 'True' ELSE 'False' END AS ReadOnly
FROM sys.filegroups
ORDER BY is_default DESC, name
"@
    
    $reader = $fgCmd.ExecuteReader()
    $filegroups = @()
    while ($reader.Read()) {
        $filegroups += [PSCustomObject]@{
            Parent = $reader["Parent"]
            Name = $reader["Name"]
            IsDefault = $reader["IsDefault"]
            IsFileStream = $reader["IsFileStream"]
            ReadOnly = $reader["ReadOnly"]
        }
    }
    $reader.Close()
    $filegroups | Format-Table -AutoSize
    
    # Show data files
    Write-Host "Data Files:"
    $filesCmd = $connection.CreateCommand()
    $filesCmd.CommandText = @"
SELECT 
    fg.name AS Parent,
    f.name AS Name,
    f.size * 8 AS Size,
    CASE 
        WHEN f.max_size = -1 THEN 'None'
        WHEN f.growth = 0 THEN 'None'
        WHEN f.is_percent_growth = 1 THEN 'Percent'
        ELSE 'KB'
    END AS GrowthType,
    CASE 
        WHEN f.growth = 0 THEN 0
        WHEN f.is_percent_growth = 1 THEN f.growth
        ELSE f.growth * 8
    END AS Growth,
    f.physical_name AS FileName
FROM sys.database_files f
LEFT JOIN sys.filegroups fg ON f.data_space_id = fg.data_space_id
WHERE f.type = 0
ORDER BY f.file_id
"@
    
    $reader = $filesCmd.ExecuteReader()
    $files = @()
    while ($reader.Read()) {
        $files += [PSCustomObject]@{
            Parent = $reader["Parent"]
            Name = $reader["Name"]
            Size = $reader["Size"]
            GrowthType = $reader["GrowthType"]
            Growth = $reader["Growth"]
            FileName = $reader["FileName"]
        }
    }
    $reader.Close()
    $files | Format-Table -AutoSize
    
    # Show log files
    Write-Host "Log Files:"
    $logCmd = $connection.CreateCommand()
    $logCmd.CommandText = @"
SELECT 
    DB_NAME() AS Parent,
    name AS Name,
    size * 8 AS Size,
    CASE 
        WHEN max_size = -1 THEN 'None'
        WHEN growth = 0 THEN 'None'
        WHEN is_percent_growth = 1 THEN 'Percent'
        ELSE 'KB'
    END AS GrowthType,
    CASE 
        WHEN growth = 0 THEN 0
        WHEN is_percent_growth = 1 THEN growth
        ELSE growth * 8
    END AS Growth,
    physical_name AS FileName
FROM sys.database_files
WHERE type = 1
"@
    
    $reader = $logCmd.ExecuteReader()
    $logFiles = @()
    while ($reader.Read()) {
        $logFiles += [PSCustomObject]@{
            Parent = $reader["Parent"]
            Name = $reader["Name"]
            Size = $reader["Size"]
            GrowthType = $reader["GrowthType"]
            Growth = $reader["Growth"]
            FileName = $reader["FileName"]
        }
    }
    $reader.Close()
    $logFiles | Format-Table -AutoSize
    
    $connection.Close()
}
catch {
    Write-Error "Error: $_"
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
    throw
}
