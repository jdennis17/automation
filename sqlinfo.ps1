# Run on server where SQL is installed

# Collect OS information on each remote servr
$os = Get-ComputerInfo

# Display the 'Developer' edition
$sqlEdition = Invoke-Sqlcmd -ServerInstance "localhost" -Query "SELECT SERVERPROPERTY('Edition') AS Edition"
$sqlEditionString = $sqlEdition[0]


# Execute the sql query to get version info
$versionInfo = Invoke-Sqlcmd -ServerInstance "localhost" -Query "SELECT @@VERSION"

# Extract the version string information from the first row - only row that contains data; this process changes the type to a String from a data row which doesn't work with regex
$versionString = $versionInfo[0]

<# Select the text we need from the version string - searches for the pattern 'Microsoft SQL Server' followed by a 4-digit number which is the version number we want.
.Matches - This holds the matching object(s). In this case, there is only one match, which is "SQL Server 2019".
.Value -  The .Value property gives you the actual string that was matched by the pattern. So, in this case, Matches.Value will return "Microsoft SQL Server 2019".
#>
$versionText = ($versionString | Select-String -Pattern "Microsoft SQL Server \d{4}").Matches.Value


# Create a custom object to store the server info
        $sqlVersionInfo = [PSCustomObject]@{
            'Server Name'            = $os.CsName
            'Operating System' = $os.WindowsProductName
            'SQL Version'          = $versionText
            'SQL Edition'  = $sqlEditionString

        }

        $sqlVersionInfo

