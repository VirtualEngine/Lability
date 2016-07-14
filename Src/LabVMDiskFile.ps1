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

        $hostDefaults = GetConfigurationData -Configuration Host;
        $resourceDestinationPath = '{0}:\{1}' -f $vhdDriveLetter, $hostDefaults.ResourceShareName;
        $expandLabResourceParams = @{
            ConfigurationData = $ConfigurationData;
            Name = $NodeName;
            DestinationPath = $resourceDestinationPath;
        }
        WriteVerbose ($localized.AddingVMResource -f 'VM');
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
        $resolveLabDscModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'DscResource';
        }
        $setLabVMDiskDscModuleParams = @{
            Module = ResolveLabModule @resolveLabDscModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskDscModuleParams['Module']) {
            WriteVerbose ($localized.AddingDSCResourceModules -f $programFilesPath);
            SetLabVMDiskModule @setLabVMDiskDscModuleParams;
        }

        ## Add the PowerShell resource modules
        $resolveLabPowerShellModuleParams =@{
            ConfigurationData = $ConfigurationData;
            NodeName = $NodeName;
            ModuleType = 'Module';
        }
        $setLabVMDiskPowerShellModuleParams = @{
            Module = ResolveLabModule @resolveLabPowerShellModuleParams;
            DestinationPath = $programFilesPath;
        }
        if ($null -ne $setLabVMDiskPowerShellModuleParams['Module']) {
            WriteVerbose ($localized.AddingPowerShellModules -f $programFilesPath);
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

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $node = ResolveLabVMProperties -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;

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
        WriteVerbose ($localized.SettingAdministratorPassword -f $Credential.GetNetworkCredential().Password);
        if ($node.CustomData.ProductKey) {
            $newUnattendXmlParams['ProductKey'] = $node.CustomData.ProductKey;
        }
        ## TODO: We probably need to be localise the \Windows\ (%ProgramFiles% has been done) directory?
        $unattendXmlPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $VhdDriveLetter;
        WriteVerbose ($localized.AddingUnattendXmlFile -f $unattendXmlPath);
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
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootstrap,

        ## CoreCLR
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;
        WriteVerbose ($localized.AddingBootStrapFile -f $bootStrapPath);
        if ($CustomBootStrap) {
            SetBootStrap -Path $bootStrapPath -CustomBootStrap $CustomBootStrap -CoreCLR:$CoreCLR;
        }
        else {
            SetBootStrap -Path $bootStrapPath -CoreCLR:$CoreCLR;
        }

        $setupCompleteCmdPath = '{0}:\Windows\Setup\Scripts' -f $vhdDriveLetter;
        WriteVerbose ($localized.AddingSetupCompleteCmdFile -f $setupCompleteCmdPath);
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
            WriteWarning ($localized.CannotLocateMofFileError -f $mofPath);
        }
        else {
            WriteVerbose ($localized.AddingDscConfiguration -f $destinationMofPath);
            $destinationMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.mof';
            Copy-Item -Path $mofPath -Destination $destinationMofPath -Force -ErrorAction Stop;
        }

        $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $NodeName);
        if (Test-Path -Path $metaMofPath -PathType Leaf) {
            $destinationMetaMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.meta.mof';
            WriteVerbose ($localized.AddingDscConfiguration -f $destinationMetaMofPath);
            Copy-Item -Path $metaMofPath -Destination $destinationMetaMofPath -Force;
        }

    } #end process
} #end function SetLabVMDiskFileBootstrap


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

        $node = ResolveLabVMProperties -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;

        if (-not [System.String]::IsNullOrWhitespace($node.ClientCertificatePath)) {
            $destinationCertificatePath = Join-Path -Path $bootStrapPath -ChildPath 'LabClient.pfx';
            $expandedClientCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.ClientCertificatePath);
            WriteVerbose ($localized.AddingCertificate -f 'Client', $destinationCertificatePath);
            Copy-Item -Path $expandedClientCertificatePath -Destination $destinationCertificatePath -Force;
        }

        if (-not [System.String]::IsNullOrWhitespace($node.RootCertificatePath)) {
            $destinationCertificatePath = Join-Path -Path $bootStrapPath -ChildPath 'LabRoot.cer';
            $expandedRootCertificatePath = [System.Environment]::ExpandEnvironmentVariables($node.RootCertificatePath);
            WriteVerbose ($localized.AddingCertificate -f 'Root', $destinationCertificatePath);
            Copy-Item -Path $expandedRootCertificatePath -Destination $destinationCertificatePath -Force;
        }

    } #end process
} #end function SetLabVMDiskFileBootstrap


function SetLabVMDiskFile {
<#
    .SYNOPSIS
        Copies Lability files to a node's VHD(X) file.
    .DESCRIPTION
        Copies the Lability bootstrap file, SetupComplete.cmd, unattend.xml,
        mof files, certificates and PowerShell/DSC resource modules to a
        VHD(X) file.
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

        ## Local administrator password of the VM
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Lab VM/Node DSC .mof and .meta.mof configuration files
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootstrap,

        ## CoreCLR
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR
    )
    process {

        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-Service -Name 'ShellHWDetection' -Force -ErrorAction Ignore;

        $node = ResolveLabVMProperties -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $vhdPath = ResolveLabVMDiskPath -Name $node.NodeDisplayName;

        WriteVerbose ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Mount-Vhd -Path $vhdPath -Passthru;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Get-Partition -DiskNumber $vhd.DiskNumber |
                            Where-Object DriveLetter |
                                Select-Object -Last 1 -ExpandProperty DriveLetter;
        Start-Service -Name 'ShellHWDetection';

        SetLabVMDiskFileResource @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
        SetLabVMDiskFileBootstrap @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
        SetLabVMDiskFileUnattendXml @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
        SetLabVMDiskFileMof @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
        SetLabVMDiskFileCertificate @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
        SetLabVMDiskFileModule @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;

        WriteVerbose ($localized.DismountingDiskImage -f $VhdPath);
        Dismount-Vhd -Path $VhdPath;

    } #end process
} #end function SetLabVMDiskFile
