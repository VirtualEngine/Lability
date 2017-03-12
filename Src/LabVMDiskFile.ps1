function SetLabVMDiskModule {
<#
    .SYNOPSIS
        Downloads (if required) PowerShell/DSC modules and expands
        them to the destination path specified.
#>
    [CmdletBinding()]
    param (
        ## Lability PowerShell modules/DSC resource hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable[]] $Module,

        ## The target VHDX modules path
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $DestinationPath,

        ## Force a download of the module(s) even if they already exist in the cache.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Removes existing target module directory (if present)
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Clean
    )
    process {

        ## Invokes the module download if not cached, and returns the source
        [ref] $null = InvokeModuleCacheDownload -Module $Module -Force:$Force
        ## Expand the modules into the VHDX file
        [ref] $null = ExpandModuleCache -Module $Module -DestinationPath $DestinationPath -Clean:$Clean;

    } #end process
} #end function SetLabVMDiskModule


function SetLabVMDiskFileResource {
<#
    .SYNOPSIS
        Copies a node's defined resources to VHD(X) file.
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

        $hostDefaults = Get-ConfigurationData -Configuration Host;
        $resourceDestinationPath = '{0}:\{1}' -f $vhdDriveLetter, $hostDefaults.ResourceShareName;
        $expandLabResourceParams = @{
            ConfigurationData = $ConfigurationData;
            Name = $NodeName;
            DestinationPath = $resourceDestinationPath;
        }
        WriteVerbose -Message ($localized.AddingVMResource -f 'VM');
        ExpandLabResource @expandLabResourceParams;

    } #end process
} #end function SetLabVMDiskFileResource


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
        $resolveLabModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'DscResource';
        }
        $setLabVMDiskDscModuleParams = @{
            Module = Resolve-LabModule @resolveLabModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskDscModuleParams['Module']) {

            WriteVerbose -Message ($localized.AddingDSCResourceModules -f $programFilesPath);
            SetLabVMDiskModule @setLabVMDiskDscModuleParams;
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

            WriteVerbose -Message ($localized.AddingPowerShellModules -f $programFilesPath);
            SetLabVMDiskModule @setLabVMDiskPowerShellModuleParams;
        }

    } #end process
} #end function SetLabVMDiskFileModule


function SetLabVMDiskFileUnattendXml {
<#
    .SYNOPSIS
        Copies a node's unattent.xml to a VHD(X) file.
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

        ## Local administrator password of the VM
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Media-defined product key
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $ProductKey,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $node = Resolve-NodePropertyValue -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;

        ## Create Unattend.xml
        $newUnattendXmlParams = @{
            ComputerName = $node.NodeName;
            Credential = $Credential;
            InputLocale = $node.InputLocale;
            SystemLocale = $node.SystemLocale;
            UserLocale = $node.UserLocale;
            UILanguage = 'en-US';
            Timezone = $node.Timezone;
            RegisteredOwner = $node.RegisteredOwner;
            RegisteredOrganization = $node.RegisteredOrganization;
        }
        WriteVerbose -Message $localized.SettingAdministratorPassword;

        ## Node defined Product Key takes preference over key defined in the media definition
        if ($node.CustomData.ProductKey) {

            $newUnattendXmlParams['ProductKey'] = $node.CustomData.ProductKey;
        }
        elseif ($PSBoundParameters.ContainsKey('ProductKey')) {

            $newUnattendXmlParams['ProductKey'] = $ProductKey;
        }

        ## TODO: We probably need to be localise the \Windows\ (%ProgramFiles% has been done) directory?
        $unattendXmlPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $VhdDriveLetter;
        WriteVerbose -Message ($localized.AddingUnattendXmlFile -f $unattendXmlPath);
        [ref] $null = SetUnattendXml @newUnattendXmlParams -Path $unattendXmlPath;

    } #end process
} #end function SetLabVMDiskFileUnattendXml


function SetLabVMDiskFileBootstrap {
<#
    .SYNOPSIS
        Copies a the Lability bootstrap file to a VHD(X) file.
#>

    [CmdletBinding()]
    param (
        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VhdDriveLetter,

        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootstrap,

        ## CoreCLR
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom/replacement shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DefaultShell,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;
        WriteVerbose -Message ($localized.AddingBootStrapFile -f $bootStrapPath);
        $setBootStrapParams = @{
            Path = $bootStrapPath;
            CoreCLR = $CoreCLR;
        }
        if ($CustomBootStrap) {

            $setBootStrapParams['CustomBootStrap'] = $CustomBootStrap;
        }
        if ($PSBoundParameters.ContainsKey('DefaultShell')) {

            WriteVerbose -Message ($localized.SettingCustomShell -f $DefaultShell);
            $setBootStrapParams['DefaultShell'] = $DefaultShell;
        }
        SetBootStrap @setBootStrapParams;

        $setupCompleteCmdPath = '{0}:\Windows\Setup\Scripts' -f $vhdDriveLetter;
        WriteVerbose -Message ($localized.AddingSetupCompleteCmdFile -f $setupCompleteCmdPath);
        SetSetupCompleteCmd -Path $setupCompleteCmdPath -CoreCLR:$CoreCLR;

    } #end process
} #end function SetLabVMDiskFileBootstrap


function SetLabVMDiskFileMof {
<#
    .SYNOPSIS
        Copies a node's mof files to a VHD(X) file.
#>
    [CmdletBinding()]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $NodeName,

        ## Lab VM/Node DSC .mof and .meta.mof configuration files
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VhdDriveLetter,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;
        $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $NodeName);

        if (-not (Test-Path -Path $mofPath)) {

            WriteWarning -Message ($localized.CannotLocateMofFileError -f $mofPath);
        }
        else {

            $destinationMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.mof';
            WriteVerbose -Message ($localized.AddingDscConfiguration -f $destinationMofPath);
            Copy-Item -Path $mofPath -Destination $destinationMofPath -Force -ErrorAction Stop -Confirm:$false;
        }

        $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $NodeName);
        if (Test-Path -Path $metaMofPath -PathType Leaf) {

            $destinationMetaMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.meta.mof';
            WriteVerbose -Message ($localized.AddingDscConfiguration -f $destinationMetaMofPath);
            Copy-Item -Path $metaMofPath -Destination $destinationMetaMofPath -Force -Confirm:$false;
        }

    } #end process
} #end function SetLabVMDiskFileMof


function SetLabVMDiskFileCertificate {
<#
    .SYNOPSIS
        Copies a node's certificate(s) to a VHD(X) file.
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

        $node = Resolve-NodePropertyValue -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;

        if (-not [System.String]::IsNullOrWhitespace($node.ClientCertificatePath)) {

            [ref] $null = New-Item -Path $bootStrapPath -ItemType File -Name 'LabClient.pfx' -Force;
            $destinationCertificatePath = Join-Path -Path $bootStrapPath -ChildPath 'LabClient.pfx';
            $expandedClientCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.ClientCertificatePath);
            WriteVerbose -Message ($localized.AddingCertificate -f 'Client', $destinationCertificatePath);
            Copy-Item -Path $expandedClientCertificatePath -Destination $destinationCertificatePath -Force -Confirm:$false;
        }

        if (-not [System.String]::IsNullOrWhitespace($node.RootCertificatePath)) {

            [ref] $null = New-Item -Path $bootStrapPath -ItemType File -Name 'LabRoot.cer' -Force;
            $destinationCertificatePath = Join-Path -Path $bootStrapPath -ChildPath 'LabRoot.cer';
            $expandedRootCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.RootCertificatePath);
            WriteVerbose -Message ($localized.AddingCertificate -f 'Root', $destinationCertificatePath);
            Copy-Item -Path $expandedRootCertificatePath -Destination $destinationCertificatePath -Force -Confirm:$false;
        }

    } #end process
} #end functionSetLabVMDiskFileCertificate
