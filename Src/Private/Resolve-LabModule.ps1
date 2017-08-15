function Resolve-LabModule {
<#
    .SYNOPSIS
        Returns the Node\DSCResource or Node\Module definitions from the
        NonNodeData\Lability\DSCResource or NonNodeData\Lability\Module node.
    .DESCRIPTION
        Resolves lab modules/DSC resources names defined at the Node\DSCResource or
        Node\Module node, and returns a collection of hashtables where the names
        match the definition in the NonNodeData\Lability\DSCResource or
        \NonNodeData\Lability\Module nodes.

        If resources are defined at the \NonNodeData\Lability\DSCResource or
        NonNodeData\Lability\Module nodes, but there are no VM references, then all
        the associated resources are returned.
    .NOTES
        If no NonNodeData\Lability\DscResource collection is defined, all locally
        installed DSC resource modules are returned.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $NodeName,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Module type to enumerate
        [Parameter(Mandatory)]
        [ValidateSet('Module','DscResource')]
        [System.String] $ModuleType
    )
    process {

        $resolveNodePropertyValueParams = @{
            NodeName = $NodeName;
            ConfigurationData = $ConfigurationData;
        }
        $nodeProperties = Resolve-NodePropertyValue @resolveNodePropertyValueParams;

        $resolveModuleParams = @{
            ConfigurationData = $ConfigurationData;
            ModuleType = $ModuleType;
        }
        if ($nodeProperties.ContainsKey($ModuleType)) {
            $resolveModuleParams['Name'] = $nodeProperties[$ModuleType];
        }

        $modules = Resolve-LabConfigurationModule @resolveModuleParams;

        ## Only copy all existing DSC resources if there is no node or configuration DscResource
        ## defined. This allows suppressing local DSC resource module deploys
        if (($ModuleType -eq 'DscResource') -and
            (-not $nodeProperties.ContainsKey('DscResource')) -and
            ($null -eq $ConfigurationData.NonNodeData.($labDefaults.ModuleName).DscResource)) {
            <#
                There is no DSCResource = @() node defined either at the node or the configuration
                level. Therefore, we need
                to copy all the existing DSC resources on from the host by
                returning a load of FileSystem provider resources..
            #>
            WriteWarning -Message ($localized.DscResourcesNotDefinedWarning);

            $modules = GetDscResourceModule -Path "$env:ProgramFiles\WindowsPowershell\Modules" |
                ForEach-Object {
                    ## Create a new hashtable
                    Write-Output -InputObject @{
                        Name = $_.ModuleName;
                        Version = $_.ModuleVersion;
                        Provider = 'FileSystem';
                        Path = $_.Path;
                    }
                };
        }

        return $modules;
    }
} #end function Resolve-LabModule
