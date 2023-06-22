function New-LabVirtualMachine {
<#
    .SYNOPSIS
        Creates and configures a new lab virtual machine.
    .DESCRIPTION
        Creates an new VM, creating the switch if required, injecting all
        resources and snapshotting as required.
#>
    [CmdletBinding(DefaultParameterSetName = 'PSCredential')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
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
        [System.Management.Automation.SwitchParameter] $IsQuickVM,

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
        if (-not $Credential) {throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

    }
    process {

        $node = Resolve-NodePropertyValue -NodeName $Name -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $nodeName = $node.NodeName;
        ## Display name includes any environment prefix/suffix
        $displayName = $node.NodeDisplayName;

        if (-not (Test-ComputerName -ComputerName $node.NodeName.Split('.')[0])) {

            throw ($localized.InvalidComputerNameError -f $node.NodeName);
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

                Write-Warning -Message ($localized.NoCertificateFoundWarning -f 'Client');
            }

            if (-not [System.String]::IsNullOrWhitespace($node.RootCertificatePath)) {

                $expandedRootCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.RootCertificatePath);
                if (-not (Test-Path -Path $expandedRootCertificatePath -PathType Leaf)) {

                    throw ($localized.CannotFindCertificateError -f 'Root', $node.RootCertificatePath);
                }
            }
            else {

                Write-Warning -Message ($localized.NoCertificateFoundWarning -f 'Root');
            }

        } #end if not quick VM

        $environmentSwitchNames = @();
        foreach ($switchName in $node.SwitchName) {

            ## Retrieve prefixed switch names for VM creation (if necessary)
            $resolveLabSwitchParams = @{
                Name = $switchName;
                ConfigurationData = $ConfigurationData;
                WarningAction = 'SilentlyContinue';
            }
            $networkSwitch = Resolve-LabSwitch @resolveLabSwitchParams;

            Write-Verbose -Message ($localized.SettingVMConfiguration -f 'Virtual Switch', $networkSwitch.Name);
            $environmentSwitchNames += $networkSwitch.Name;

            ## Set-LabSwitch also resolves/prefixes the switch name, so pass the naked name (#251)
            Set-LabSwitch -Name $switchName -ConfigurationData $ConfigurationData;
        }

        if (-not (Test-LabImage -Id $node.Media -ConfigurationData $ConfigurationData)) {

            [ref] $null = New-LabImage -Id $node.Media -ConfigurationData $ConfigurationData;
        }

        Write-Verbose -Message ($localized.ResettingVMConfiguration -f 'VHDX', "$displayName.vhdx");
        $resetLabVMDiskParams = @{
            Name = $displayName;
            NodeName = $nodeName;
            Media = $node.Media;
            ConfigurationData = $ConfigurationData;
        }
        Reset-LabVMDisk @resetLabVMDiskParams -ErrorAction Stop;

        Write-Verbose -Message ($localized.SettingVMConfiguration -f 'VM', $displayName);
        $setLabVirtualMachineParams = @{
            Name = $DisplayName;
            SwitchName = $environmentSwitchNames;
            Media = $node.Media;
            StartupMemory = $node.StartupMemory;
            MinimumMemory = $node.MinimumMemory;
            MaximumMemory = $node.MaximumMemory;
            ProcessorCount = $node.ProcessorCount;
            MACAddress = $node.MACAddress;
            SecureBoot = $node.SecureBoot;
            GuestIntegrationServices = $node.GuestIntegrationServices;
            AutomaticCheckPoints = $node.AutomaticCheckpoints;
            ConfigurationData = $ConfigurationData;
        }

        ## Add VMProcessor, Dvd Drive and additional HDD options
        foreach ($additionalProperty in 'DvdDrive','ProcessorOption','HardDiskDrive') {

            if ($node.ContainsKey($additionalProperty)) {

                $setLabVirtualMachineParams[$additionalProperty] = $node[$additionalProperty];
            }
        }

        Set-LabVirtualMachine @setLabVirtualMachineParams;

        $media = Resolve-LabMedia -Id $node.Media -ConfigurationData $ConfigurationData;
        if (($media.OperatingSystem -eq 'Linux') -or
            ($media.MediaType -eq 'NULL')) {
            ## Skip injecting files for Linux VMs..
        }
        else {

            Write-Verbose -Message ($localized.AddingVMCustomization -f 'VM');
            $setLabVMDiskFileParams = @{
                NodeName = $nodeName;
                ConfigurationData = $ConfigurationData;
                Path = $Path;
                Credential = $Credential;
                CoreCLR = $media.CustomData.SetupComplete -eq 'CoreCLR';
                MaxEnvelopeSizeKb = $node.MaxEnvelopeSizeKb;
            }
            if (-not [System.String]::IsNullOrEmpty($media.CustomData.DefaultShell)) {

                $setLabVMDiskFileParams['DefaultShell'] = $media.CustomData.DefaultShell;
            }

            $resolveCustomBootStrapParams = @{
                CustomBootstrapOrder = $node.CustomBootstrapOrder;
                ConfigurationCustomBootstrap = $node.CustomBootstrap;
                MediaCustomBootStrap = $media.CustomData.CustomBootstrap;
            }

            $customBootstrap = Resolve-LabCustomBootStrap @resolveCustomBootStrapParams;
            if ($customBootstrap) {

                $setLabVMDiskFileParams['CustomBootstrap'] = $customBootstrap;
            }

            if (-not [System.String]::IsNullOrEmpty($media.CustomData.ProductKey)) {

                $setLabVMDiskFileParams['ProductKey'] = $media.CustomData.ProductKey;
            }
            Set-LabVMDiskFile @setLabVMDiskFileParams -FeedCredential $feedCredential;

        } #end Windows VMs

        if (-not $NoSnapshot) {

            $snapshotName = $localized.BaselineSnapshotName -f $labDefaults.ModuleName;
            Write-Verbose -Message ($localized.CreatingBaselineSnapshot -f $snapshotName);
            Hyper-V\Checkpoint-VM -Name $displayName -SnapshotName $snapshotName -Confirm:$false;
        }

        if ($node.WarningMessage) {

            if ($node.WarningMessage -is [System.String]) {

                Write-Warning -Message ($localized.NodeCustomMessageWarning -f $nodeName, $node.WarningMessage.Trim("`n"));
            }
            else {

                Write-Warning -Message ($localized.IncorrectPropertyTypeError -f 'WarningMessage', '[System.String]')
            }
        }

        Write-Output -InputObject (Hyper-V\Get-VM -Name $displayName);

    } #end process
} #end function
