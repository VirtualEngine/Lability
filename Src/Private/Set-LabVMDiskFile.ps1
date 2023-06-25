function Set-LabVMDiskFile {
<#
    .SYNOPSIS
        Copies Lability files to a node's VHD(X) file.
    .DESCRIPTION
        Copies the Lability bootstrap file, SetupComplete.cmd, unattend.xml,
        mof files, certificates and PowerShell/DSC resource modules to a
        VHD(X) file.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
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
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom/replacement Shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DefaultShell,

        ## WSMan maximum envelope size
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Int32] $MaxEnvelopeSizeKb = 1024,

        ## Media-defined product key
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $ProductKey,

        ## Credentials to access the a private feed
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential
    )
    process {

        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-ShellHWDetectionService;

        $node = Resolve-NodePropertyValue -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;

        $resolveLabVMGenerationDiskPathParams = @{
            Name = $node.NodeDisplayName;
            Media = $node.Media;
            ConfigurationData = $ConfigurationData;
        }
        $vhdPath = Resolve-LabVMGenerationDiskPath @resolveLabVMGenerationDiskPathParams;

        ## Disable BitLocker fixed drive write protection (if enabled)
        Disable-BitLockerFDV;

        Write-Verbose -Message ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Hyper-V\Mount-Vhd -Path $vhdPath -Passthru -Confirm:$false;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Storage\Get-Partition -DiskNumber $vhd.DiskNumber |
                            Where-Object DriveLetter |
                                Select-Object -Last 1 -ExpandProperty DriveLetter;
        Start-ShellHWDetectionService;

        try {

            Set-LabVMDiskFileResource @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            Set-LabVMDiskFileBootstrap @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            Set-LabVMDiskFileUnattendXml @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            Set-LabVMDiskFileMof @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            Set-LabVMDiskFileCertificate @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            Set-LabVMDiskFileModule @PSBoundParameters -VhdDriveLetter $vhdDriveLetter; # FeedCredential passed in bound parameters
        }
        catch {

            ## Bubble up the error to the caller
            throw $_;
        }
        finally {

            ## Ensure the VHD is dismounted (#185)
            Write-Verbose -Message ($localized.DismountingDiskImage -f $VhdPath);
            $null = Hyper-V\Dismount-Vhd -Path $VhdPath -Confirm:$false;

            ## Enable BitLocker (if required)
            Assert-BitLockerFDV;
        }

    } #end process
} #end function Set-LabVMDiskFile
