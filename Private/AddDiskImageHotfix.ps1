function AddDiskImageHotfix {

<#
    .SYMOPSIS
        Adds a Windows update/hotfix package to an image.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if ($PartitionStyle -eq 'MBR') {

            $partitionType = 'IFS';
        }
        elseif ($PartitionStyle -eq 'GPT') {

            $partitionType = 'Basic';
        }
        $vhdDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;

        $resolveLabMediaParams = @{
            Id = $Id;
        }
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {
            $resolveLabMediaParams['ConfigurationData'] = $ConfigurationData;
        }
        $media = ResolveLabMedia @resolveLabMediaParams;

        foreach ($hotfix in $media.Hotfixes) {

            $hotfixFileInfo = InvokeLabMediaHotfixDownload -Id $hotfix.Id -Uri $hotfix.Uri;
            $packageName = [System.IO.Path]::GetFileNameWithoutExtension($hotfixFileInfo.FullName);

            AddDiskImagePackage -Name $packageName -Path $hotfixFileInfo.FullName -DestinationPath $vhdDriveLetter;
        }

    } #end process

}

