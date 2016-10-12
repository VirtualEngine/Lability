function ResolveLabVMProperties {
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

            $node = ResolveLabVMProperties -NodeName $nodeName -ConfigurationData $ConfigurationData;
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
            $node = ResolveLabVMProperties -NodeName $vmName -ConfigurationData $ConfigurationData;
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

        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $NodeName = $node.NodeName;
        ## Display name includes any environment prefix/suffix
        $displayName = $node.NodeDisplayName;

        if (-not (TestComputerName -ComputerName $displayName)) {

            throw (localized.InvalidComputerNameError -f $displayName);
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

            $mediaProductKey = $media.CustomData.ProductKey;
            if ($mediaProductKey) {

                $setLabVMDiskFileParams['ProductKey'] = $mediaProductKey;
            }

            SetLabVMDiskFile @setLabVMDiskFileParams;

        } #end Windows VMs

        if (-not $NoSnapshot) {

            $snapshotName = $localized.BaselineSnapshotName -f $labDefaults.ModuleName;
            WriteVerbose ($localized.CreatingBaselineSnapshot -f $snapshotName);
            Checkpoint-VM -Name $displayName -SnapshotName $snapshotName;
        }

        if ($node.WarningMessage) {

            if ($node.WarningMessage -is [System.String]) {

                WriteWarning ($localized.NodeCustomMessageWarning -f $NodeName, $node.WarningMessage);
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

        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode -ErrorAction Stop;
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

        WriteVerbose ($localized.RemovingNodeConfiguration -f 'VHDX', "$Name.vhdx");
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


function Reset-LabVM {
<#
    .SYNOPSIS
        Recreates a lab virtual machine.
    .DESCRIPTION
        The Reset-LabVM cmdlet deletes and recreates a lab virtual machine, reapplying the MOF.

        To revert a single VM to a previous state, use the Restore-VMSnapshot cmdlet. To revert an entire lab environment, use the Restore-Lab cmdlet.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'PSCredential')]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Local administrator password of the virtual machine. The username is NOT used.
        [Parameter(ParameterSetName = 'PSCredential', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential = (& $credentialCheckScriptBlock),

        ## Local administrator password of the virtual machine.
        [Parameter(Mandatory, ParameterSetName = 'Password', ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,

        ## Directory path containing the virtual machines' .mof file(s).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),

        ## Skip creation of the initial baseline snapshot.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot
    )
    begin {

        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) { throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

    }
    process {

        $currentNodeCount = 0;
        foreach ($vmName in $Name) {

            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Reset-LabVM', $vmName;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.ResettingVM -f $vmName);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                $currentNodeCount++;
                [System.Int32] $percentComplete = (($currentNodeCount / $Name.Count) * 100) - 1;
                $activity = $localized.ConfiguringNode -f $vmName;
                Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

                RemoveLabVM -Name $vmName -ConfigurationData $ConfigurationData;
                NewLabVM -Name $vmName -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot -Credential $Credential;

            } #end if should process
        } #end foreach VMd

        if (-not [System.String]::IsNullOrEmpty($activity)) {
            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
        }

    } #end process
} #end function Reset-LabVM


function New-LabVM {
<#
    .SYNOPSIS
        Creates a simple bare-metal virtual machine.
    .DESCRIPTION
        The New-LabVM cmdlet creates a bare virtual machine using the specified media. No bootstrap or DSC configuration is applied.

        NOTE: The mandatory -MediaId parameter is dynamic and is not displayed in the help syntax output.

        If optional values are not specified, the virtual machine default settings are applied. To list the current default settings run the `Get-LabVMDefault` command.

        NOTE: If a specified virtual switch cannot be found, an Internal virtual switch will automatically be created. To use any other virtual switch configuration, ensure the virtual switch is created in advance.
    .LINK
        Register-LabMedia
        Unregister-LabMedia
        Get-LabVMDefault
        Set-LabVMDefault
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'PSCredential')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams','')]
    param (
        ## Specifies the virtual machine name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Default virtual machine startup memory (bytes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $StartupMemory,

        ## Default virtual machine miniumum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MinimumMemory,

        ## Default virtual machine maximum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MaximumMemory,

        ## Default virtual machine processor count.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 4)]
        [System.Int32] $ProcessorCount,

        # Input Locale
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^([a-z]{2,2}-[a-z]{2,2})|(\d{4,4}:\d{8,8})$')]
        [System.String] $InputLocale,

        # System Locale
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $SystemLocale,

        # User Locale
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UserLocale,

        # UI Language
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UILanguage,

        # Timezone
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Timezone,

        # Registered Owner
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $RegisteredOwner,

        # Registered Organization
        [Parameter(ValueFromPipelineByPropertyName)] [Alias('RegisteredOrganisation')]
        [ValidateNotNullOrEmpty()]
        [System.String] $RegisteredOrganization,

        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PSCredential')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential = (& $credentialCheckScriptBlock),

        ## Local administrator password of the VM.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Password')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,

        ## Virtual machine switch name(s).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        ## Virtual machine MAC address(es).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $MACAddress,

        ## Enable Secure boot status
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Boolean] $SecureBoot,

        ## Enable Guest Integration Services
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Boolean] $GuestIntegrationServices,

        ## Custom data
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.Collections.Hashtable] $CustomData,

        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot
    )
    DynamicParam {

        ## Adds a dynamic -MediaId parameter that returns the available media Ids
        $parameterAttribute = New-Object -TypeName 'System.Management.Automation.ParameterAttribute';
        $parameterAttribute.ParameterSetName = '__AllParameterSets';
        $parameterAttribute.Mandatory = $true;
        $attributeCollection = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Attribute]';
        $attributeCollection.Add($parameterAttribute);
        $mediaIds = (Get-LabMedia).Id;
        $validateSetAttribute = New-Object -TypeName 'System.Management.Automation.ValidateSetAttribute' -ArgumentList $mediaIds;
        $attributeCollection.Add($validateSetAttribute);
        $runtimeParameter = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameter' -ArgumentList @('MediaId', [System.String], $attributeCollection);
        $runtimeParameterDictionary = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameterDictionary';
        $runtimeParameterDictionary.Add('MediaId', $runtimeParameter);
        return $runtimeParameterDictionary;
    }
    begin {

        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) { throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

    } #end begin
    process {

        ## Skeleton configuration node
        $configurationNode = @{ }

        if ($CustomData) {
            ## Add all -CustomData keys/values to the skeleton configuration
            foreach ($key in $CustomData.Keys) {
                $configurationNode[$key] = $CustomData.$key;
            }
        }

        ## Explicitly defined parameters override any -CustomData
        $parameterNames = @('StartupMemory','MinimumMemory','MaximumMemory','SwitchName','Timezone','UILanguage','MACAddress',
            'ProcessorCount','InputLocale','SystemLocale','UserLocale','RegisteredOwner','RegisteredOrganization','SecureBoot')
        foreach ($key in $parameterNames) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $configurationNode[$key] = $PSBoundParameters.$key;
            }
        }

        ## Ensure the specified MediaId is applied after any CustomData media entry!
        $configurationNode['Media'] = $PSBoundParameters.MediaId;

        $currentNodeCount = 0;
        foreach ($vmName in $Name) {

            ## Update the node name before creating the VM
            $configurationNode['NodeName'] = $vmName;
            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'New-LabVM', $vmName;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.CreatingQuickVM -f $vmName, $PSBoundParameters.MediaId);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {
                $currentNodeCount++;
                [System.Int32] $percentComplete = (($currentNodeCount / $Name.Count) * 100) - 1;
                $activity = $localized.ConfiguringNode -f $vmName;
                Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

                $configurationData = @{ AllNodes = @( $configurationNode ) };
                NewLabVM -Name $vmName -ConfigurationData $configurationData -Credential $Credential -NoSnapshot:$NoSnapshot -IsQuickVM;
            }

        } #end foreach name

        if (-not [System.String]::IsNullOrEmpty($activity)) {
            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
        }

    } #end process
} #end function New-LabVM


function Remove-LabVM {
<#
    .SYNOPSIS
        Removes a bare-metal virtual machine and differencing VHD(X).
    .DESCRIPTION
        The Remove-LabVM cmdlet removes a virtual machine and it's VHD(X) file.
#>
    [CmdletBinding(SupportsShouldProcess)]
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
                    $configurationData = @{
                        AllNodes = @(
                            @{  NodeName = $vmName; }
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
