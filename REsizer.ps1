<#
.SYNOPSIS
This PowerShell script addresses the KB5028997 (Windows Update error 0x80070643) WinRE issue automatically for simple systems.

.DESCRIPTION
This script automates the process of checking, resizing, and configuring the Windows RE partition. It checks the disk layout, shrinks the OS partition, removes the old Windows RE partition, and creates a new one with proper formatting to address KB5028997 (Windows Update error 0x80070643).

.NOTICE
This script is provided 'as is', with no guarantees or warranties of any kind, implied or otherwise. It is not recommended you use this software with systems that have unusual partition layouts.

.LICENSE
Copyright 2024 Tanner Harkin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.T NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

# Print the disclaimer
Write-Output "DISCLAIMER: This script is provided 'as is' with no guarantees or warranties, either expressed or implied. Use at your own risk."
Write-Output ""
Write-Output "IMPORTANT: Before running this script, please ensure the following criteria are met:"
Write-Output "- You are running this script on a system with a single physical disk configured as the boot device."
Write-Output "- The disk uses a standard partition layout with the Windows operating system installed."
Write-Output "- There are no other operating systems installed on this disk."
Write-Output "- You have backups of all important data on this disk."
Write-Output "- You have at least 250MB of free disk space on your OS partition."
Write-Output ""
Write-Output "WARNING: This script will perform operations that could result in ALL data on this computer being lost."
Write-Output ""
$confirmation = Read-Host "Are you prepared to irrevocably lose ALL data on this computer should something go wrong? If not, STOP NOW and consult a computer repair shop. 

Type 'yes' to continue or 'no' to stop"

$abortMessage = "Operation canceled by user. No changes were made to the disk."
if ($confirmation -ne "yes") {
    Write-Output $abortMessage
    exit
}

# Check Windows RE status
$winREInfo = reagentc /info | Out-String
Write-Output "Windows RE status:"
Write-Output $winREInfo

$doubleCheck = Read-Host "Have you checked the Windows RE status and wish to proceed? It should say 'Enabled' for the status.

Type 'yes' to continue or 'no' to stop"

if ($doubleCheck -ne "yes") {
    Write-Output $abortMessage
    exit
}

try {
    # Regex to extract the disk and partition number
    if ($winREInfo -match '(?m)^\s*Windows\s+RE\s+location:\s+\\\\\?\\GLOBALROOT\\device\\harddisk(\d+)\\partition(\d+)\\') {
        $diskIndex = $matches[1]
        $recoveryPartitionIndex = $matches[2]
        $osPartitionIndex = $matches[2] - 1  # Yes, this is an assumption, and that's why we ask for a human sanity check.

        # Retrieve partition and volume information
        $recoveryPartition = Get-Partition -DiskNumber $diskIndex -PartitionNumber $recoveryPartitionIndex
        $osPartition = Get-Partition -DiskNumber $diskIndex -PartitionNumber $osPartitionIndex

        $driveLetter = if ($osPartition.DriveLetter) { "($($osPartition.DriveLetter): drive)" } else { "(no drive letter)" }
        $label = if ($recoveryPartition.Type) { "($($recoveryPartition.Type))" } else { "(unknown)" }

        Write-Output ""
        Write-Output "Identified Disk Index: $diskIndex"
        Write-Output "Identified Recovery Partition Index: $recoveryPartitionIndex"
        Write-Output "Recovery Partition Size: $($recoveryPartition.Size / 1MB -as [int])MB (if this is larger than 1024MB, abort!)"

        # Confirm details with user
        Write-Output ""
        $confirmationMessage = "Windows RE was identified as being at Disk $diskIndex $driveLetter, Partition $recoveryPartitionIndex $label.
		
		This is your last chance to abort. As a human, does this seem correct and should we proceed? (yes/no)"
        $doubleCheck = Read-Host $confirmationMessage
        if ($doubleCheck -ne "yes") {
            Write-Output $abortMessage
            exit
        }
    } else {
        throw "Failed to parse Windows RE location. No changes were made to your disk, but you should consult a professional computer technician."
    }
} catch {
    Write-Output "An error occurred: $_"
    exit
}

# Check if the available space on the OS partition is at least 250MB
if ([math]::Round(($osPartition.Size - $osPartition.UsedSize) / 1MB, 2) -lt 250) {
    Write-Output "Insufficient free space on the OS partition detected. At least 250MB of free space is required. No changes were made to your disk."
    exit
}

# Disable WinRE
reagentc /disable
#Debug: Write-Output "What-If: Disabled recovery."

# Begin disk operations using diskpart
$diskpartScript = @"
select disk $diskIndex
select partition $osPartitionIndex
shrink desired=250 minimum=250
select partition $recoveryPartitionIndex
delete partition override
create partition primary
format quick fs=ntfs label="Windows RE tools"

"@ 

# Set partition special flag based on disk format
$isGPT = (Get-Disk -Number $diskIndex).PartitionStyle -eq "GPT"
if ($isGPT) {
    $diskpartScript += "gpt attributes=0x8000000000000001"
} else {
    $diskpartScript += "set id=27"
}

diskpart /s $diskpartScript
#Debug: Write-Output "What-If: Running script $diskpartScript"

# Re-enable WinRE
reagentc /enable
#Debug: Write-Output "What-If: Enabled recovery"

Write-Output "Complete!"
