function ResolveModule {

<#
    .SYNOPSIS
        Resolves a lab module definition by its name from Lability configuration data.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        [Parameter(Mandatory)] [ValidateSet('Module','DscResource')]
        [System.String] $ModuleType,

        ## Lab module name/ID
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]] $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $ThrowIfNotFound
    )
    process {

        $modules = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).$ModuleType;

        if (($PSBoundParameters.ContainsKey('Name')) -and ($Name -notcontains '*')) {

            ## Check we have them all first..
            foreach ($moduleName in $Name) {
                if ($modules.Name -notcontains $moduleName) {
                    if ($ThrowIfNotFound) {
                        throw ($localized.CannotResolveModuleNameError -f $ModuleType, $moduleName);
                    }
                    else {
                        WriteWarning -Message ($localized.CannotResolveModuleNameError -f $ModuleType, $moduleName);
                    }
                }
            }

            $modules = $modules | Where-Object { $_.Name -in $Name };
        }

        return $modules;
    }

}

