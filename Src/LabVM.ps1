function ResolveLabVMProperties {
<#
    .SYNOPSIS
        Resolve lab VM properties.
    .DESCRIPTION
        Resolves a lab virtual machine properties, using VM-specific properties over-and-above
        the AllNodes.NodeName '*' and lab defaults.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $NodeName,
        
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $ConfigurationData,
        
        ## Do not enumerate the AllNode.'*'
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
        $labDefaultProperties = GetConfigurationData -Configuration VM;
        $properties = Get-Member -InputObject $labDefaultProperties -MemberType NoteProperty;
        foreach ($propertyName in $properties.Name) {
            ## Int32 values of 0 get coerced into $false!
            if (($node.$propertyName -isnot [System.Int32]) -and (-not $node.$propertyName)) {
                $node[$propertyName] = $labDefaultProperties.$propertyName;
            }
        }

        ## Rename/overwrite existing parameter values where $moduleName-specific parameters exist
        foreach ($key in @($node.Keys)) {
            if ($key.StartsWith("$($labDefaults.ModuleName)_")) {
                $node[($key.Replace("$($labDefaults.ModuleName)_",''))] = $node.$key;
            }
        }

        ## Default to SecureBoot On/$true unless otherwise specified
        ## TODO: Should this not be added to the LabVMDefaults?
        if (($null -ne $node.SecureBoot) -and ($node.SecureBoot -eq $false)) { $node['SecureBoot'] = $false; }
        else { $node['SecureBoot'] = $true; }

        return $node;
    } #end process
} #end function Resolve-LabProperty

function Get-LabVM {
<#
    .SYNOPSIS
        Retrieves the current configuration of a VM.
    .DESCRIPTION
        Gets a virtual machine configuration using the xVMHyperV DSC resource.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Object] $ConfigurationData,
        
        ## Lab VM/Node name
        [Parameter(ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        if (-not $Name) {
            # Return all nodes defined in the configuration
            $Name = $ConfigurationData.AllNodes | Where-Object NodeName -ne '*' | ForEach-Object { $_.NodeName; }
        }
        
        foreach ($nodeName in $Name) {
            $xVMParams = @{
                Name = $nodeName;
                VhdPath = ResolveLabVMDiskPath -Name $nodeName;
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
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Object] $ConfigurationData,
        
        ## Lab VM/Node name
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        if (-not $Name) {
            $Name = $ConfigurationData.AllNodes | Where-Object NodeName -ne '*' | ForEach-Object { $_.NodeName }
        }
        foreach ($vmName in $Name) {
            $isNodeCompliant = $true;
            WriteVerbose ($localized.TestingNodeConfiguration -f $vmName);
            $node = ResolveLabVMProperties -NodeName $vmName -ConfigurationData $ConfigurationData;
            [ref] $null = $node.Remove('NodeName');

            WriteVerbose ($localized.TestingVMConfiguration -f 'Image', $node.Media);
            if (-not (Test-LabImage -Id $node.Media)) {
                $isNodeCompliant = $false;
            }
            WriteVerbose ($localized.TestingVMConfiguration -f 'Virtual Switch', $node.SwitchName);
            if (-not (TestLabSwitch -Name $node.SwitchName -ConfigurationData $ConfigurationData)) {
                $isNodeCompliant = $false;
            }
            WriteVerbose ($localized.TestingVMConfiguration -f 'VHDX', $node.Media);
            if (-not (TestLabVMDisk -Name $vmName -Media $node.Media -ErrorAction SilentlyContinue)) {
                $isNodeCompliant = $false;
            }
            WriteVerbose ($localized.TestingVMConfiguration -f 'VM', $vmName);
            $testLabVirtualMachineParams = @{
                SwitchName = $node.SwitchName;
                Media = $node.Media;
                StartupMemory = $node.StartupMemory;
                MinimumMemory = $node.MinimumMemory;
                MaximumMemory = $node.MaximumMemory;
                ProcessorCount = $node.ProcessorCount;
                MACAddress = $node.MACAddress;
                SecureBoot = $node.SecureBoot;
            }
            if (-not (TestLabVirtualMachine @testLabVirtualMachineParams -Name $vmName)) {
                $isNodeCompliant = $false;
            }
            Write-Output -InputObject $isNodeCompliant;
        }
    } #end process
} #end function Test-LabVM

function NewLabVM {
<#
    .SYNOPSIS
        Creates a new lab virtual machine is configured as required.
#>
    [CmdletBinding(DefaultParameterSetName = 'PSCredential')]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] [System.String] $Name,
        
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $ConfigurationData,
        
        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PSCredential')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential = (& $credentialCheckScriptBlock),
        
        ## Local administrator password of the VM.
        [Parameter(Mandatory, ParameterSetName = 'Password', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
        
        ## Virtual machine DSC .mof and .meta.mof location
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),
        
        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot,

        ## Is a quick VM
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $IsQuickVM
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
        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $Name = $node.NodeName;
        [ref] $null = $node.Remove('NodeName');

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

            if (-not (Test-LabImage -Id $node.Media)) {
                [ref] $null = New-LabImage -Id $node.Media -ConfigurationData $ConfigurationData;
            }

            WriteVerbose ($localized.SettingVMConfiguration -f 'Virtual Switch', $node.SwitchName);
            SetLabSwitch -Name $node.SwitchName -ConfigurationData $ConfigurationData;
        } #end if not quick VM

        WriteVerbose ($localized.ResettingVMConfiguration -f 'VHDX', "$Name.vhdx");
        ResetLabVMDisk -Name $Name -Media $node.Media -ErrorAction Stop;

        WriteVerbose ($localized.SettingVMConfiguration -f 'VM', $Name);
        $setLabVirtualMachineParams = @{
            Name = $Name;
            SwitchName = $node.SwitchName;
            Media = $node.Media;
            StartupMemory = $node.StartupMemory;
            MinimumMemory = $node.MinimumMemory;
            MaximumMemory = $node.MaximumMemory;
            ProcessorCount = $node.ProcessorCount;
            SecureBoot = $node.SecureBoot;
        }
        SetLabVirtualMachine @setLabVirtualMachineParams;
        
        ## Only mount the VHDX to copy resources if needed!
        if ($node.Resource) {
            WriteVerbose ($localized.AddingVMResource -f 'VM');
            SetLabVMDiskResource -ConfigurationData $ConfigurationData -Name $Name;
        }

        WriteVerbose ($localized.AddingVMCustomization -f 'VM'); ## DSC resources and unattend.xml
        $setLabVMDiskFileParams = @{
            Name = $Name;
            NodeData = $node;
            Path = $Path;
            Credential = $Credential;
        }
        if ($node.CustomBootStrap) {
            $setLabVMDiskFileParams['CustomBootStrap'] = ($node.CustomBootStrap).ToString();
        }
        SetLabVMDiskFile @setLabVMDiskFileParams -IsQuickVM:$IsQuickVM;

        if (-not $NoSnapshot) {
            $snapshotName = $localized.BaselineSnapshotName -f $labDefaults.ModuleName;
            WriteVerbose ($localized.CreatingBaselineSnapshot -f $snapshotName);
            Checkpoint-VM -Name $Name -SnapshotName $snapshotName;
        }

        if ($node.WarningMessage) {
            if ($node.WarningMessage -is [System.String]) {
                WriteWarning ($localized.NodeCustomMessageWarning -f $Name, $node.WarningMessage);
            }
            else {
                WriteWarning ($localized.IncorrectPropertyTypeError -f 'WarningMessage', '[System.String]')
            }
        }

        Write-Output -InputObject (Get-VM -Name $Name);
    } #end process
} #end function NewLabVM

function RemoveLabVM {
    <#
            .SYNOPSIS
            Deletes a lab virtual machine.
    #>
    [CmdletBinding()]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] [System.String] $Name,
        
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Object] $ConfigurationData,
        
        ## Include removal of virtual switch(es). By default virtual switches are not removed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $RemoveSwitch
    )
    process {
        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode -ErrorAction Stop;
        if (-not $node.NodeName) {
            throw ($localized.CannotLocateNodeError -f $Name);
        }
        $Name = $node.NodeName;
        
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
            ProcessorCount = $node.ProcessorCount;
        }
        RemoveLabVirtualMachine @removeLabVirtualMachineParams;

        WriteVerbose ($localized.RemovingNodeConfiguration -f 'VHDX', $node.Media);
        RemoveLabVMDisk -Name $Name -Media $node.Media -ErrorAction Stop;

        if ($RemoveSwitch) {
            WriteVerbose ($localized.RemovingNodeConfiguration -f 'Virtual Switch', $node.SwitchName);
            RemoveLabSwitch -Name $node.SwitchName -ConfigurationData $ConfigurationData;
        }
    } #end process    
} #end function RemoveLabVM

function Reset-LabVM {
<#
    .SYNOPSIS
        Deletes and recreates a lab virtual machine, reapplying the MOF
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'PSCredential')]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,
        
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Object] $ConfigurationData,
        
        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PSCredential')] [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential = (& $credentialCheckScriptBlock),
        
        ## Local administrator password of the VM.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Password')] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
        
        ## Directory path containing the VM .mof file(s)
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),
        
        ## Skip creating baseline snapshots
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
        
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        foreach ($vmName in $Name) {
            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Reset-LabVM', $vmName;
            $verboseProcessMessage = $localized.ResettingVM -f $vmName;
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {
                RemoveLabVM -Name $vmName -ConfigurationData $ConfigurationData;
                NewLabVM -Name $vmName -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot -Credential $Credential;
            } #end if should process
        } #end foreach VM
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
    .LINK
        Register-LabMedia
        Unregister-LabMedia
        Get-LabVMDefault
        Set-LabVMDefault
#>
    [CmdletBinding(DefaultParameterSetName = 'PSCredential')]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Default virtual machine startup memory (bytes).
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $StartupMemory,
        
        ## Default virtual machine miniumum dynamic memory allocation (bytes).        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MinimumMemory,
        
        ## Default virtual machine maximum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MaximumMemory,
        
        ## Default virtual machine processor count.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(1, 4)]
        [System.Int32] $ProcessorCount,

        # Input Locale
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^([a-z]{2,2}-[a-z]{2,2})|(\d{4,4}:\d{8,8})$')]
        [System.String] $InputLocale,
        
        # System Locale
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $SystemLocale,
        
        # User Locale
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UserLocale,
        
        # UI Language
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UILanguage,
        
        # Timezone
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $Timezone,
        
        # Registered Owner
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $RegisteredOwner,
        
        # Registered Organization
        [Parameter(ValueFromPipelineByPropertyName)] [Alias('RegisteredOrganisation')] 
        [ValidateNotNullOrEmpty()] [System.String] $RegisteredOrganization,
        
        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PSCredential')] [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential = (& $credentialCheckScriptBlock),
        
        ## Local administrator password of the VM.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Password')] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
        
        ## Virtual machine switch name.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String[]] $SwitchName,
        
        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)] [System.Management.Automation.SwitchParameter] $NoSnapshot
    )
    DynamicParam {
        ## Adds a dynamic -Id parameter that returns the registered media Ids
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

        ## Test VM Switch exists
        foreach ($switch in $SwitchName) {
            if (-not (Get-VMSwitch -Name $switch -ErrorAction SilentlyContinue)) {
                throw ($localized.SwitchDoesNotExistError -f $switch);
            }
        }
    }
    process {
        foreach ($vmName in $Name) {
            ## Create a skelton config data
            $skeletonConfigurationData = @{
                AllNodes = @(
                    @{  NodeName = $vmName; "$($labDefaults.ModuleName)_Media" = $PSBoundParameters.MediaId; }
                )
            };

            $parameterNames = @('StartupMemory','MinimumMemory','MaximumMemory','SwitchName','Timezone','UILanguage',
                'ProcessorCount','InputLocale','SystemLocale','UserLocale','RegisteredOwner','RegisteredOrganization')
            foreach ($key in $parameterNames) {
                if ($PSBoundParameters.ContainsKey($key)) {
                    $configurationName = '{0}_{1}' -f $labDefaults.ModuleName, $key;
                    [ref] $null = $skeletonConfigurationData.AllNodes[0].Add($configurationname, $PSBoundParameters.$key);        
                }
            }
            WriteVerbose -Message ($localized.CreatingQuickVM -f $vmName, $PSBoundParameters.MediaId);
            NewLabVM -Name $vmName -ConfigurationData $skeletonConfigurationData -Credential $Credential -NoSnapshot:$NoSnapshot -IsQuickVM;
        } #end foreach name
    } #end process
} #end function New-LabVM

function Remove-LabVM {
<#
    .SYNOPSIS
        Removes one or more lab virtual machines and differencing VHD(X)s.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] [System.String[]] $Name
    )
    process {
        foreach ($vmName in $Name) {
            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Remove-LabVM', $vmName;
            $verboseProcessMessage = $localized.RemovingQuickVM -f $vmName;
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {
                ## Create a skelton config data
                $skeletonConfigurationData = @{
                    AllNodes = @(
                        @{  NodeName = $vmName; }
                    )
                };
                RemoveLabVM -Name $vmName -ConfigurationData $skeletonConfigurationData; 
            } #end if should process
        } #end foreach VM
    } #end process
} #end function Remove-LabVM
