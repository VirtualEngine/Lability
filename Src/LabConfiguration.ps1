function Test-LabConfiguration {
<#
    .SYNOPSIS
        Tests the configuration of all VMs in a lab.
    .DESCRIPTION
        The Test-LabConfiguration determines whether all nodes defined in a PowerShell DSC configuration document
        are configured correctly and returns the results.

        WANRING: Only the virtual machine configuration is checked, not in the internal VM configuration. For example,
        the virtual machine's memory configuraiton, virtual switch configuration and processor count are tested. The
        VM's operating system configuration is not checked.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to create the virtual machines. Each node defined in the AllNodes array is
        tested.
    .LINK
        about_ConfigurationData
        Start-LabConfiguration
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        WriteVerbose $localized.StartedLabConfigurationTest;
        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };
        foreach ($node in $nodes) {
            [PSCustomObject] @{
                Name = $node.NodeName;
                IsConfigured = Test-LabVM -Name $node.NodeName -ConfigurationData $ConfigurationData;
            }
        }
        WriteVerbose $localized.FinishedLabConfigurationTest;
    } #end process
} #end function Test-LabConfiguration

function TestLabConfigurationMof {
<#
    .SYNOPSIS
        Checks for node MOF and meta MOF configuration files.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,
        
        ## Lab vm/node name
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,
        
        ## Path to .MOF files created from the DSC configuration
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),
        
        ## Ignores missing MOF file
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $SkipMofCheck
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $Path = Resolve-Path -Path $Path -ErrorAction Stop;
        $node = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -eq $Name };
        
        $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $node.NodeName);
        WriteVerbose ($localized.CheckingForNodeFile -f $mofPath);
        if (-not (Test-Path -Path $mofPath -PathType Leaf)) {
            if ($SkipMofCheck) {
                WriteWarning ($localized.CannotLocateMofFileError -f $mofPath)
            }
            else {
                throw ($localized.CannotLocateMofFileError -f $mofPath);
            }
        }

        $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $node.NodeName);
        WriteVerbose ($localized.CheckingForNodeFile -f $metaMofPath);
        if (-not (Test-Path -Path $metaMofPath -PathType Leaf)) {
            WriteWarning ($localized.CannotLocateLCMFileWarning -f $metaMofPath);
        }
    } #end process
} #end function TestLabConfigurationMof

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
    .PARAMETER Force
        Specifies that any existing virtual machine with a matching name, will be removed and recreated. By
        default, if a virtual machine already exists with the same name, the cmdlet will generate an error.
        
        NOTE: If the -Force parameter is specified - and a virtual machine with the same name already exists -
        ALL EXISTING DATA WITHIN THE VM WILL BE LOST.
    .LINK
        about_ConfigurationData
        about_Bootstrap
        Get-LabHostDefault
        Set-LabHostDefault
        Get-LabVMDefault
        Set-LabVMDefault
        Reset-Lab
#>
    [CmdletBinding(DefaultParameterSetName = 'PSCredential')]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,
        
        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ParameterSetName = 'PSCredential', ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential = (& $credentialCheckScriptBlock),
        
        ## Local administrator password of the VM.
        [Parameter(Mandatory, ParameterSetName = 'Password', ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
        
        ## Path to .MOF files created from the DSC configuration
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),
        
        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot,
        
        ## Forces a reconfiguration/redeployment of all nodes.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,
        
        ## Ignores missing MOF file
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $SkipMofCheck
    )
    begin {
        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) { throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        if (-not (Test-LabHostConfiguration) -and (-not $Force)) {
            throw $localized.HostConfigurationTestError;
        }
    }
    process {
        WriteVerbose $localized.StartedLabConfiguration;
        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };

        $Path = ResolvePathEx -Path $Path;
        foreach ($node in $nodes) {
            $testLabConfigurationMofParams = @{
                ConfigurationData = $ConfigurationData;
                Name = $node.NodeName;
                Path = $Path;
            }
            TestLabConfigurationMof @testLabConfigurationMofParams -SkipMofCheck:$SkipMofCheck;
        } #end foreach node

        foreach ($node in (Test-LabConfiguration -ConfigurationData $ConfigurationData)) {
            
            if ($node.IsConfigured -and $Force) {
                WriteVerbose ($localized.NodeForcedConfiguration -f $node.Name);
                NewLabVM -Name $node.Name -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot -Credential $Credential;
            }
            elseif ($node.IsConfigured) {
                WriteVerbose ($localized.NodeAlreadyConfigured -f $node.Name);
            }
            else {
                WriteVerbose ($localized.NodeMissingOrMisconfigured -f $node.Name);
                NewLabVM -Name $node.Name -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot -Credential $Credential;
            }
        }
        WriteVerbose $localized.FinishedLabConfiguration;
    } #end process
} #end function Start-LabConfiguration

function Remove-LabConfiguration {
<#
    .SYNOPSIS
        Removes all VMs and associated snapshots of all nodes defined in a PowerShell DSC configuration document.
    .DESCRIPTION
        The Remove-LabConfiguration removes all virtual machines that have a corresponding NodeName defined in the
        AllNode array of the PowerShell DSC configuration document.

        WARNING: ALL EXISTING VIRTUAL MACHINE DATA WILL BE LOST WHEN VIRTUAL MACHINES ARE REMOVED.

        By default, associated virtual machine switches are not removed as they may be used by other virtual
        machines or lab configurations. If you wish to remove any virtual switche defined in the PowerShell DSC
        configuration document, specify the -RemoveSwitch parameter.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to remove existing virtual machines. One virtual machine is removed per node
        defined in the AllNodes array.
    .PARAMETER RemoveSwitch
        Specifies that any connected virtual switch should also be removed when the virtual machine is removed.
    .LINK
        about_ConfigurationData
        Start-LabConfiguration
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,
        
        ## Include removal of virtual switch(es). By default virtual switches are not removed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $RemoveSwitch
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        WriteVerbose $localized.StartedLabConfiguration;
        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };
        foreach ($node in $nodes) {
            ##TODO: Should this not ensure that VMs are powered off?
            RemoveLabVM -Name $node.NodeName -ConfigurationData $ConfigurationData -RemoveSwitch:$RemoveSwitch;
        }
        WriteVerbose $localized.FinishedLabConfiguration;
    } #end process
} #end function Remove-LabConfiguration
