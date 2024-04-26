 # Function to get SQL Server instances
function Get-SQLInstances {
    $sqlInstances = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | ForEach-Object {
        $instanceName = $_
        $instanceVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL").$instanceName
        $instancePath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceVersion\$instanceName"
        $instanceEdition = (Get-ItemProperty $instancePath).Edition
        $instanceVersion = (Get-ItemProperty $instancePath).VersionString
        [PSCustomObject]@{
            Name = $instanceName
            Edition = $instanceEdition
            Version = $instanceVersion
        }
    }
    return $sqlInstances
}

# Get Windows Server edition and version
$windowsEdition = (Get-WmiObject -Class Win32_OperatingSystem).Caption
$windowsVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version

# Get hostname and IP addresses
$hostname = (Get-WmiObject Win32_ComputerSystem).Name
$ipAddresses = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }).IPAddress

# Get SQL Server instances
$sqlInstances = Get-SQLInstances

# Specify the file path for the report
$reportFilePath = "C:\temp\server_report.txt"

# Create the report content in table format
$reportContent = @"
| Windows Server Edition | Windows Server Version | Hostname | IP Addresses | SQL Server Instances |
|------------------------|-----------------------|----------|--------------|----------------------|
| $windowsEdition        | $windowsVersion       | $hostname | $($ipAddresses -join ', ') |                      |

SQL Server Instances:
$($sqlInstances | Format-Table | Out-String)
"@

# Append the report to the specified file
$reportContent | Out-File -FilePath $reportFilePath -Append

Write-Host "Report appended to $reportFilePath"
 
