function Set-LabVMDiskFileBootstrap {
<#
    .SYNOPSIS
        Copies a the Lability bootstrap file to a VHD(X) file.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $VhdDriveLetter,

        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootstrap,

        ## CoreCLR
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom/replacement shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultShell,

        ## WSMan maximum envelope size
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Int32] $MaxEnvelopeSizeKb = 1024,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;
        Write-Verbose -Message ($localized.AddingBootStrapFile -f $bootStrapPath);
        $setBootStrapParams = @{
            Path = $bootStrapPath;
            CoreCLR = $CoreCLR;
            MaxEnvelopeSizeKb = $MaxEnvelopeSizeKb;
        }
        if ($CustomBootStrap) {

            $setBootStrapParams['CustomBootStrap'] = $CustomBootStrap;
        }
        if ($PSBoundParameters.ContainsKey('DefaultShell')) {

            Write-Verbose -Message ($localized.SettingCustomShell -f $DefaultShell);
            $setBootStrapParams['DefaultShell'] = $DefaultShell;
        }
        Set-LabBootStrap @setBootStrapParams;

        $setupCompleteCmdPath = '{0}:\Windows\Setup\Scripts' -f $vhdDriveLetter;
        Write-Verbose -Message ($localized.AddingSetupCompleteCmdFile -f $setupCompleteCmdPath);
        Set-LabSetupCompleteCmd -Path $setupCompleteCmdPath -CoreCLR:$CoreCLR;

    } #end process
} #end function
