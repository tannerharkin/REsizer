# REsizer: WinRE Resizer Script

![REsizer Logo](images/logo.png)

REsizer is a PowerShell script designed to automate the resizing and configuration of the Windows Recovery Environment (WinRE) as per [KB5028997](https://support.microsoft.com/en-us/topic/kb5028997-400faa27-9343-461c-ada9-24c8229763bf) to address Windows Update error `0x80070643` when installing the WinRE update. This script is only designed for standard Windows installs.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Important Considerations](#important-considerations)

## Introduction
This PowerShell script manages the Windows RE partition by shrinking the primary OS partition, deleting the old Windows RE partition, and creating a new one to ensure that system recovery mechanisms function correctly post-update.

**Disclaimer:** THIS SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. Use at your own risk!

## Prerequisites
Ensure your system meets the following before running REsizer:
- **System Layout**: Single disk with a standard partition layout.
- **Operating System**: Windows 10. No other operating systems installed.
- **Administrative Rights**: The script must be run as an Administrator.
- **Data Backup**: Backup all important data on the disk, assume this script will wipe your computer.
- **Free Disk Space**: At least 250MB of space must be free in the OS partition.

## Usage
To use REsizer, follow these steps:
1. **Open PowerShell as an Administrator (right-click, Run as Administrator).**
2. **Set Execution Policy**: Run `Set-ExecutionPolicy Bypass` and press <kbd>Y</kbd> at the prompt.
3. **Execute the REsizer Script**:

   ```powershell
   iwr https://raw.githubusercontent.com/tannerharkin/REsizer/main/REsizer.ps1 | iex
   ```

4. **Follow On-Screen Prompts**: The script will guide you through the necessary steps, asking for confirmations before making any changes.

## Important Considerations
- Modifying disk partitions can lead to data loss. Follow all prompts carefully and ensure you understand the changes being made.
- This is only intended for simple systems with standard partition layouts.
- Consult a professional if you encounter errors or have doubts about your system's partition layout.
