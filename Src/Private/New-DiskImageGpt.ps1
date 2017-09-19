function New-DiskImageGpt {
<#
    .SYNOPSIS
        Create a new GPT-formatted disk image.
#>
    [CmdletBinding()]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd # Microsoft.Vhd.PowerShell.VirtualHardDisk
    )
    process {

        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-ShellHWDetectionService;

        Write-Verbose -Message ($localized.CreatingDiskPartition -f 'EFI');
        $efiPartition = New-Partition -DiskNumber $Vhd.DiskNumber -Size 250MB -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' -AssignDriveLetter;
        Write-Verbose -Message ($localized.FormattingDiskPartition -f 'EFI');
        New-DiskPartFat32Partition -DiskNumber $Vhd.DiskNumber -PartitionNumber $efiPartition.PartitionNumber;

        Write-Verbose -Message ($localized.CreatingDiskPartition -f 'MSR');
        [ref] $null = New-Partition -DiskNumber $Vhd.DiskNumber -Size 128MB -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}';

        Write-Verbose -Message ($localized.CreatingDiskPartition -f 'Windows');
        $osPartition = New-Partition -DiskNumber $Vhd.DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -AssignDriveLetter;
        Write-Verbose -Message ($localized.FormattingDiskPartition -f 'Windows');
        [ref] $null = Format-Volume -Partition $osPartition -FileSystem NTFS -Force -Confirm:$false;

        Start-ShellHWDetectionService;

    } #end process
} #end function
