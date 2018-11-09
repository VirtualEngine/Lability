function Add-DiskImageHotfix {
<#
    .SYMOPSIS
        Adds a Windows update/hotfix package to an image.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Id,

        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
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
        $vhdDriveLetter = Get-DiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;

        $resolveLabMediaParams = @{
            Id = $Id;
        }
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

            $resolveLabMediaParams['ConfigurationData'] = $ConfigurationData;
        }
        $media = Resolve-LabMedia @resolveLabMediaParams;

        foreach ($hotfix in $media.Hotfixes) {

            if ($hotfix.Id -and $hotfix.Uri) {

                $invokeLabMediaDownloadParams = @{
                    Id  = $hotfix.Id;
                    Uri = $hotfix.Uri;
                }

                if ($null -ne $hotfix.Checksum) {

                    $invokeLabMediaDownloadParams['Checksum'] = $hotfix.Checksum;
                }

                $hotfixFileInfo = Invoke-LabMediaDownload @invokeLabMediaDownloadParams;
                $packageName = [System.IO.Path]::GetFileNameWithoutExtension($hotfixFileInfo.FullName);

                Add-DiskImagePackage -Name $packageName -Path $hotfixFileInfo.FullName -DestinationPath $vhdDriveLetter;
            }
        }

    } #end process
} #end function
