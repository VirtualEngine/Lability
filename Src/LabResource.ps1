function Test-LabResource {
<#
    .SYNOPSIS
        Tests whether a lab's resources are present.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab resource Id to test.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceId,

        ## Lab resource path
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $ResourcePath
    )
    begin {

        if (-not $ResourcePath) {
            $hostDefaults = GetConfigurationData -Configuration Host;
            $ResourcePath = $hostDefaults.ResourcePath;
        }

    }
    process {

        if ($resourceId) {

            $resources = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $ResourceId;
        }
        else {

            $resources = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).Resource;
        }

        foreach ($resource in $resources) {

            $fileName = $resource.Id;
            if ($resource.Filename) { $fileName = $resource.Filename; }

            $testResourceDownloadParams = @{
                DestinationPath = Join-Path -Path $ResourcePath -ChildPath $fileName;;
                Uri = $resource.Uri;
            }

            if ($resource.Checksum) {

                $testResourceDownloadParams['Checksum'] = $resource.Checksum;
            }

            if (-not (TestResourceDownload @testResourceDownloadParams)) {

                return $false;
            }
        } #end foreach resource

        return $true;

    } #end process
} #end Test-LabResource


function TestLabResourceIsLocal {
<#
    .SYNOPSIS
        Test whether a lab resource is available locally
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab resource Id to test.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceId,

        ## Node's target resource folder
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $LocalResourcePath
    )
    process {

        $resource = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $ResourceId;

        if (($resource.Expand) -and ($resource.Expand -eq $true)) {

            ## Check the ResourceId folder is present
            $resourcePath = Join-Path -Path $LocalResourcePath -ChildPath $resourceId;
            $resourceExtension = [System.IO.Path]::GetExtension($resource.Filename);

            switch ($resourceExtension) {
                '.iso' {
                    $isPresent = Test-Path -Path $resourcePath -PathType Container;
                }
                '.zip' {
                    $isPresent = Test-Path -Path $resourcePath -PathType Container;
                }
                default {
                    throw ($localized.ExpandNotSupportedError -f $resourceExtension);
                }
            }
        }
        else {

            $resourcePath = Join-Path -Path $LocalResourcePath -ChildPath $resource.Filename;
            $isPresent = Test-Path -Path $resourcePath -PathType Leaf;
        }

        if ($isPresent) {

            WriteVerbose -Message ($localized.ResourceFound -f $resourcePath);
            return $true;
        }
        else {

            WriteVerbose -Message ($localized.ResourceNotFound -f $resourcePath);
            return $false;
        }

    } #end process
} #end function TestLabResourceIsLocal


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
    .PARAMETER All
        Specifies all media, custom and DSC resources should be downloaded.
    .PARAMETER MediaId
        Specifies the specific media IDs to download.
    .PARAMETER ResourceId
        Specifies the specific custom resource IDs to download.
    .PARAMETER Media
        Specifies all media IDs should be downloaded.
    .PARAMETER Resources
        Specifies all custom resource IDs should be downloaded.
    .PARAMETER DSCResources
        Specifies all defined DSC resources should be downloaded.
    .PARAMETER Moduless
        Specifies all defined PowerShell modules should be downloaded.
    .PARAMETER Force
        Forces a download of all resources, overwriting any existing resources.
    .PARAMETER DestinationPath
        Specifies the target destination path of downloaded custom resources (not media or DSC resources).
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -All

        Downloads all required lab media, any custom resources and DSC resources defined in the 'MyLab.psd1' configuration.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -MediaId 'WIN10_x64_Enterprise_EN_Eval'

        Downloads only the 'WIN10_x64_Enterprise_EN_Eval' media.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -ResourceId 'MyCustomResource'

        Downloads only the 'MyCustomResource' resource defined in the 'MyLab.psd1' configuration.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -Media

        Downloads only the media defined in the 'MyLab.psd1' configuration.
    .EXAMPLE
        Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -Resources -DSCResources

        Downloads only the custom file resources and DSC resources defined in the 'MyLab.psd1' configuration.
#>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
         $ConfigurationData = @{ },

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'All')]
        [System.Management.Automation.SwitchParameter] $All,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'MediaId')]
        [System.String[]] $MediaId,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ResourceId')]
        [System.String[]] $ResourceId,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Media')]
        [System.Management.Automation.SwitchParameter] $Media,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Resources')]
        [System.Management.Automation.SwitchParameter] $Resources,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DSCResources')]
        [System.Management.Automation.SwitchParameter] $DSCResources,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Modules')]
        [System.Management.Automation.SwitchParameter] $Modules,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Resources')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ResourceId')]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        $hostDefaults = GetConfigurationData -Configuration Host;
        if (-not $DestinationPath) {
            $DestinationPath = $hostDefaults.ResourcePath;
        }

    }
    process {

        if ($PSCmdlet.ParameterSetName -in 'MediaId','Media','All') {

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

        } #end if MediaId or MediaOnly

        if ($PSCmdlet.ParameterSetName -in 'ResourceId','Resources','All') {

            if (-not $ResourceId) {

                WriteVerbose ($Localized.DownloadingAllDefinedResources);
                $ResourceId = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Resource.Id;
            }

            if (($ResourceId.Count -gt 0) -and (-not $MediaOnly)) {

                foreach ($id in $ResourceId) {

                    $resource = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $id;
                    if (($null -eq $resource.IsLocal) -or ($resource.IsLocal -eq $false)) {

                        $fileName = $resource.Id;
                        if ($resource.Filename) { $fileName = $resource.Filename; }
                        $resourceDestinationPath = Join-Path -Path $DestinationPath -ChildPath $fileName;
                        $invokeResourceDownloadParams = @{
                            DestinationPath = $resourceDestinationPath;
                            Uri = $resource.Uri;
                            Checksum = $resource.Checksum;
                            Force = $Force;
                        }
                        [ref] $null = InvokeResourceDownload @invokeResourceDownloadParams;
                        Write-Output (Get-Item -Path $resourceDestinationPath);
                    }
                }
            }
            else {

                WriteVerbose ($localized.NoResourcesDefined);
            }

        } #end if ResourceId or ResourceOnly

        if ($PSCmdlet.ParameterSetName -in 'DSCResources','All') {

            $dscResourceDefinitions = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).DSCResource;
            if (($null -ne $dscResourceDefinitions) -and ($dscResourceDefinitions.Count -gt 0)) {

                ## Invokes download of DSC resource modules into the module cache
                WriteVerbose ($Localized.DownloadingAllDSCResources);
                InvokeModuleCacheDownload -Module $dscResourceDefinitions -Force:$Force;
            }
            else {
                WriteVerbose ($localized.NoDSCResourcesDefined);
            }
        } #end if DSC resource

        if ($PSCmdlet.ParameterSetName -in 'Modules','All') {

            $moduleDefinitions = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Module;
            if (($null -ne $moduleDefinitions) -and ($moduleDefinitions.Count -gt 0)) {

                ## Invokes download of PowerShell modules into the module cache
                WriteVerbose ($Localized.DownloadingAllPowerShellModules);
                InvokeModuleCacheDownload -Module $moduleDefinitions -Force:$Force;
            }
            else {
                WriteVerbose ($localized.NoPowerShellModulesDefined);
            }

        } #end PowerShell module

    } #end process
} #end function Invoke-LabResourceDownload


function ResolveLabResource {
<#
    .SYNOPSIS
        Resolves a lab resource by its ID
#>
    param (
        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab resource ID
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceId
    )
    process {

        $resource = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).Resource | Where-Object Id -eq $ResourceId;
        if ($resource) {

            return $resource;
        }
        else {

            throw ($localized.CannotResolveResourceIdError -f $resourceId);
        }

    } #end process
} #end function ResolveLabResource


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
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab VM name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Destination mounted VHDX path to expand resources into
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        ## Source resource path
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourcePath
    )
    begin {

        if (-not $ResourcePath) {

            $hostDefaults = GetConfigurationData -Configuration Host;
            $ResourcePath = $hostDefaults.ResourcePath;
        }

    }
    process {

        ## Create the root destination (\Resources) container
        if (-not (Test-Path -Path $DestinationPath -PathType Container)) {

            [ref] $null = New-Item -Path $DestinationPath -ItemType Directory -Force -Confirm:$false;
        }

        $node = ResolveLabVMProperties -NodeName $Name -ConfigurationData $ConfigurationData -ErrorAction Stop;
        foreach ($resourceId in $node.Resource) {

            WriteVerbose ($localized.AddingResource -f $resourceId);
            $resource = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $resourceId;

            ## Default to resource.Id unless there is a filename property defined!
            $resourceSourcePath = Join-Path $resourcePath -ChildPath $resource.Id;

            if ($resource.Filename) {

                $resourceSourcePath = Join-Path $resourcePath -ChildPath $resource.Filename;
                if ($resource.IsLocal) {

                    $resourceSourcePath = Resolve-Path -Path $resource.Filename;
                }
            }

            if (-not (Test-Path -Path $resourceSourcePath) -and (-not $resource.IsLocal)) {

                $invokeLabResourceDownloadParams = @{
                    ConfigurationData = $ConfigurationData;
                    ResourceId = $resourceId;
                }
                [ref] $null = Invoke-LabResourceDownload @invokeLabResourceDownloadParams;
            }

            if (-not (Test-Path -Path $resourceSourcePath)) {

                throw ($localized.CannotResolveResourceIdError -f $resourceId);
            }

            $resourceItem = Get-Item -Path $resourceSourcePath;
            $resourceDestinationPath = $DestinationPath;

            if ($resource.DestinationPath -and (-not [System.String]::IsNullOrEmpty($resource.DestinationPath))) {

                $destinationDrive = Split-Path -Path $DestinationPath -Qualifier;
                $resourceDestinationPath = Join-Path -Path $destinationDrive -ChildPath $resource.DestinationPath;

                ## We can't create a drive-rooted folder!
                if (($resource.DestinationPath -ne '\') -and (-not (Test-Path -Path $resourceDestinationPath))) {

                    [ref] $null = New-Item -Path $resourceDestinationPath -ItemType Directory -Force  -Confirm:$false;
                }
            }
            elseif ($resource.IsLocal -and ($resource.IsLocal -eq $true)) {

                $relativeLocalPath = ($resource.Filename).TrimStart('.');
                $resourceDestinationPath = Join-Path -Path $DestinationPath -ChildPath $relativeLocalPath;
            }

            if (($resource.Expand) -and ($resource.Expand -eq $true)) {

                if ([System.String]::IsNullOrEmpty($resource.DestinationPath)) {

                    ## No explicit destination path, so expand into the <DestinationPath>\<ResourceId> folder
                    $resourceDestinationPath = Join-Path -Path $DestinationPath -ChildPath $resource.Id;
                }

                if (-not (Test-Path -Path $resourceDestinationPath)) {

                    [ref] $null = New-Item -Path $resourceDestinationPath -ItemType Directory -Force -Confirm:$false;
                }

                switch ([System.IO.Path]::GetExtension($resourceSourcePath)) {

                    '.iso' {

                        ExpandIso -Path $resourceItem.FullName -DestinationPath $resourceDestinationPath;
                    }

                    '.zip' {

                        WriteVerbose ($localized.ExpandingZipResource -f $resourceItem.FullName);
                        $expandZipArchiveParams = @{
                            Path = $resourceItem.FullName;
                            DestinationPath = $resourceDestinationPath;
                            Verbose = $false;
                        }
                        [ref] $null = ExpandZipArchive @expandZipArchiveParams;
                    }

                    Default {

                        throw ($localized.ExpandNotSupportedError -f $resourceItem.Extension);
                    }

                } #end switch
            }
            else {

                WriteVerbose ($localized.CopyingFileResource -f $resourceDestinationPath);
                $copyItemParams = @{
                    Path = "$($resourceItem.FullName)";
                    Destination = "$resourceDestinationPath";
                    Force = $true;
                    Recurse = $true;
                    Verbose = $false;
                    Confirm = $false;
                }
                Copy-Item @copyItemParams;
            }

        } #end foreach ResourceId

    } #end process
} #end function ExpandLabResource
