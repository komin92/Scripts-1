<#  
.SYNOPSIS  
    Uses MySql .Net Connector to interface with a SQL database
.DESCRIPTION  
    ExecuteNonQuery - Used for queries that don't return any real information, such as an INSERT, UPDATE, or DELETE.
      So, to insert records into a table 
      $query = "INSERT INTO test (id, name, age) VALUES (1, 'Joe', 33)" 
      $Rows = Execute-SQLNonQuery $conn $query 
      Write-Host $Rows " inserted into database"

    ExecuteReader - Used for normal queries that return multiple values. Results need to be received into MySqlDataReader object.
      So, to produce a table of results from a query...
      $query = "SELECT * FROM subnets;"
      $result = Execute-SQLReader $query
      Write-Host ("Found " + $result.rows.count + " rows...")
      $result | Format-Table
      
    ExecuteScalar - Used for normal queries that return a single. The result needs to be received into a variable.
      So to return a result to a value
      $query = "Select name FROM clients "
      $result = Execute-SQLScalar $query
      Write-Host " You most recent client was $result"
.NOTES  
    File Name  : Run-PowerSQL 
    Author     : Mitchell Beare - Mitchellbeare@gmail.com  
    Requires   : PowerShell V4 - MySQL .NET Connector v6.8.8  
.LINK  
  
#>

#Configure Database variables here
$user = 'root'
$pass = 'TheM@7r1x!'
$database = 'undurbadb'
$SQLHost = '10.113.92.2'

#Enter your SQL Query here read description for help.
Function Main{
 Connect-MySQL $user $pass $SQLHost $database
 $query = ""

}


#Do not edit below here ===================
Function Connect-MySQL([string]$user, [string]$pass, [string]$SQLHost, [string]$database) { 
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

    return $conn 
} # End Connect-SQL
Function Execute-SQLNonQuery($conn, [string]$query) { 
  $command = $conn.CreateCommand()                  # Create command object
  $command.CommandText = $query                     # Load query into object
  $RowsInserted = $command.ExecuteNonQuery()        # Execute command
  $command.Dispose()                                # Dispose of command object
  if ($RowsInserted) { 
    return $RowInserted 
  } else { 
    return $false 
  } 
}  # End Execute-SQLNonQuery
Function Execute-SQLReader([string]$query) { 
  # NonQuery - Insert/Update/Delete query where no return data is required
  $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connMySQL)    # Create SQL command
  $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($cmd)      # Create data adapter from query command
  $dataSet = New-Object System.Data.DataSet                                    # Create dataset
  $dataAdapter.Fill($dataSet, "data")                                          # Fill dataset from data adapter, with name "data"              
  $cmd.Dispose()
  return $dataSet.Tables["data"]                                               # Returns an array of results
}
Function Execute-SQLScalar([string]$query) {
    # Scalar - Select etc query where a single value of return data is expected
    $cmd = $SQLconn.CreateCommand()                                             # Create command object
    $cmd.CommandText = $query                                                   # Load query into object
    $cmd.ExecuteScalar()                                                        # Execute command
}#End Execute-SQLScalar

Main