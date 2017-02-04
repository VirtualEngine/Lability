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

        ## Media-defined product key
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $ProductKey
    )
    process {

        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-ShellHWDetectionService;

        $node = ResolveLabVMProperties -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        $vhdPath = ResolveLabVMDiskPath -Name $node.NodeDisplayName;

        WriteVerbose -Message ($localized.MountingDiskImage -f $VhdPath);
        $vhd = Mount-Vhd -Path $vhdPath -Passthru;
        [ref] $null = Get-PSDrive;
        $vhdDriveLetter = Get-Partition -DiskNumber $vhd.DiskNumber |
                            Where-Object DriveLetter |
                                Select-Object -Last 1 -ExpandProperty DriveLetter;
        Start-ShellHWDetectionService;

        try {

            SetLabVMDiskFileResource @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            SetLabVMDiskFileBootstrap @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            SetLabVMDiskFileUnattendXml @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            SetLabVMDiskFileMof @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            SetLabVMDiskFileCertificate @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
            SetLabVMDiskFileModule @PSBoundParameters -VhdDriveLetter $vhdDriveLetter;
        }
        catch {

            ## Bubble up the error to the caller
            throw $_;

        }
        finally {

            ## Ensure the VHD is dismounted (#185)
            WriteVerbose -Message ($localized.DismountingDiskImage -f $VhdPath);
            Dismount-Vhd -Path $VhdPath;
        }

    } #end process
} #end function Set-LabVMDiskFile
