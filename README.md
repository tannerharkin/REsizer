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
   $uri='https://raw.githubusercontent.com/tannerharkin/REsizer/main/REsizer.ps1';$hash='968EDB783501BEB3B7AD980A6F4343AB3FED60CD295C588D3031217A6147651E';if((Get-FileHash -Algorithm SHA256 -InputStream (iwr $uri -UseBasicParsing).RawContentStream).Hash -eq $hash){iex (iwr $uri -UseBasicParsing).Content}else{Write-Error 'Hash mismatch'}
   ```

   <details>
       <summary><strong>Woah! That's a lot longer than the usual download and run one-liner, what is all that?</strong></summary>
       <p>This command ensures that only an approved version of the script is executed, providing a security measure against unauthorized changes or potential hostile takeovers of the script repository (as unlikely as that would be). Here's what each part of the command does:</p>
       <ul>
           <li><strong>Set Variables:</strong> Sets <code>$uri</code> for the script URL and <code>$hash</code> for the expected SHA256 hash.</li>
           <li><strong>Download the Script:</strong> Uses <code>Invoke-WebRequest (iwr)</code> to download the script once with <code>-UseBasicParsing</code>, which is necessary for older versions of PowerShell, and most Windows Server installs (we still don't recommend using REsizer on server!).</li>
           <li><strong>Store Script Content:</strong> Stores the downloaded script content in a variable, reducing the risk of the script being tampered with between download and execution (mitigates a theoretical TOCTOU bug if we were to fetch twice).</li>
           <li><strong>Hash Verification:</strong>
               <ul>
                   <li><code>Get-FileHash</code> computes the SHA256 hash of the stored script's content stream directly.</li>
                   <li>Compares this computed hash with the expected hash, ensuring script integrity.</li>
               </ul>
           </li>
           <li><strong>Conditional Execution:</strong>
               <ul>
                   <li>If the hashes match, the script is executed using <code>Invoke-Expression (iex)</code>.</li>
                   <li>If there's a hash mismatch, an error is issued using <code>Write-Error</code>, preventing the execution of a potentially compromised script.</li>
               </ul>
           </li>
       </ul>
       <p>This approach ensures you always run the approved version of your script. If the script's content at the specified URL changes without a corresponding update to the expected hash in your command, the hash check will fail, and an error will be raised. This is particularly important if there's a potential hostile takeover of the repository hosting the script, as it safeguards against executing tampered code.</p>
       <p><strong>TL;DR</strong> This is implemented as a security measure.</p>
   </details>

4. **Follow On-Screen Prompts**: The script will guide you through the necessary steps, asking for confirmations before making any changes.

## Important Considerations
- Modifying disk partitions can lead to data loss. Follow all prompts carefully and ensure you understand the changes being made.
- This is only intended for simple systems with standard partition layouts.
- Consult a professional if you encounter errors or have doubts about your system's partition layout.
