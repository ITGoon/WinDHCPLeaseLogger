# This first section exports a CSV of your DHCP leases
# Set your DHCP server by full FQDN name
Get-DhcpServerv4Scope -ComputerName FullFQDN.Of.YourDHCPServer | Get-DhcpServerv4Lease -ComputerName FullFQDN.Of.YourDHCPServer | select Hostname, ClientId, IPAddress, LeaseExpiryTime | Export-csv -path "C:\exportdir\psdhcpleases.csv"

# Set your database information here, table must be dbo.tablename
# The server can be referenced by just the name instead of the full FQDN
$database = 'DatabaseName'
$server = 'DatabaseServerName'
$table = 'dbo.YourTable'

# Use this section to cut off your Windows domain name from the end of the hostnames
((Get-Content -path C:\exportdir\psdhcpleases.csv -Raw) -replace '.YourDomain.Name','') | Set-Content -Path C:\exportdir\psdhcpleases.csv

# This section imports the CSV file to your Microsoft SQL Database
Import-CSV C:\exportdir\psdhcpleases.csv | ForEach-Object {Invoke-Sqlcmd `
  -Database $database -ServerInstance $server `
  -Query "insert into $table(hostname, mac, ip) VALUES ('$($_.Hostname)','$($_.ClientId)','$($_.IPAddress)')"
  }
