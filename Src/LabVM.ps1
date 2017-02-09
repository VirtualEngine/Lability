function Get-LabVM {
<#
    .SYNOPSIS
        Retrieves the current configuration of a VM.
    .DESCRIPTION
        Gets a virtual machine's configuration using the xVMHyperV DSC resource.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if (-not $Name) {

            # Return all nodes defined in the configuration
            $Name = $ConfigurationData.AllNodes | Where-Object NodeName -ne '*' | ForEach-Object { $_.NodeName; }
        }

        foreach ($nodeName in $Name) {

            $node = Resolve-NodePropertyValue -NodeName $nodeName -ConfigurationData $ConfigurationData;
            $xVMParams = @{
                Name = $node.NodeDisplayName;
                VhdPath = ResolveLabVMDiskPath -Name $node.NodeDisplayName;;
            }

            try {

                ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
                $vm = GetDscResource -ResourceName VM -Parameters $xVMParams;
                Write-Output -InputObject ([PSCustomObject] $vm);
            }
            catch {

                Write-Error -Message ($localized.CannotLocateNodeError -f $nodeName);
            }

        } #end foreach node

    } #end process
} #end function Get-LabVM


function Test-LabVM {
<#
    .SYNOPSIS
        Checks whether the (external) lab virtual machine is configured as required.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if (-not $Name) {

            $Name = $ConfigurationData.AllNodes | Where-Object NodeName -ne '*' | ForEach-Object { $_.NodeName }
        }

        foreach ($vmName in $Name) {

            $isNodeCompliant = $true;
            $node = Resolve-NodePropertyValue -NodeName $vmName -ConfigurationData $ConfigurationData;
            WriteVerbose ($localized.TestingNodeConfiguration -f $node.NodeDisplayName);

            WriteVerbose ($localized.TestingVMConfiguration -f 'Image', $node.Media);
            if (-not (Test-LabImage -Id $node.Media -ConfigurationData $ConfigurationData)) {

                $isNodeCompliant = $false;
            }
            else {

                ## No point testing switch, vhdx and VM if the image isn't available
                WriteVerbose ($localized.TestingVMConfiguration -f 'Virtual Switch', $node.SwitchName);
                foreach ($switchName in $node.SwitchName) {

                    if (-not (TestLabSwitch -Name $switchName -ConfigurationData $ConfigurationData)) {

                        $isNodeCompliant = $false;
                    }
                }

                WriteVerbose ($localized.TestingVMConfiguration -f 'VHDX', $node.Media);
                $testLabVMDiskParams = @{
                    Name = $node.NodeDisplayName;
                    Media = $node.Media;
                    ConfigurationData = $ConfigurationData;
                }
                if (-not (TestLabVMDisk @testLabVMDiskParams -ErrorAction SilentlyContinue)) {

                    $isNodeCompliant = $false;
                }
                else {

                    ## No point testing VM if the VHDX isn't available
                    WriteVerbose ($localized.TestingVMConfiguration -f 'VM', $vmName);
                    $testLabVirtualMachineParams = @{
                        Name = $node.NodeDisplayName;
                        SwitchName = $node.SwitchName;
                        Media = $node.Media;
                        StartupMemory = $node.StartupMemory;
                        MinimumMemory = $node.MinimumMemory;
                        MaximumMemory = $node.MaximumMemory;
                        ProcessorCount = $node.ProcessorCount;
                        MACAddress = $node.MACAddress;
                        SecureBoot = $node.SecureBoot;
                        GuestIntegrationServices = $node.GuestIntegrationServices;
                        ConfigurationData = $ConfigurationData;
                    }
                    if (-not (TestLabVirtualMachine @testLabVirtualMachineParams)) {

                        $isNodeCompliant = $false;
                    }
                }
            }

            Write-Output -InputObject $isNodeCompliant;

        } #end foreach vm

    } #end process
} #end function Test-LabVM


function NewLabVM {
<#
    .SYNOPSIS
        Creates and configures a lab virtual machine.
    .DESCRIPTION
        Creates an new VM, creating the switch if required, injecting all
        resources and snapshotting as required.
#>
    [CmdletBinding(DefaultParameterSetName = 'PSCredential')]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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
        [Parameter(Mandatory, ParameterSetName = 'Password', ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,

        ## Virtual machine DSC .mof and .meta.mof location
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),

        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot,

        ## Is a quick VM, e.g. created via the New-LabVM cmdlet
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $IsQuickVM
    )
    begin {

        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) {throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

    }
    process {

        $node = Resolve-NodePropertyValue -NodeName $Name -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $NodeName = $node.NodeName;
        ## Display name includes any environment prefix/suffix
        $displayName = $node.NodeDisplayName;

        if (-not (TestComputerName -ComputerName $displayName)) {

            throw ($localized.InvalidComputerNameError -f $displayName);
        }

        ## Don't attempt to check certificates for 'Quick VMs'
        if (-not $IsQuickVM) {

            ## Check for certificate before we (re)create the VM
            if (-not [System.String]::IsNullOrWhitespace($node.ClientCertificatePath)) {

                $expandedClientCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.ClientCertificatePath);
                if (-not (Test-Path -Path $expandedClientCertificatePath -PathType Leaf)) {

                    throw ($localized.CannotFindCertificateError -f 'Client', $node.ClientCertificatePath);
                }
            }
            else {

                WriteWarning ($localized.NoCertificateFoundWarning -f 'Client');
            }

            if (-not [System.String]::IsNullOrWhitespace($node.RootCertificatePath)) {

                $expandedRootCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.RootCertificatePath);
                if (-not (Test-Path -Path $expandedRootCertificatePath -PathType Leaf)) {

                    throw ($localized.CannotFindCertificateError -f 'Root', $node.RootCertificatePath);
                }
            }
            else {

                WriteWarning ($localized.NoCertificateFoundWarning -f 'Root');
            }

        } #end if not quick VM

        foreach ($switchName in $node.SwitchName) {

            WriteVerbose ($localized.SettingVMConfiguration -f 'Virtual Switch', $switchName);
            SetLabSwitch -Name $switchName -ConfigurationData $ConfigurationData;
        }

        if (-not (Test-LabImage -Id $node.Media -ConfigurationData $ConfigurationData)) {

            [ref] $null = New-LabImage -Id $node.Media -ConfigurationData $ConfigurationData;
        }

        WriteVerbose ($localized.ResettingVMConfiguration -f 'VHDX', "$displayName.vhdx");
        ResetLabVMDisk -Name $DisplayName -Media $node.Media -ConfigurationData $ConfigurationData -ErrorAction Stop;

        WriteVerbose ($localized.SettingVMConfiguration -f 'VM', $displayName);
        $setLabVirtualMachineParams = @{
            Name = $DisplayName;
            SwitchName = $node.SwitchName;
            Media = $node.Media;
            StartupMemory = $node.StartupMemory;
            MinimumMemory = $node.MinimumMemory;
            MaximumMemory = $node.MaximumMemory;
            ProcessorCount = $node.ProcessorCount;
            MACAddress = $node.MACAddress;
            SecureBoot = $node.SecureBoot;
            GuestIntegrationServices = $node.GuestIntegrationServices;
            ConfigurationData = $ConfigurationData;
        }
        SetLabVirtualMachine @setLabVirtualMachineParams;

        $media = ResolveLabMedia -Id $node.Media -ConfigurationData $ConfigurationData;
        if ($media.OperatingSystem -eq 'Linux') {
            ## Skip injecting files for Linux VMs..
        }
        else {

            WriteVerbose ($localized.AddingVMCustomization -f 'VM');
            $setLabVMDiskFileParams = @{
                NodeName = $NodeName;
                ConfigurationData = $ConfigurationData;
                Path = $Path;
                Credential = $Credential;
                CoreCLR = $media.CustomData.SetupComplete -eq 'CoreCLR';
            }

            $resolveCustomBootStrapParams = @{
                CustomBootstrapOrder = $node.CustomBootstrapOrder;
                ConfigurationCustomBootstrap = $node.CustomBootstrap;
                MediaCustomBootStrap = $media.CustomData.CustomBootstrap;
            }

            $customBootstrap = ResolveCustomBootStrap @resolveCustomBootStrapParams;
            if ($customBootstrap) {

                $setLabVMDiskFileParams['CustomBootstrap'] = $customBootstrap;
            }

            if (-not [System.String]::IsNullOrEmpty($media.CustomData.ProductKey)) {

                $setLabVMDiskFileParams['ProductKey'] = $media.CustomData.ProductKey;
            }
            Set-LabVMDiskFile @setLabVMDiskFileParams;

        } #end Windows VMs

        if (-not $NoSnapshot) {

            $snapshotName = $localized.BaselineSnapshotName -f $labDefaults.ModuleName;
            WriteVerbose ($localized.CreatingBaselineSnapshot -f $snapshotName);
            Checkpoint-VM -Name $displayName -SnapshotName $snapshotName -Confirm:$false;
        }

        if ($node.WarningMessage) {

            if ($node.WarningMessage -is [System.String]) {

                WriteWarning ($localized.NodeCustomMessageWarning -f $NodeName, $node.WarningMessage.Trim("\n"));
            }
            else {

                WriteWarning ($localized.IncorrectPropertyTypeError -f 'WarningMessage', '[System.String]')
            }
        }

        Write-Output -InputObject (Get-VM -Name $displayName);

    } #end process
} #end function NewLabVM


function RemoveLabVM {
<#
    .SYNOPSIS
        Deletes a lab virtual machine.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Include removal of virtual switch(es). By default virtual switches are not removed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $RemoveSwitch
    )
    process {

        $node = Resolve-NodePropertyValue -NodeName $Name -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode -ErrorAction Stop;
        if (-not $node.NodeName) {
            throw ($localized.CannotLocateNodeError -f $Name);
        }
        $Name = $node.NodeDisplayName;

        # Revert to oldest snapshot prior to VM removal to speed things up
        Get-VMSnapshot -VMName $Name -ErrorAction SilentlyContinue |
            Sort-Object -Property CreationTime |
                Select-Object -First 1 |
                    Restore-VMSnapshot -Confirm:$false;

        RemoveLabVMSnapshot -Name $Name;

        WriteVerbose ($localized.RemovingNodeConfiguration -f 'VM', $Name);
        $removeLabVirtualMachineParams = @{
            Name = $Name;
            SwitchName = $node.SwitchName;
            Media = $node.Media;
            StartupMemory = $node.StartupMemory;
            MinimumMemory = $node.MinimumMemory;
            MaximumMemory = $node.MaximumMemory;
            MACAddress = $node.MACAddress;
            ProcessorCount = $node.ProcessorCount;
            ConfigurationData = $ConfigurationData;
        }
        RemoveLabVirtualMachine @removeLabVirtualMachineParams;

        WriteVerbose ($localized.RemovingNodeConfiguration -f 'VHD/X', "$Name.vhd/vhdx");
        $removeLabVMDiskParams = @{
            Name = $node.NodeDisplayName;
            Media = $node.Media;
            ConfigurationData = $ConfigurationData;
        }
        RemoveLabVMDisk @removeLabVMDiskParams -ErrorAction Stop;

        if ($RemoveSwitch) {

            WriteVerbose ($localized.RemovingNodeConfiguration -f 'Virtual Switch', $node.SwitchName);
            RemoveLabSwitch -Name $node.SwitchName -ConfigurationData $ConfigurationData;
        }

    } #end process
} #end function RemoveLabVM


function Remove-LabVM {
<#
    .SYNOPSIS
        Removes a bare-metal virtual machine and differencing VHD(X).
    .DESCRIPTION
        The Remove-LabVM cmdlet removes a virtual machine and it's VHD(X) file.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        ## Virtual machine name
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $currentNodeCount = 0;
        foreach ($vmName in $Name) {

            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Remove-LabVM', $vmName;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.RemovingVM -f $vmName);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                $currentNodeCount++;
                [System.Int32] $percentComplete = (($currentNodeCount / $Name.Count) * 100) - 1;
                $activity = $localized.ConfiguringNode -f $vmName;
                Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

                ## Create a skeleton config data if one wasn't supplied
                if (-not $PSBoundParameters.ContainsKey('ConfigurationData')) {

                    try {

                        <# If we don't have configuration document, we need to locate
                        the lab image id so that the VM's VHD/X can be removed #182 #>
                        $mediaId = (Resolve-LabVMImage -Name $vmName).Id;
                    }
                    catch {

                        throw ($localized.CannotResolveMediaIdError -f $vmName);
                    }

                    $configurationData = @{
                        AllNodes = @(
                            @{
                                NodeName = $vmName;
                                Media = $mediaId;
                            }
                        )
                    };
                }

                RemoveLabVM -Name $vmName -ConfigurationData $configurationData;
            } #end if should process
        } #end foreach VM

        if (-not [System.String]::IsNullOrEmpty($activity)) {

            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
        }

    } #end process
} #end function Remove-LabVM
