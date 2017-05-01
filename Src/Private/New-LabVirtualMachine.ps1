function New-LabVirtualMachine {
<#
    .SYNOPSIS
        Creates and configures a new lab virtual machine.
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
        [System.String] $Path = (Get-LabHostDscConfigurationPath),

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
        $nodeName = $node.NodeName;
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
        $resetLabVMDiskParams = @{
            Name = $displayName;
            NodeName = $nodeName;
            Media = $node.Media;
            ConfigurationData = $ConfigurationData;
        }
        Reset-LabVMDisk @resetLabVMDiskParams -ErrorAction Stop;

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

        ## Add VMProcessor, Dvd Drive and additional HDD options
        foreach ($additionalProperty in 'DvdDrive','ProcessorOption','HardDiskDrive') {

            if ($node.ContainsKey($additionalProperty)) {

                $setLabVirtualMachineParams[$additionalProperty] = $node[$additionalProperty];
            }
        }

        Set-LabVirtualMachine @setLabVirtualMachineParams;

        $media = ResolveLabMedia -Id $node.Media -ConfigurationData $ConfigurationData;
        if ($media.OperatingSystem -eq 'Linux') {
            ## Skip injecting files for Linux VMs..
        }
        else {

            WriteVerbose ($localized.AddingVMCustomization -f 'VM');
            $setLabVMDiskFileParams = @{
                NodeName = $nodeName;
                ConfigurationData = $ConfigurationData;
                Path = $Path;
                Credential = $Credential;
                CoreCLR = $media.CustomData.SetupComplete -eq 'CoreCLR';
            }
            if (-not [System.String]::IsNullOrEmpty($media.CustomData.DefaultShell)) {

                $setLabVMDiskFileParams['DefaultShell'] = $media.CustomData.DefaultShell;
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

                WriteWarning ($localized.NodeCustomMessageWarning -f $nodeName, $node.WarningMessage.Trim("`n"));
            }
            else {

                WriteWarning ($localized.IncorrectPropertyTypeError -f 'WarningMessage', '[System.String]')
            }
        }

        Write-Output -InputObject (Get-VM -Name $displayName);

    } #end process
} #end function