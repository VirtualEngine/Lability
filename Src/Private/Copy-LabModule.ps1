function Copy-LabModule {
<#
    .SYNOPSIS
        Copies Lability PowerShell and DSC Resource modules.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ConfigurationData,

        ## Module type(s) to install
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('Module','DscResource')]
        [System.String[]] $ModuleType,

        ## Install a specific node's modules
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $NodeName,

        ## Destination module path
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath
    )
    begin {

        [System.Collections.Hashtable] $ConfigurationData = ConvertTo-ConfigurationData -ConfigurationData $ConfigurationData;

    }
    process {

        ## Copy PowerShell modules
        if ($ModuleType -contains 'Module') {

            if ($PSBoundParameters.ContainsKey('NodeName')) {

                $resolveLabModuleParams = @{
                    NodeName = $NodeName;
                    ConfigurationData = $ConfigurationData;
                    ModuleType = 'Module';
                }
                $powerShellModules = Resolve-LabModule @resolveLabModuleParams;
            }
            else {

                $powerShellModules = $ConfigurationData.NonNodeData.Lability.Module;
            }

            if ($null -ne $powerShellModules) {

                Write-Verbose -Message ($localized.CopyingPowerShellModules -f $DestinationPath);
                if ($PSCmdlet.ShouldProcess($DestinationPath, $localized.InstallModulesConfirmation)) {

                    ExpandModuleCache -Module $powerShellModules -DestinationPath $DestinationPath;
                }
            }

        } #end if PowerShell modules

        ## Copy DSC resource modules
        if ($ModuleType -contains 'DscResource') {

            if ($PSBoundParameters.ContainsKey('NodeName')) {

                $resolveLabModuleParams = @{
                    NodeName = $NodeName;
                    ConfigurationData = $ConfigurationData;
                    ModuleType = 'DscResource';
                }
                $dscResourceModules = Resolve-LabModule @resolveLabModuleParams;
            }
            else {

                $dscResourceModules = $ConfigurationData.NonNodeData.Lability.DSCResource;
            }

            if ($null -ne $dscResourceModules) {

                Write-Verbose -Message ($localized.CopyingDscResourceModules -f $DestinationPath);
                if ($PSCmdlet.ShouldProcess($DestinationPath, $localized.InstallDscResourcesConfirmation)) {

                    ExpandModuleCache -Module $dscResourceModules -DestinationPath $DestinationPath;
                }
            }

        } #end if DSC resources

    } #end process
} #end function
