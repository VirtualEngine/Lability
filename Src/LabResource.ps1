function Test-LabResource {
<#
    .SYNOPSIS
        Tests whether a lab's resources are present.
#>
    param (
        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Object] $ConfigurationData,
        
        ## Lab resource Id to test.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $ResourceId
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        $hostDefaults = GetConfigurationData -Configuration Host;
    }
    process {
        if ($resourceId) { $resources = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $ResourceId }
        else { $resources = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).Resource }
        
        foreach ($resource in $resources) {
            $fileName = $resource.Id;
            if ($resource.Filename) { $fileName = $resource.Filename; }
            
            $testResourceDownloadParams = @{
                DestinationPath = Join-Path -Path $hostDefaults.ResourcePath -ChildPath $fileName;;
                Uri = $resource.Uri;
            }
            if ($resource.Checksum) { $testResourceDownloadParams['Checksum'] = $resource.Checksum }
            if (-not (TestResourceDownload @testResourceDownloadParams)) {
                return $false;
            }
        }
        return $true;
    } #end process
} #end Test-LabResource

function Invoke-LabResourceDownload {
<#
    .SYNOPSIS
        Starts a download of all required lab resources.
    .DESCRIPTION
        When a lab configuration is started, Lability will attempt to download all the required media and resources.
        
        In some scenarios you many need to download lab resources in advance, e.g. where internet access is not
        readily available or permitted. The `Invoke-LabResourceDownload` cmdlet can be used to manually download
        all required resources or specific media/resources as needed.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
    .PARAMETER MediaId
        Specifies the specific media IDs to download.
    .PARAMETER ResourceId
        Specifies the specific custom resource IDs to download.
    .PARAMETER Force
        Forces a download of all resources, overwriting any existing resources.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1

        Downloads all required lab media and any custom resources defined in the 'MyLab.psd1' configuration.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -MediaId 'WIN10_x64_Enterprise_EN_Eval'

        Downloads only the 'WIN10_x64_Enterprise_EN_Eval' media.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -ResourceId 'MyCustomResource'

        Downloads only the 'MyCustomResource' resource defined in the 'MyLab.psd1' configuration.
#>
    param (
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Object] $ConfigurationData = @{ },
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]] $MediaId,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String[]] $ResourceId,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        $hostDefaults = GetConfigurationData -Configuration Host;
    }
    process {
        if (-not $MediaId) {
            WriteVerbose ($Localized.DownloadingAllRequiredMedia);
            $uniqueMediaIds = @();
            $ConfigurationData.AllNodes.Where({ $_.NodeName -ne '*' }) | ForEach-Object {
                $id = (ResolveLabVMProperties -NodeName $_.NodeName -ConfigurationData $ConfigurationData).Media;
                if ($uniqueMediaIds -notcontains $id) { $uniqueMediaIds += $id; }
            }
            $MediaId = $uniqueMediaIds;
        }

        if ($MediaId) {
            foreach ($id in $MediaId) {
                $labMedia = ResolveLabMedia -ConfigurationData $ConfigurationData -Id $id;
                InvokeLabMediaImageDownload -Media $labMedia -Force:$Force;

                WriteVerbose $Localized.DownloadingAllRequiredHotfixes;            
                if ($labMedia.Hotfixes.Count -gt 0) {
                    foreach ($hotfix in $labMedia.Hotfixes) {
                        InvokeLabMediaHotfixDownload -Id $hotfix.Id -Uri $hotfix.Uri;
                    }
                }
                else {
                    WriteVerbose ($localized.NoHotfixesSpecified);
                }
            }
        }
        else {
            WriteVerbose ($localized.NoMediaDefined);
        }

        if (-not $ResourceId) {
            WriteVerbose ($Localized.DownloadingAllDefinedResources);
            $ResourceId = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Resource.Id;
        }

        if ($ResourceId.Count -gt 0) {
            foreach ($id in $ResourceId) {
                $resource = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $id;
                $fileName = $resource.Id;
                if ($resource.Filename) { $fileName = $resource.Filename; }
                $destinationPath = Join-Path -Path $hostDefaults.ResourcePath -ChildPath $fileName;
                InvokeResourceDownload -DestinationPath $destinationPath -Uri $resource.Uri -Checksum $resource.Checksum -Force:$Force;
            }
        }
        else {
            WriteVerbose ($localized.NoResourcesDefined);
        }
    } #end process
} #end function Invoke-LabResourceDownload

function ResolveLabResource {
<#
    .SYNOPSIS
        Resolves a lab resource by its ID
#>
    param (
        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Object] $ConfigurationData,
        
        ## Lab resource ID
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ResourceId
    )
    process {
        $resource = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).Resource | Where-Object Id -eq $ResourceId;
        if ($resource) { return $resource; }
        else { throw ($localized.CannotResolveResourceIdError -f $resourceId); }
    }
} #end function ResolveLabResource

function ExpandIsoResource {
<#
    .SYNOPSIS
        Expands an ISO disk image resource
#>
    param (
        ## Source ISO file path
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,
        
        ## Destination folder path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $DestinationPath
    )
    process {
        WriteVerbose ($localized.MountingDiskImage -f $Path);
        $iso = Mount-DiskImage -ImagePath $Path -StorageType ISO -Access ReadOnly -PassThru -Verbose:$false;
        ## Refresh drives
        [ref] $null = Get-PSDrive;
        $isoDriveLetter = $iso | Get-Volume | Select-Object -ExpandProperty DriveLetter;
        WriteVerbose ($localized.ExpandingIsoResource -f $DestinationPath);
        $sourcePath = '{0}:\*' -f $isoDriveLetter;
        Copy-Item -Path $sourcePath -Destination $DestinationPath -Recurse -Force -Verbose:$false;
        WriteVerbose ($localized.DismountingDiskImage -f $Path);
        Dismount-DiskImage -ImagePath $Path;
    } #end process
} #end function ExpandIsoResource

function ExpandLabResource {
<#
    .SYNOPSIS
        Copies files, e.g. EXEs, ISOs and ZIP file resources into a lab VM's mounted VHDX differencing disk image.
    .NOTES
        VHDX should already be mounted and passed in via the $DestinationPath parameter
        Can expand ISO and ZIP files if the 'Expand' property is set to $true on the resource's properties.
#>
    param (
        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Object] $ConfigurationData,
        
        ## Lab VM name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,
        
        ## Destination mounted VHDX path to expand resources into
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        $hostDefaults = GetConfigurationData -Configuration Host;
    }
    process {
        if (-not (Test-Path -Path $DestinationPath -PathType Container)) {
            [ref] $null = New-Item -Path $DestinationPath -ItemType Directory -Force;
        }
        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -ErrorAction Stop;
        foreach ($resourceId in $node.Resource) {
            
            WriteVerbose ($localized.InjectingVMResource -f $resourceId);
            $destinationResourcePath = Join-Path -Path $DestinationPath -ChildPath $resourceId;
            $resource = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $resourceId;
            
            ## Default to resource.Id unless there is a filename property defined!
            $resourceItemPath = Join-Path -Path $hostDefaults.ResourcePath -ChildPath $resource.Id;
            if ($resource.Filename) {
                $resourceItemPath = Join-Path -Path $hostDefaults.ResourcePath -ChildPath $resource.Filename;
            }
            if (-not (Test-Path -Path $resourceItemPath)) {
                [ref] $null = Invoke-LabResourceDownload -ConfigurationData $ConfigurationData -ResourceId $resourceId;
            }
            $resourceItem = Get-Item -Path $resourceItemPath;

            if (($resource.Expand) -and ($resource.Expand -eq $true)) {
                [ref] $null = New-Item -Path $destinationResourcePath -ItemType Directory -Force;
                switch ($resourceItem.Extension) {
                    '.iso' { ExpandIsoResource -Path $resourceItem.FullName -DestinationPath $destinationResourcePath; }
                    '.zip' { [ref] $null = ExpandZipArchive -Path $resourceItem.FullName -DestinationPath $destinationResourcePath -Verbose:$false; }
                    Default { throw ($localized.ExpandNotSupportedError -f $resourceItem.Extension); }
                } #end switch
            }
            else {
                WriteVerbose ($localized.CopyingFileResource -f (Join-Path -Path $DestinationPath -ChildPath $resourceItem.Name));
                Copy-Item -Path $resourceItem.FullName -Destination $destinationPath -Force -Verbose:$false;
            }
        } #end foreach ResourceId
    } #end process
} #end function ExpandLabResource
