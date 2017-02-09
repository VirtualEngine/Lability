function Resolve-NodePropertyValue {
<#
    .SYNOPSIS
        Resolves a node's properites.
    .DESCRIPTION
        Resolves a lab virtual machine properties from the lab defaults, Node\* node
        and Node\NodeName node.

        Properties defined on the wildcard node override the lab defaults.
        Properties defined at the node override the wildcard node settings.
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

        ## Do not enumerate the AllNodes.'*' node
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoEnumerateWildcardNode
    )
    process {

        $node = @{ };
        $moduleName = $labDefaults.ModuleName;

        ## Set the node's display name, if defined.
        if ($ConfigurationData.NonNodeData.$moduleName.EnvironmentPrefix) {

            $node["$($moduleName)_EnvironmentPrefix"] = $ConfigurationData.NonNodeData.$moduleName.EnvironmentPrefix;
        }
        if ($ConfigurationData.NonNodeData.$moduleName.EnvironmentSuffix) {

            $node["$($moduleName)_EnvironmentSuffix"] = $ConfigurationData.NonNodeData.$moduleName.EnvironmentSuffix;
        }

        if (-not $NoEnumerateWildcardNode) {

            ## Retrieve the AllNodes.* properties
            $ConfigurationData.AllNodes.Where({ $_.NodeName -eq '*' }) | ForEach-Object {
                foreach ($key in $_.Keys) {

                    $node[$key] = $_.$key;
                }
            }
        }

        ## Retrieve the AllNodes.$NodeName properties
        $ConfigurationData.AllNodes.Where({ $_.NodeName -eq $NodeName }) | ForEach-Object {

            foreach ($key in $_.Keys) {

                $node[$key] = $_.$key;
            }
        }

        ## Check VM defaults
        $labDefaultProperties = GetConfigurationData -Configuration VM;
        $properties = Get-Member -InputObject $labDefaultProperties -MemberType NoteProperty;
        foreach ($propertyName in $properties.Name) {

            ## Int32 values of 0 get coerced into $false!
            if (($node.$propertyName -isnot [System.Int32]) -and (-not $node.ContainsKey($propertyName))) {

                $node[$propertyName] = $labDefaultProperties.$propertyName;
            }
        }

        ## Set the node's friendly/display name
        $nodeDisplayName = $node.NodeName;
        $environmentPrefix = '{0}_EnvironmentPrefix' -f $moduleName;
        $environmentSuffix = '{0}_EnvironmentSuffix' -f $moduleName;
        if (-not [System.String]::IsNullOrEmpty($node[$environmentPrefix])) {

            $nodeDisplayName = '{0}{1}' -f $node[$environmentPrefix], $nodeDisplayName;
        }
        if (-not [System.String]::IsNullOrEmpty($node[$environmentSuffix])) {

            $nodeDisplayName = '{0}{1}' -f $nodeDisplayName, $node[$environmentSuffix];
        }
        $node["$($moduleName)_NodeDisplayName"] = $nodeDisplayName;

        ## Rename/overwrite existing parameter values where $moduleName-specific parameters exist
        foreach ($key in @($node.Keys)) {

            if ($key.StartsWith("$($moduleName)_")) {

                $node[($key.Replace("$($moduleName)_",''))] = $node.$key;
                $node.Remove($key);
            }
        }

        return $node;

    } #end process
} #end function ResolveLabVMProperties
