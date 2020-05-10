# PowerShell SQLite DB example, muchos gracias to C. Nichols mohawke@gmail.com
# https://www.darkartistry.com/2019/08/create-insert-and-query-sqlite-with-powershell/

# DOWNLOAD THIS FILE
#https://system.data.sqlite.org/downloads/1.0.112.0/sqlite-netFx46-binary-x64-2015-1.0.112.0.zip

# Unzip it
# Expand-Archive -Path sqlite-netFx46-binary-x64-2015-1.0.112.0.zip -DestinationPath C:\temp
# copy c:\temp\*dll c:\Suricata

# Unblock-File -Path c:\Suricata\System.Data.SQLite.dll

Add-Type -Path "c:\Suricata\System.Data.SQLite.dll" 
Function createDataBase([string]$DBPath){
    If (!(Test-Path $DBPath)) {
        $CONN = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $CONN.ConnectionString = "Data Source=$DBPath"
        $CONN.Open()
        $CMD = $CONN.CreateCommand()
        $CMD.Dispose()
        $CONN.Close()
        Write-Output "Create database: Ok"
    } Else {write-output "DB Exists: Ok"}
}
# ******** MAIN ********
write-output ""
write-output ""
write-output "Main"
write-output "--------------------------"
$DBPath = "c:\Suricata\firstoctet.sqlite"
write-output "calling createDatabase"
write-output "--------------------------"
createDataBase $DBPath  # Function call
write-output "--------------------------"
write-output "Main END"


# Awesome GUI for sqlite
# https://sqlitebrowser.org/
