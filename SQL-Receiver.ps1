<#  
.SYNOPSIS  
    Inserts data into a SQL Database
.DESCRIPTION  
    Calls to this module with a valid INSERT query will be passed to the database.
.NOTES  
    File Name  : Run-PowerSQL 
    Author     : Mitchell Beare - Mitchellbeare@gmail.com  
    Requires   : PowerShell V4 - MySQL .NET Connector v6.8.8  
.LINK  
#>

Param(
  [Parameter(
  Mandatory = $true,
  ParameterSetName = '',
  ValueFromPipeline = $true)]
  [string]$query,
  [string]$user,
  [string]$pass,
  [string]$database,
  [string]$SQLHost
  )

    # Load MySQL .NET Connector Objects 
    [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data") 
 
    # Open Connection 
    $connStr = "server=" + $SQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database="+$database+";Pooling=FALSE;sslmode=none" 
    try {
        $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr) 
        $conn.Open()
    } catch [System.Management.Automation.PSArgumentException] {
        Write-Output "Unable to connect to MySQL server, do you have the MySQL connector installed..?"
        Write-Output $_
        Exit
    } catch {
        Write-Output "Unable to connect to MySQL server..."
        Write-Output $_.Exception.GetType().FullName
        Write-Output $_.Exception.Message
        exit
    }
    Write-Output "Connected to MySQL database $SQLHost\$database"

  $command = $conn.CreateCommand()                  # Create command object
  $command.CommandText = $query                     # Load query into object
  $RowsInserted = $command.ExecuteNonQuery()        # Execute command
  $command.Dispose()                                # Dispose of command object
  if ($RowsInserted) { 
    return $RowInserted 
  } else { 
    return $false 
  } 
