# Define the mapped network drive path
$networkDrive = "Z:\"
# Define a temporary file name for testing
$tempFileName = "temp_test_file.dat"
# Define the full path for the temporary file on the desktop
$tempFile = "C:\Users\zobai\Desktop\$tempFileName"
# Define the size of the test file (in MB)
$fileSizeMB = 1000

# Create the test file with random data
try {
    $bytesToWrite = 1MB * $fileSizeMB
    $randomData = New-Object byte[] $bytesToWrite
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($randomData)
    [System.IO.File]::WriteAllBytes($tempFile, $randomData)
} catch {
    Write-Host "Error creating test file: $_"
    exit
}

# Measure write speed
try {
    $writeStartTime = Get-Date
    Copy-Item -Path $tempFile -Destination (Join-Path $networkDrive $tempFileName) -ErrorAction Stop
    $writeEndTime = Get-Date
} catch {
    Write-Host "Error during write operation: $_"
    # Cleanup and exit on error
    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    exit
}

# Measure read speed
try {
    $readStartTime = Get-Date
    Copy-Item -Path (Join-Path $networkDrive $tempFileName) -Destination $tempFile -ErrorAction Stop
    $readEndTime = Get-Date
} catch {
    Write-Host "Error during read operation: $_"
    # Cleanup and exit on error
    Remove-Item -Path (Join-Path $networkDrive $tempFileName) -ErrorAction SilentlyContinue
    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    exit
}

# Clean up test files
try {
    Remove-Item -Path (Join-Path $networkDrive $tempFileName) -ErrorAction Stop
    Remove-Item -Path $tempFile -ErrorAction Stop
} catch {
    Write-Host "Error during cleanup: $_"
}

# Calculate speeds
$writeDuration = ($writeEndTime - $writeStartTime).TotalSeconds
$readDuration = ($readEndTime - $readStartTime).TotalSeconds

$writeSpeed = [math]::Round($fileSizeMB / $writeDuration, 2)
$readSpeed = [math]::Round($fileSizeMB / $readDuration, 2)

# Output results
Write-Host "Write Speed: $writeSpeed MB/s"
Write-Host "Read Speed: $readSpeed MB/s"
