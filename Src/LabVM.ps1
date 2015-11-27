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
        [Parameter(Mandatory)] [System.String] $NodeName,
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        ## Lab DSC configuration data
        [Parameter(Mandatory)] [System.Collections.Hashtable] $ConfigurationData,
        ## Do not enumerate the AllNode.'*'
        [Parameter()] [System.Management.Automation.SwitchParameter] $NoEnumerateWildcardNode
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
        [Parameter(Mandatory)] [System.Object] $ConfigurationData,
        ## Lab VM/Node name
        [Parameter(ValueFromPipeline)] [ValidateNotNullOrEmpty()] [System.String[]] $Name
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
                Write-Output ([PSCustomObject] $vm);
            }
            catch {
                Write-Error ($localized.CannotLocateNodeError -f $nodeName);
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
        [Parameter(Mandatory)] [System.Object] $ConfigurationData,
        ## Lab VM/Node name
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String[]] $Name
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        if (-not $Name) {
            $Name = $ConfigurationData.AllNodes | Where NodeName -ne '*' | ForEach-Object { $_.NodeName }
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
            Write-Output $isNodeCompliant;
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
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory)] [System.Collections.Hashtable] $ConfigurationData,
        
        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ParameterSetName = 'PSCredential')] [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential = (& $credentialCheckScriptBlock),
        
        ## Local administrator password of the VM.
        [Parameter(Mandatory, ParameterSetName = 'Password')] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
        
        ## Virtual machine DSC .mof and .meta.mof location
        [Parameter()] [System.String] $Path = (GetLabHostDSCConfigurationPath),
        ## Skip creating baseline snapshots
        [Parameter()] [System.Management.Automation.SwitchParameter] $NoSnapshot
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

        WriteVerbose ($localized.ResettingVMConfiguration -f 'VHDX', $node.Media);
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
        SetLabVMDiskFile @setLabVMDiskFileParams;

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

        Write-Output (Get-VM -Name $Name);
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
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory)] [Object] $ConfigurationData,
        ## Include removal of virtual switch(es). By default virtual switches are not removed.
        [Parameter()] [System.Management.Automation.SwitchParameter] $RemoveSwitch
    )
    process {
        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode -ErrorAction Stop;
        if (-not $node.NodeName) {
            throw ($localized.CannotLocateNodeError -f $Name);
        }
        $Name = $node.NodeName;
        
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
    [CmdletBinding(DefaultParameterSetName = 'PSCredential')]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory)] [System.Object] $ConfigurationData,
        
        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ParameterSetName = 'PSCredential')] [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential = (& $credentialCheckScriptBlock),
        
        ## Local administrator password of the VM.
        [Parameter(Mandatory, ParameterSetName = 'Password')] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,
        
        ## Directory path containing the VM .mof file(s)
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Path = (GetLabHostDSCConfigurationPath),
        ## Skip creating baseline snapshots
        [Parameter()] [System.Management.Automation.SwitchParameter] $NoSnapshot
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
            RemoveLabVM -Name $vmName -ConfigurationData $ConfigurationData;
            NewLabVM -Name $vmName -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot -Credential $Credential;
        }
    } #end process    
} #end function Reset-LabVM
