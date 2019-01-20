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
        $labDefaultProperties = Get-ConfigurationData -Configuration VM;
        $properties = Get-Member -InputObject $labDefaultProperties -MemberType NoteProperty;
        foreach ($propertyName in $properties.Name) {

            ## Int32 values of 0 get coerced into $false!
            if (($node.$propertyName -isnot [System.Int32]) -and (-not $node.ContainsKey($propertyName))) {

                $node[$propertyName] = $labDefaultProperties.$propertyName;
            }
        }

        $resolveLabEnvironmentNameParams = @{
            Name              = $NodeName;
            ConfigurationData = $ConfigurationData;
        }
        ## Set the node's friendly/display name with any prefix/suffix
        $node['NodeDisplayName'] = Resolve-LabEnvironmentName @resolveLabEnvironmentNameParams;
        ## Use the prefixed/suffixed NetBIOSName is specified
        if ($node.UseNetBIOSName -eq $true) {
            $node['NodeDisplayName'] = $node['NodeDisplayName'].Split('.')[0];
        }

        $moduleName = $labDefaults.ModuleName;
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
