function Set-LabVMDiskFileModule {
<#
    .SYNOPSIS
        Copies a node's PowerShell and DSC resource modules to a VHD(X) file.
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
        [System.String] $VhdDriveLetter,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        ## Resolve the localized %ProgramFiles% directory
        $programFilesPath = '{0}\WindowsPowershell\Modules' -f (Resolve-ProgramFilesFolder -Drive $VhdDriveLetter).FullName

        ## Add the DSC resource modules
        $resolveLabModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'DscResource';
        }
        $setLabVMDiskDscModuleParams = @{
            Module = Resolve-LabModule @resolveLabModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskDscModuleParams['Module']) {

            WriteVerbose -Message ($localized.AddingDSCResourceModules -f $programFilesPath);
            Set-LabVMDiskModule @setLabVMDiskDscModuleParams;
        }

        ## Add the PowerShell resource modules
        $resolveLabModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'Module';
        }
        $setLabVMDiskPowerShellModuleParams = @{
            Module = Resolve-LabModule @resolveLabModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskPowerShellModuleParams['Module']) {

            WriteVerbose -Message ($localized.AddingPowerShellModules -f $programFilesPath);
            Set-LabVMDiskModule @setLabVMDiskPowerShellModuleParams;
        }

    } #end process
} #end function
