function SetLabVMDiskResource {
<#
    .SYNOPSIS
        Copies lab resources to a VHDX file.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData,
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)] [System.String] $Name
    )
    begin {
        $hostDefaults = GetConfigurationData -Configuration Host;
    }
    process {
        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-Service -Name 'ShellHWDetection' -Force;

        $vhdPath = ResolveLabVMDiskPath -Name $Name;
        WriteVerbose ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Mount-Vhd -Path $vhdPath -Passthru;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Get-Partition -DiskNumber $vhd.DiskNumber | Where-Object DriveLetter | Select-Object -First 1 -ExpandProperty DriveLetter;
        Start-Service -Name 'ShellHWDetection';

        $destinationPath = '{0}:\{1}' -f $vhdDriveLetter, $hostDefaults.ResourceShareName;
        ExpandLabResource -ConfigurationData $ConfigurationData -Name $Name -DestinationPath $destinationPath;

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
        [Parameter(Mandatory, ValueFromPipeline)] [System.String] $Name,
        ## Lab VM/Node configuration data
        [Parameter(Mandatory)] [System.Collections.Hashtable] $NodeData,
        ## Lab VM/Node DSC .mof and .meta.mof configuration files
        [Parameter()] [System.String] $Path,
        ## Custom bootstrap script
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $CustomBootStrap
    )
    process {
        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-Service -Name 'ShellHWDetection' -Force;

        $vhdPath = ResolveLabVMDiskPath -Name $Name;
        WriteVerbose ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Mount-Vhd -Path $vhdPath -Passthru;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Get-Partition -DiskNumber $vhd.DiskNumber | Where-Object DriveLetter | Select-Object -First 1 -ExpandProperty DriveLetter;
        Start-Service -Name 'ShellHWDetection';

        $destinationPath = '{0}:\Program Files\WindowsPowershell\Modules' -f $vhdDriveLetter;
        WriteVerbose ($localized.CopyingPowershellModules -f $destinationPath);
        Copy-Item -Path "$env:ProgramFiles\WindowsPowershell\Modules\*" -Destination $destinationPath -Recurse -Force;

        ## Create Unattend.xml
        $newUnattendXmlParams = @{
            ComputerName = $Name;
            Password = $NodeData.Password;
            InputLocale = $NodeData.InputLocale;
            SystemLocale = $NodeData.SystemLocale;
            UserLocale = $NodeData.UserLocale;
            UILanguage = 'en-US';
            Timezone = $NodeData.Timezone;
            RegisteredOwner = $NodeData.RegisteredOwner;
            RegisteredOrganization = $NodeData.RegisteredOrganization;
        }
        WriteVerbose ($localized.SettingAdministratorPassword -f $NodeData.Password);
        if ($NodeData.ProductKey) {
            $newUnattendXmlParams['ProductKey'] = $NodeData.ProductKey;
        }
        $unattendXml = NewUnattendXml @newUnattendXmlParams;
        $unattendXmlPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $vhdDriveLetter;
        WriteVerbose ($localized.AddingUnattendXmlFile -f $unattendXmlPath);
        [ref] $null = $unattendXml.Save($unattendXmlPath);

        $bootStrapPath = '{0}:\BootStrap' -f $vhdDriveLetter;
        WriteVerbose ($localized.AddingBootStrapFile -f $bootStrapPath);
        if ($CustomBootStrap) { SetBootStrap -Path $bootStrapPath -CustomBootStrap $CustomBootStrap; }
        else { SetBootStrap -Path $bootStrapPath; }
        
        $setupCompleteCmdPath = '{0}:\Windows\Setup\Scripts' -f $vhdDriveLetter;
        WriteVerbose ($localized.AddingSetupCompleteCmdFile -f $setupCompleteCmdPath);
        SetSetupCompleteCmd -Path $setupCompleteCmdPath;

        ## Copy MOF files to \BootStrap\localhost.mof and \BootStrap\localhost.meta.mof
        if ($Path) {
            $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $Name);
            $destinationMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.mof';
            WriteVerbose ($localized.AddingDscConfiguration -f $destinationMofPath);
            if (-not (Test-Path -Path $mofPath)) { WriteWarning ($localized.CannotLocateMofFileError -f $mofPath); }
            else { Copy-Item -Path $mofPath -Destination $destinationMofPath -Force -ErrorAction Stop; }

            $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $Name);
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
} #end function  SetLabVMDiskFile
