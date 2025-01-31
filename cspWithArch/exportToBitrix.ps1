# Define variables
$folderPath = "C:\Users\smedvedev\Desktop\forExport"
$remoteMachine = "master@172.31.0.40"
$remoteFolder = '/var/www/html/bx-site/upload/1c/reports'
$sshKeyPath = "C:/Users/smedvedev/Desktop/keys/id_ed25519"
$archFolder = Join-Path -Path $folderPath -ChildPath "Arch"
$logFolder = Join-Path -Path $folderPath -ChildPath "Logs"

# Create Logs folder if it doesn't exist
if (-Not (Test-Path -Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory
}

# Create log file with the current timestamp
$logFilePath = Join-Path -Path $logFolder -ChildPath "$(Get-Date -Format yyyy.MM.dd).log"
$logContent = @()

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $logContent += "$(Get-Date -Format yyyy.MM.dd-HH.mm.ss) - $Message"
    $logContent | Out-File -FilePath $logFilePath -Append
}

# Redirect all error output to the log
$ErrorActionPreference = "Stop"
$error.Clear()

# Check if the folder contains any files
$files = Get-ChildItem -Path $folderPath -File
if ($files.Count -eq 0) {
    Log-Message "No files found in the folder."
    exit
}

# Process each file in the folder
foreach ($file in $files) {
    $filePath = $file.FullName

    try {
        # Create SHA-256 checksum for the file
        $checksum = Get-FileHash -Algorithm SHA256 -Path $filePath
        $checksumValue = $checksum.Hash

        # Format the file path for SCP
        $formattedFilePath = '"{0}"' -f $filePath.Replace('\', '/')

        # Copy file to remote machine using SCP (ensure you have SCP installed and configured)
        $scpCommand = @("-i", "$sshKeyPath", $formattedFilePath, "${remoteMachine}:$remoteFolder")
        Log-Message "Executing SCP command: $($scpCommand -join ' ')"
        $process = Start-Process -FilePath "scp" -ArgumentList $scpCommand -NoNewWindow -PassThru -Wait
        $process.WaitForExit()
        Log-Message "SCP command executed. Exit code: $($process.ExitCode)"
        if ($process.ExitCode -ne 0) {
            Log-Message "SCP command failed to upload the file $filePath."
            continue
        }

        # Download file back from remote machine
        $remoteFilePath = '"{0}"' -f ($remoteFolder+"/"+("'{0}'" -f $($file.Name)))
        $downloadPath = '"{0}"' -f (Join-Path -Path  $folderPath -ChildPath "downloaded_$($file.Name)")
        $scpCommand = @("-i", $sshKeyPath, "-T", "${remoteMachine}:$remoteFilePath", $downloadPath)
        Log-Message "Executing SCP command: $($scpCommand -join ' ')"
        $process = Start-Process -FilePath "scp" -ArgumentList $scpCommand -NoNewWindow -PassThru -Wait
        $process.WaitForExit()
        Log-Message "SCP command executed. Exit code: $($process.ExitCode)"
        if ($process.ExitCode -ne 0) {
            Log-Message "SCP command failed to download the file $remoteFilePath."
            continue
        }

        # Check if the downloaded file exists
        $downloadPath = $($downloadPath -replace '"', '')
        if (-Not ( Test-Path -Path $($downloadPath) )) {
            Log-Message "Downloaded file $downloadPath does not exist."
            continue
        }
        
        # Create SHA-256 checksum for the downloaded file
        $downloadedChecksum = Get-FileHash -Algorithm SHA256 -Path $downloadPath
        $downloadedChecksumValue = $downloadedChecksum.Hash

        # Compare checksums
        if ($checksumValue -eq $downloadedChecksumValue) {
            Remove-Item -Path $downloadPath
            if (!(Test-Path -Path $archFolder)) {
                New-Item -Path $archFolder -ItemType Directory
            }
            Move-Item -Path $filePath -Destination $archFolder
            Log-Message "File $filePath processed and moved to 'Arch' folder."
        } else {
            Log-Message "Checksum mismatch for file $filePath. File was not processed."
        }
    } catch {
        Log-Message "An error occurred: $_"
    }

    # Write log content to log file
    $logContent | Out-File -FilePath $logFilePath -Append
}

# Write any remaining log content
$logContent | Out-File -FilePath $logFilePath -Append
