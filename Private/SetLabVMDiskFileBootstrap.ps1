function SetLabVMDiskFileBootstrap {

<#
    .SYNOPSIS
        Copies a the Lability bootstrap file to a VHD(X) file.
#>

    [CmdletBinding()]
    param (
        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VhdDriveLetter,

        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootstrap,

        ## CoreCLR
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;
        WriteVerbose -Message ($localized.AddingBootStrapFile -f $bootStrapPath);
        if ($CustomBootStrap) {

            SetBootStrap -Path $bootStrapPath -CustomBootStrap $CustomBootStrap -CoreCLR:$CoreCLR;
        }
        else {

            SetBootStrap -Path $bootStrapPath -CoreCLR:$CoreCLR;
        }

        $setupCompleteCmdPath = '{0}:\Windows\Setup\Scripts' -f $vhdDriveLetter;
        WriteVerbose -Message ($localized.AddingSetupCompleteCmdFile -f $setupCompleteCmdPath);
        SetSetupCompleteCmd -Path $setupCompleteCmdPath -CoreCLR:$CoreCLR;

    } #end process

}

