Import-Module SQLServer

$Instance   = "WINDC\DEFAULT"
$MyDBName   = "TestDB"

# get the database
$MyDB = Get-Item "SQLSERVER:\SQL\$Instance\Databases\$MyDBName"
 
$MyDB.Drop()





[CmdletBinding()]
param 
(
[Parameter(Mandatory = $True)][string]$Instance,
[Parameter(Mandatory = $True)][string]$MyDBName
)

Import-Module SQLServer

# get the database
$MyDB = Get-Item "SQLSERVER:\SQL\$Instance\Databases\$MyDBName"
 
$MyDB.Drop()
