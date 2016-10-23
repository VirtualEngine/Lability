function SetLabVMDiskFileModule {

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
        [ValidateNotNullOrEmpty()]
        [System.String] $VhdDriveLetter,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        ## Resolve the localized %ProgramFiles% directory
        $programFilesPath = '{0}\WindowsPowershell\Modules' -f (ResolveProgramFilesFolder -Drive $VhdDriveLetter).FullName

        ## Add the DSC resource modules
        $resolveLabDscModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'DscResource';
        }
        $setLabVMDiskDscModuleParams = @{
            Module = ResolveLabModule @resolveLabDscModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskDscModuleParams['Module']) {

            WriteVerbose -Message ($localized.AddingDSCResourceModules -f $programFilesPath);
            SetLabVMDiskModule @setLabVMDiskDscModuleParams;
        }

        ## Add the PowerShell resource modules
        $resolveLabPowerShellModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'Module';
        }
        $setLabVMDiskPowerShellModuleParams = @{
            Module = ResolveLabModule @resolveLabPowerShellModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskPowerShellModuleParams['Module']) {

            WriteVerbose -Message ($localized.AddingPowerShellModules -f $programFilesPath);
            SetLabVMDiskModule @setLabVMDiskPowerShellModuleParams;
        }

    } #end process

}

