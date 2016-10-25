function SetLabVMDiskFileResource {

<#
    .SYNOPSIS
        Copies a node's defined resources to VHD(X) file.
#>
    [CmdletBinding()]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $NodeName,

        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VhdDriveLetter,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $hostDefaults = GetConfigurationData -Configuration Host;
        $resourceDestinationPath = '{0}:\{1}' -f $vhdDriveLetter, $hostDefaults.ResourceShareName;
        $expandLabResourceParams = @{
            ConfigurationData = $ConfigurationData;
            Name = $NodeName;
            DestinationPath = $resourceDestinationPath;
        }
        WriteVerbose -Message ($localized.AddingVMResource -f 'VM');
        ExpandLabResource @expandLabResourceParams;

    } #end process

}

