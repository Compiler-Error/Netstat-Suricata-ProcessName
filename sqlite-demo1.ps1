# PowerShell SQLite DB example, muchos gracias to C. Nichols mohawke@gmail.com
# https://www.darkartistry.com/2019/08/create-insert-and-query-sqlite-with-powershell/

# DOWNLOAD THIS FILE
#https://system.data.sqlite.org/downloads/1.0.112.0/sqlite-netFx46-binary-x64-2015-1.0.112.0.zip

# Expand-Archive -Path sqlite-netFx46-binary-x64-2015-1.0.112.0.zip -DestinationPath C:\temp
# copy System.Data.SQLite.dll c:\Suricata

# Unblock-File -Path c:\Suricata\System.Data.SQLite.dll

Add-Type -Path "c:\Suricata\System.Data.SQLite.dll" 
$DBPath = "c:\Suricata\firstoctet.sqlite"
Function createDataBase([string]$db){
    If (!(Test-Path $db)) {
        $CONN = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $CONN.ConnectionString = "Data Source=$db"
        $CONN.Open()
        $CMD = $CONN.CreateCommand()
        $CMD.Dispose()
        $CONN.Close()
        Write-Output "Create database and table: Ok"
    } Else {Log-It "DB Exists: Ok"}
}