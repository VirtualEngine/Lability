function Start-LabConfiguration {
<#
    .SYNOPSIS
        Invokes the deployment and configuration of a VM for each node defined in a PowerShell DSC configuration
        document.
    .DESCRIPTION
        The Start-LabConfiguration initiates the configuration of all nodes defined in a PowerShell DSC configuration
        document. The AllNodes array is enumerated and a virtual machine is created per node, using the NodeName
        property.

        If any existing virtual machine exists with the same name as the NodeName declaration of the AllNodes array,
        the cmdlet will throw an error. If this behaviour is not desired, you can forcibly remove the existing VM
        with the -Force parameter. NOTE: THE VIRTUAL MACHINE'S EXISTING DATA WILL BE LOST.

        The virtual machines' local administrator password must be specified when creating the lab VMs. The local
        administrator password can be specified as a [PSCredential] or a [SecureString] type. If a [PSCredential] is
        used then the username is not used.

        It is possible to override the module's virtual machine default settings by specifying the required property
        on the node hashtable in the PowerShell DSC configuration document. Default settings include the Operating
        System image to use, the amount of memory assigned to the virtual machine and/or the virtual switch to
        connect the virtual machine to. If the settings are not overridden, the module's defaults are used. Use the
        Get-LabVMDefault cmdlet to view the module's default values.

        Each virtual machine created by the Start-LabConfiguration cmdlet, has its PowerShell DSC configuraion (.mof)
        file injected into the VHD file as it is created. This configuration is then applied during the first boot
        process to ensure the virtual machine is configured as required. If the path to the VM's .mof files is not
        specified, the module's default Configuration directory is used. Use the Get-LabHostDefault cmdlet to view
        the module's default Configuration directory path.

        The virtual machine .mof files must be created before creating the lab. If any .mof files are missing, the
        Start-LabConfiguration cmdlet will generate an error. You can choose to ignore this error by specifying
        the -SkipMofCheck parameter. If you skip the .mof file check - and no .mof file is found - no configuration
        will be applied to the virtual machine's Operating System settings.

        When deploying a lab, the module will create a default baseline snapshot of all virtual machines. This
        snapshot can be used to revert all VMs back to their default configuration. If this snapshot is not
        required, it can be surpressed with the -NoSnapshot parameter.
    .NOTES
        The same local administrator password is used for all virtual machines created in the same lab configuration.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to create the virtual machines. One virtual machine is created per node defined
        in the AllNodes array.
    .PARAMETER Credential
        Specifies the local administrator password of all virtual machines in the lab configuration. The same
        password is used for all virtual machines in the same lab configuration. The username is not used.
    .PARAMETER Password
        Specifies the local administrator password of all virtual machines in the lab configuration. The same
        password is used for all virtual machines in the same lab configuration.
    .PARAMETER Path
        Specifies the directory path containing the individual PowerShell DSC .mof files. If not specified, the
        module's default location is used.
    .PARAMETER NoSnapshot
        Specifies that no default snapshot will be taken when creating the virtual machine.

        NOTE: If no default snapshot is not created, the lab cannot be restored to its initial configuration
        with the Reset-Lab cmdlet.
    .PARAMETER SkipMofCheck
        Specifies that the module will configure a virtual machines that do not have a corresponding .mof file
        located in the -Path specfified. By default, if any .mof file cannot be located then the cmdlet will
        generate an error.

        NOTE: If no .mof file is found and the -SkipMofCheck parameter is specified, no configuration will be
        applied to the virtual machine's Operating System configuration.
    .PARAMETER IgnorePendingReboot
        The host's configuration is checked before invoking a lab configuration, including checking for pending
        reboots. The -IgnorePendingReboot specifies that a pending reboot should be ignored and the lab
        configuration applied.
    .PARAMETER Force
        Specifies that any existing virtual machine with a matching name, will be removed and recreated. By
        default, if a virtual machine already exists with the same name, the cmdlet will generate an error.

        NOTE: If the -Force parameter is specified - and a virtual machine with the same name already exists -
        ALL EXISTING DATA WITHIN THE VM WILL BE LOST.
    .PARAMETER FeedCredential
        A [PSCredential] object containing the credentials to use when accessing a private Azure DevOps feed.
    .LINK
        about_ConfigurationData
        about_Bootstrap
        Get-LabHostDefault
        Set-LabHostDefault
        Get-LabVMDefault
        Set-LabVMDefault
        Reset-Lab
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'PSCredential')]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ParameterSetName = 'PSCredential', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential = (& $credentialCheckScriptBlock),

        ## Local administrator password of the VM.
        [Parameter(Mandatory, ParameterSetName = 'Password', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,

        ## Path to .MOF files created from the DSC configuration
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot,

        ## Forces a reconfiguration/redeployment of all nodes.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Ignores missing MOF file
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $SkipMofCheck,

        ## Skips pending reboot check
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $IgnorePendingReboot,

        ## Credentials to access the a private feed
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential
)
    begin {

        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) { throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

        if (-not (Test-LabHostConfiguration -IgnorePendingReboot:$IgnorePendingReboot) -and (-not $Force)) {

            throw $localized.HostConfigurationTestError;
        }
    }
    process {

        Write-Verbose -Message $localized.StartedLabConfiguration;
        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };

        ## There is an assumption here is all .mofs are in the same folder
        $resolveConfigurationPathParams = @{
            ConfigurationData = $ConfigurationData;
            Name = $nodes | Select-Object -First 1 | ForEach-Object { $_.NodeName };
            Path = $Path;
            UseDefaultPath = $SkipMofCheck;
        }
        $Path = Resolve-ConfigurationPath @resolveConfigurationPathParams;

        foreach ($node in $nodes) {

            $assertLabConfigurationMofParams = @{
                ConfigurationData = $ConfigurationData;
                Name = $node.NodeName;
                Path = $Path;
            }
            Assert-LabConfigurationMof @assertLabConfigurationMofParams -SkipMofCheck:$SkipMofCheck;

        } #end foreach node

        $currentNodeCount = 0;
        foreach ($node in (Test-LabConfiguration -ConfigurationData $ConfigurationData -WarningAction SilentlyContinue)) {
            ## Ignore Lability warnings during the test phase, e.g. existing switches and .mof files

            $currentNodeCount++;
            [System.Int16] $percentComplete = (($currentNodeCount / $nodes.Count) * 100) - 1;
            $activity = $localized.ConfiguringNode -f $node.Name;
            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
            if ($node.IsConfigured -and $Force) {

                Write-Verbose -Message ($localized.NodeForcedConfiguration -f $node.Name);

                $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'New-VM', $node.Name;
                $verboseProcessMessage = Get-FormattedMessage -Message ($localized.CreatingVM -f $node.Name);
                if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                    $newLabVirtualMachineParams = @{
                        Name = $node.Name;
                        ConfigurationData = $ConfigurationData;
                        Path = $Path;
                        NoSnapshot = $NoSnapshot;
                        Credential = $Credential;
                    }
                    New-LabVirtualMachine @newLabVirtualMachineParams;
                }
            }
            elseif ($node.IsConfigured) {

                Write-Verbose -Message ($localized.NodeAlreadyConfigured -f $node.Name);
            }
            else {

                Write-Verbose -Message ($localized.NodeMissingOrMisconfigured -f $node.Name);

                $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Start-LabConfiguration', $node.Name;
                $verboseProcessMessage = Get-FormattedMessage -Message ($localized.CreatingVM -f $node.Name);
                if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                    $newLabVirtualMachineParams = @{
                        Name = $node.Name;
                        ConfigurationData = $ConfigurationData;
                        Path = $Path;
                        NoSnapshot = $NoSnapshot;
                        Credential = $Credential;
                        FeedCredential = $FeedCredential;
                    }
                    [ref] $null = New-LabVirtualMachine @newLabVirtualMachineParams;
                }
            }

        } #end foreach node

        Write-Progress -Id 42 -Activity $activity -Completed;
        Write-Verbose -Message $localized.FinishedLabConfiguration;

    } #end process
} #end function Start-LabConfiguration
