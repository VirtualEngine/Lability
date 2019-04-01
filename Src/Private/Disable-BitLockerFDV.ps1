function Disable-BitLockerFDV {
<#
    .SYNOPSIS
        Disables BitLocker full disk write protection (if enabled on the host system)
#>
    [CmdletBinding()]
    param ( )
    process {

        if ($fdvDenyWriteAccess) {

            Write-Verbose -Message $localized.DisablingBitlockerWriteProtection
            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess' -Value 0;
        }

    } #end process
} #end function
