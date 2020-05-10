# PowerShell SQLite DB example, muchos gracias to C. Nichols mohawke@gmail.com
# https://www.darkartistry.com/2019/08/create-insert-and-query-sqlite-with-powershell/

# DOWNLOAD THIS FILE
#https://system.data.sqlite.org/downloads/1.0.112.0/sqlite-netFx46-binary-x64-2015-1.0.112.0.zip

# Unzip it
# Expand-Archive -Path sqlite-netFx46-binary-x64-2015-1.0.112.0.zip -DestinationPath C:\temp
# copy c:\temp\*dll c:\Suricata

# Unblock-File -Path c:\Suricata\System.Data.SQLite.dll

cls
##rm c:\Suricata\firstoctet2.sqlite
Add-Type -Path "c:\Suricata\System.Data.SQLite.dll" 
Function createDataBase([string]$db){
    If (!(Test-Path $db)) {
        $CONN = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $CONN.ConnectionString = "Data Source=$db"
        $CONN.Open()
        # TEXT as ISO8601 strings (&#039;YYYY-MM-DD HH:MM:SS.SSS&#039;)
        # ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, INSERT NULL to increment.
        $createTableQuery = "CREATE TABLE netstatdemo (
                                    ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                    Timestamp         TEXT    NULL,
                                    Protocol          TEXT    NULL,
                                    LocalAddress      TEXT    NULL,
                                    ForeignAddress    TEXT    NULL,
                                    State             TEXT    NULL,
                                    PID               TEXT    NULL
                                    );"
        #$createUniqueIndex = "CREATE UNIQUE INDEX netstatdemo_idx ON netstatdemo(COLUMNS...);"
        $CMD = $CONN.CreateCommand()
        $CMD.CommandText = $createTableQuery
        $CMD.ExecuteNonQuery()
        #$CMD.CommandText = $createUniqueIndex
        #$CMD.ExecuteNonQuery()
 
        $CMD.Dispose()
        $CONN.Close()
        $CMD = $CONN.CreateCommand()
        $CMD.Dispose()
        $CONN.Close()
        Write-Output "Create database and table: Ok"
    } Else {write-output "DB Exists: Ok"}
}


Function insertDatabase([string]$db, [System.Collections.ArrayList]$rows) {
    Try {
        If (Test-Path $db) {
            $CONN = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $CONN.ConnectionString = "Data Source=$db"
            $CONN.Open()
            $CMD = $CONN.CreateCommand()
            #$Counter = 0
            ForEach($row in $rows) {
                #Write-Output $row
                $timestamp = $row.Split(",")[0]  
                $protocol = $row.Split(",")[1]  
                $localaddress = $row.Split(",")[2]
                $foreignaddress = $row.Split(",")[3]
                $state = $row.Split(",")[4]
                $procid = $row.Split(",")[5] #  *** $pid is RESERVED, 1 hour lost forever debugging****

                $sql = "INSERT INTO netstatdemo (Timestamp,Protocol,LocalAddress,ForeignAddress,State,PID) "
                $sql += "VALUES($timestamp,$protocol,$localaddress,$foreignaddress,$state,$procid);"
                #Write-Output $sql
 
                $CMD.CommandText = $sql
                $suppressOutput = $CMD.ExecuteNonQuery()
            }

            $CMD.Dispose()
            $CONN.Close()
            Write-Output "Inserted records successfully: Ok"
        } Else {
            Write-Output "Unable to find database: Insert Failed"
        }
 
    } Catch {
        Write-Output "Unable to insert into database: Error"
    }
}
# ******** MAIN ********


write-output ""
write-output ""
write-output "Main"
write-output "--------------------------"
$DBPath = "c:\Suricata\firstoctet4.sqlite"
write-output "calling createDatabase"
createDataBase $DBPath  # Function call

#---------------------------------------------------------
write-output "calling netstat -ano"
$netstat_ano = netstat -ano
$datatmp = $netstat_ano | ConvertFrom-String -PropertyName null, Protocol, 
LocalAddress, ForeignAddress, State, PID | 
Select-Object -First 1000 -Property @{Name='timestamp';Expression={Get-Date -Format o}}, 
Protocol, LocalAddress, ForeignAddress, State, PID  |  where PID -ne $null | 
ConvertTo-Csv
#$datatmp

#throw away the headers
$tmpheader1, $tmpheader2, $tmpheader3, $data = $datatmp 
write-output "calling insertDatabase"
insertDatabase $DBPath $data
write-output "--------------------------"
write-output "Main END"

