function SetLabVMDiskDscResource {
<#
    .SYNOPSIS
        Copies the local DSC resources to a VHDX file.
#>
    [CmdletBinding()]
    param (
        ## The target VHDX modules path
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $DestinationPath
    )
    process {
        $dscResourceModules = GetDscResourceModule -Path "$env:ProgramFiles\WindowsPowershell\Modules";
        foreach ($dscResourceModule in $dscResourceModules) {
            $targetModulePath = '{0}\{1}' -f $Destinationpath, $dscResourceModule.ModuleName;
            ## Check if path already exists and remove if necessary as it may be the wrong DSC resource version
            if (Test-Path -Path $targetModulePath -PathType Container) {
                WriteWarning -Message ($localized.RemovingDSCResourceModule -f $targetModulePath);
                Remove-Item -Path $targetModulePath -Recurse -Force -Confirm:$false;
            }
            WriteVerbose ($localized.AddingDSCResource -f $dscResourceModule.ModuleName, $dscResourceModule.ModuleVersion);
            Copy-Item -Path $dscResourceModule.Path -Destination $targetModulePath -Recurse -Force;
        }
    } #end process
} #end function SetLabVMDiskDscResource

function SetLabVMDiskResource {
<#
    .SYNOPSIS
        Copies lab resources to a VHDX file.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $NodeName,

        ## Prefixed/suffixed lab VM/Node name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $DisplayName
    )
    begin {
        $hostDefaults = GetConfigurationData -Configuration Host;
    }
    process {
        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-Service -Name 'ShellHWDetection' -Force -ErrorAction Ignore;

        $vhdPath = ResolveLabVMDiskPath -Name $DisplayName;
        WriteVerbose ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Mount-Vhd -Path $vhdPath -Passthru;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Get-Partition -DiskNumber $vhd.DiskNumber | Where-Object DriveLetter | Select-Object -Last 1 -ExpandProperty DriveLetter;
        Start-Service -Name 'ShellHWDetection';

        $destinationPath = '{0}:\{1}' -f $vhdDriveLetter, $hostDefaults.ResourceShareName;
        ExpandLabResource -ConfigurationData $ConfigurationData -Name $NodeName -DestinationPath $destinationPath;

        WriteVerbose ($localized.DismountingDiskImage -f $VhdPath);
        Dismount-Vhd -Path $VhdPath;
    } #end process
} #end function SetLabVMDiskResource

function SetLabVMDiskFile {
<#
    .SYNOPSIS
        Copies one or more files to a VHDX file.
#>
    [CmdletBinding()]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Lab VM/Node configuration data
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $NodeData,

        ## Local administrator password of the VM
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Lab VM/Node DSC .mof and .meta.mof configuration files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootstrap,

        ## CoreCLR
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR
    )
    process {
        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-Service -Name 'ShellHWDetection' -Force -ErrorAction Ignore;

        $vhdPath = ResolveLabVMDiskPath -Name $NodeData.NodeDisplayName;
        WriteVerbose ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Mount-Vhd -Path $vhdPath -Passthru;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Get-Partition -DiskNumber $vhd.DiskNumber |
                            Where-Object DriveLetter |
                                Select-Object -Last 1 -ExpandProperty DriveLetter;
        Start-Service -Name 'ShellHWDetection';

        ## Create Unattend.xml
        $newUnattendXmlParams = @{
            ComputerName = $NodeData.NodeName;
            Credential = $Credential;
            InputLocale = $NodeData.InputLocale;
            SystemLocale = $NodeData.SystemLocale;
            UserLocale = $NodeData.UserLocale;
            UILanguage = 'en-US';
            Timezone = $NodeData.Timezone;
            RegisteredOwner = $NodeData.RegisteredOwner;
            RegisteredOrganization = $NodeData.RegisteredOrganization;
        }
        WriteVerbose ($localized.SettingAdministratorPassword -f $Credential.GetNetworkCredential().Password);
        if ($NodeData.CustomData.ProductKey) {
            $newUnattendXmlParams['ProductKey'] = $NodeData.CustomData.ProductKey;
        }
        ## TODO: We probably need to be localise the \Windows\ and \Program Files\ directories?
        $unattendXmlPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $vhdDriveLetter;
        WriteVerbose ($localized.AddingUnattendXmlFile -f $unattendXmlPath);
        [ref] $null = SetUnattendXml @newUnattendXmlParams -Path $unattendXmlPath;

        $destinationPath = '{0}:\Program Files\WindowsPowershell\Modules' -f $vhdDriveLetter;
        WriteVerbose ($localized.AddingDSCResourceModules -f $destinationPath);
        SetLabVMDiskDscResource -DestinationPath $destinationPath;

        $bootStrapPath = '{0}:\BootStrap' -f $vhdDriveLetter;
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

        ## Copy MOF files to \BootStrap\localhost.mof and \BootStrap\localhost.meta.mof
        if ($Path) {
            $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $NodeData.NodeName);
            $destinationMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.mof';
            WriteVerbose ($localized.AddingDscConfiguration -f $destinationMofPath);
            if (-not (Test-Path -Path $mofPath)) { WriteWarning ($localized.CannotLocateMofFileError -f $mofPath); }
            else { Copy-Item -Path $mofPath -Destination $destinationMofPath -Force -ErrorAction Stop; }

            $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $NodeData.NodeName);
            if (Test-Path -Path $metaMofPath -PathType Leaf) {
                $destinationMetaMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.meta.mof';
                WriteVerbose ($localized.AddingDscConfiguration -f $destinationMetaMofPath);
                Copy-Item -Path $metaMofPath -Destination $destinationMetaMofPath -Force;
            }
        }

        ## Copy certificates
        if (-not [System.String]::IsNullOrWhitespace($NodeData.ClientCertificatePath)) {
            $destinationCertificatePath = Join-Path -Path $bootStrapPath -ChildPath 'LabClient.pfx';
            $expandedClientCertificatePath = [System.Environment]::ExpandEnvironmentVariables($NodeData.ClientCertificatePath);
            WriteVerbose ($localized.AddingCertificate -f 'Client', $destinationCertificatePath);
            Copy-Item -Path $expandedClientCertificatePath -Destination $destinationCertificatePath -Force;
        }
        if (-not [System.String]::IsNullOrWhitespace($NodeData.RootCertificatePath)) {
            $destinationCertificatePath = Join-Path -Path $bootStrapPath -ChildPath 'LabRoot.cer';
            $expandedRootCertificatePath = [System.Environment]::ExpandEnvironmentVariables($NodeData.RootCertificatePath);
            WriteVerbose ($localized.AddingCertificate -f 'Root', $destinationCertificatePath);
            Copy-Item -Path $expandedRootCertificatePath -Destination $destinationCertificatePath -Force;
        }

        WriteVerbose ($localized.DismountingDiskImage -f $VhdPath);
        Dismount-Vhd -Path $VhdPath;
    } #end process
} #end function SetLabVMDiskFile
