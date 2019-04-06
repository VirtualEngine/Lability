function Assert-BitLockerFDV {
<#
    .SYNOPSIS
        Enables BitLocker full disk write protection (if enabled on the host system)
#>
    [CmdletBinding()]
    param ( )
    process {

        if ($fdvDenyWriteAccess) {

            Write-Verbose -Message $localized.EnablingBitlockerWriteProtection
            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess' -Value 1
        }

    } #end process
} #end function
