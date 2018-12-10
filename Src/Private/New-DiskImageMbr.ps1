function New-DiskImageMbr {
<#
    .SYNOPSIS
        Create a new MBR-formatted disk image.
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

        Write-Verbose -Message ($localized.CreatingDiskPartition -f 'Windows');
        $osPartition = Storage\New-Partition -DiskNumber $Vhd.DiskNumber -UseMaximumSize -MbrType IFS -IsActive |
            Storage\Add-PartitionAccessPath -AssignDriveLetter -PassThru |
                Storage\Get-Partition;
        Write-Verbose -Message ($localized.FormattingDiskPartition -f 'Windows');
        [ref] $null = Storage\Format-Volume -Partition $osPartition -FileSystem NTFS -Force -Confirm:$false;

        Start-ShellHWDetectionService;

    } #end proces
} #end function
