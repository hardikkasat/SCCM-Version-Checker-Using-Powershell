# Define the path to the Notepad file with server names
$serverListPath = "C:\servers.txt"     # Replace the path according to your need

# Read the server names from the file
$servers = Get-Content -Path $serverListPath

# Create an array to store the results
$results = @()

# Loop through each server
foreach ($server in $servers) {
    try {
        # Test if WinRM is available on the server
        $winrmTest = Test-WSMan -ComputerName $server -ErrorAction Stop

        if ($winrmTest) {
            # If the server is reachable, attempt to retrieve the SCCM client version
            $clientVersion = Invoke-Command -ComputerName $server -ScriptBlock {
                # Get the SCCM client version from the WMI class
                $client = Get-WmiObject -Namespace "ROOT\CCM" -Class "SMS_Client"
                $client.ClientVersion
            }

            # Store the result in the array
            $results += [PSCustomObject]@{
                ServerName   = $server
                ClientVersion = $clientVersion
            }
        }
    }
    catch {
        # Handle any errors that occur during the query, including WinRM issues
        $results += [PSCustomObject]@{
            ServerName   = $server
            ClientVersion = "Error: WinRM connection failed - $($_.Exception.Message)"
        }
    }
}

# Output the results to the console
$results | Format-Table -AutoSize

# Optionally, export the results to a CSV file
$results | Export-Csv -Path "C:\SCCM_ClientVersions.csv" -NoTypeInformation       # Replace the path according to your need
