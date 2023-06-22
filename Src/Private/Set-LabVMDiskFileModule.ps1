function Set-LabVMDiskFileModule {
<#
    .SYNOPSIS
        Copies a node's PowerShell and DSC resource modules to a VHD(X) file.
#>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
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

        ## Node DSC .mof and .meta.mof configuration file path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments,

        ## Credentials to access the a private feed
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential
    )
    process {

        ## Resolve the localized %ProgramFiles% directory
        $programFilesPath = '{0}\WindowsPowershell\Modules' -f (Resolve-ProgramFilesFolder -Drive $VhdDriveLetter).FullName

        ## Add the DSC resource modules
        $resolveLabModuleParams = @{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'DscResource';
        }
        $setLabVMDiskDscModuleParams = @{
            Module = Resolve-LabModule @resolveLabModuleParams;
            DestinationPath = $programFilesPath;
        }

        if ($null -ne $setLabVMDiskDscModuleParams['Module']) {

            ## Check that we have cache copies of all modules used in the .mof file.
            $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $NodeName);
            if (Test-Path -Path $mofPath -PathType Leaf) {

                $testLabMofModuleParams = @{
                    Module = $setLabVMDiskDscModuleParams.Module;
                    MofModule = Get-LabMofModule -Path $mofPath;
                }

                if ($null -ne $testLabMofModuleParams['MofModule']) {

                    ## TODO: Add automatic download of missing resources from the PSGallery.
                    [ref] $null = Test-LabMofModule @testLabMofModuleParams;
                }
            }

            Write-Verbose -Message ($localized.AddingDSCResourceModules -f $programFilesPath);
            Set-LabVMDiskModule @setLabVMDiskDscModuleParams -FeedCredential $FeedCredential;
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

            Write-Verbose -Message ($localized.AddingPowerShellModules -f $programFilesPath);
            Set-LabVMDiskModule @setLabVMDiskPowerShellModuleParams;
        }

    } #end process
} #end function
