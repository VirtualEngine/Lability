function NewLabMedia {
<#
    .SYNOPSIS
        Creates a new lab media object.
    .DESCRIPTION
        Permits validation of custom NonNodeData\VirtualEngineLab\Media entries.
#>
    [CmdletBinding()]
    param (
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Id = $(throw ($localized.MissingParameterError -f 'Id')),
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Filename = $(throw ($localized.MissingParameterError -f 'Filename')),
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Description = '',
        [Parameter()] [ValidateSet('x86','x64')] [System.String] $Architecture = $(throw ($localized.MissingParameterError -f 'Architecture')),
        [Parameter()] [System.String] $ImageName = '',
        [Parameter()] [ValidateSet('ISO','VHD')] [System.String] $MediaType = $(throw ($localized.MissingParameterError -f 'MediaType')),
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Uri = $(throw ($localized.MissingParameterError -f 'Uri')),
        [Parameter()] [System.String] $Checksum = '',
        [Parameter()] [System.String] $ProductKey = '',
        [Parameter()] [ValidateNotNull()] [System.Collections.Hashtable] $CustomData = @{},
        [Parameter()] [AllowNull()] [System.Array] $Hotfixes
    )
    begin {
        ## Confirm we have a valid Uri
        try {
            $resolvedUri = New-Object -TypeName 'System.Uri' -ArgumentList $Uri;
            if ($resolvedUri.Scheme -notin 'http','https','file') {
                throw ($localized.UnsupportedUriSchemeError -f $resolvedUri.Scheme);
            }
        }
        catch {
            throw $_;
        }
    }
    process {
        $labMedia = [PSCustomObject] @{
            Id = $Id;
            Filename = $Filename;
            Description = $Description;
            Architecture = $Architecture;
            ImageName = $ImageName;
            MediaType = $MediaType;
            Uri = [System.Uri] $Uri;
            Checksum = $Checksum;
            CustomData = $CustomData;
            Hotfixes = $Hotfixes;
        }
        if ($ProductKey) {
            $CustomData['ProductKey'] = $ProductKey;
        }
        return $labMedia;
    } #end process
} #end function NewLabMedia

function ResolveLabMedia {
<#
    .SYNOPSIS
        Resolves the specified media using the registered media and configuration data.
    .DESCRIPTION
        Resolves the specified lab media from the registered media, but permitting the defaults to be overridden
        by configuration data. This also permits specifying of media within Configuration Data and not having
        to be registered on the lab host.
#>
    [CmdletBinding()]
    param (
        ## Media ID
        [Parameter(Mandatory)] [System.String] $Id,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter()] [System.Object] $ConfigurationData
    )
    process {
        ## If we have configuration data specific instance, return that
        if ($ConfigurationData) {
            $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
            $customMedia = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Media.Where({ $_.Id -eq $Id });
            if ($customMedia) {
                $mediaHash = @{};
                foreach ($key in $customMedia.Keys) {
                    [ref] $null = $mediaHash.Add($key, $customMedia.$Key);
                }
                $media = NewLabMedia @mediaHash;
            }
        }
        ## If we have custom media, return that
        if (-not $media) {
            $media = GetConfigurationData -Configuration CustomMedia;
            if ($Id) {
                $media = $media | Where-Object { $_.Id -eq $Id };
            }
        }
        ## If we still don't have a media image, return the built-in object
        if (-not $media) {
            $media = Get-LabMedia -Id $Id;
        }
        if (-not $media) {
            throw ($localized.CannotLocateMediaError -f $Id);
        }
        return $media;
    } #end process
} #end function ResolveLabMedia

function Get-LabMedia {
<#
	.SYNOPSIS
		Gets the currently registered built-in and custom lab media.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
	param (
        ## Media ID
        [Parameter(ValueFromPipeline)] [ValidateNotNullOrEmpty()] [System.String] $Id,
        ## Only return custom media
        [Parameter()] [System.Management.Automation.SwitchParameter] $CustomOnly
    )
    process {
        ## Retrieve built-in media
        if (-not $CustomOnly) {
            $defaultMedia = GetConfigurationData -Configuration Media;
        }
        ## Retrieve custom media
        $customMedia = GetConfigurationData -Configuration CustomMedia;
        if (-not $customMedia) {
            $customMedia = @();
        }

        ## Are we looking for a specific media Id
        if ($Id) {
            ## Return the custom media definition first (if it exists)
            $media = $customMedia | Where-Object { $_.Id -eq $Id };
            if ((-not $media) -and (-not $CustomOnly)) {
                ## We didn't find a custom media entry, return a default entry (if it exists)
                $media = $defaultMedia | Where-Object { $_.Id -eq $Id };
            }
        }
        else {
            ## Return all custom media
            $media = $customMedia;
            if (-not $CustomOnly) {
                foreach ($mediaEntry in $defaultMedia) {
                    ## Determine whether the media is present in the custom media, i.e. make sure
                    ## we don't override a custom entry with the default one.
                    $defaultMediaEntry = $customMedia | Where-Object { $_.Id -eq $mediaEntry.Id }
                    ## If not, add it to the media array to return
                    if (-not $defaultMediaEntry) {
                        $media += $mediaEntry;
                    }
                } #end foreach default media
            } #end if not custom only
        }
        return $media;
    } #end process
} #end function Get-LabMedia

function Test-LabMedia {
<#
    .SYNOPSIS
        Determines whether media has already been downloaded.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(ValueFromPipeline)] [ValidateNotNullOrEmpty()] [System.String] $Id
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $media = Get-LabMedia -Id $Id;
        if ($media) {
            $testResourceDownloadParams = @{
                DestinationPath = Join-Path -Path $hostDefaults.IsoPath -ChildPath $media.Filename;
                uri = $media.Uri;
                Checksum = $media.Checksum;
            }
            return TestResourceDownload @testResourceDownloadParams;
        }
        else {
            return $false;
        }
    } #end process
} #end function Test-LabMedia

function InvokeLabMediaImageDownload {
<#
    .SYNOPSIS
        Downloads ISO/VHDX media resources.
    .DESCRIPTION
        Initiates a download of a media resource. If the resource has already been downloaded and the checksum
        is correct, it won't be re-downloaded. To force download of a ISO/VHDX use the -Force switch.
    .NOTES
        ISO media is downloaded to the default IsoPath location. VHD(X) files are downloaded directly into the
        ParentVhdPath location.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        ## Lab media object
        [Parameter(Mandatory)] [ValidateNotNull()] [System.Object] $Media,
        ## Force (re)download of the resource
        [Parameter()] [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;

        if ($media.MediaType -eq 'VHD') {
            $destinationPath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $media.Filename;
        }
        elseif ($media.MediaType -eq 'ISO') {
            $destinationPath = Join-Path -Path $hostDefaults.IsoPath -ChildPath $media.Filename;
        }

        $invokeResourceDownloadParams = @{
            DestinationPath = $destinationPath;
            Uri = $media.Uri;
            Checksum = $media.Checksum;
        }

        $mediaUri = New-Object -TypeName System.Uri -ArgumentList $Media.Uri;
        if ($mediaUri.Scheme -eq 'File') {
            ## Use a bigger buffer for local file copies..
            $invokeResourceDownloadParams['BufferSize'] = 1MB;
        }
        
        [ref] $null = InvokeResourceDownload @invokeResourceDownloadParams -Force:$Force;
        return (Get-Item -Path $destinationPath);
    } #end process
} #end Invoke-LabMediaDownload

function InvokeLabMediaHotfixDownload {
<#
    .SYNOPSIS
        Downloads resources.
    .DESCRIPTION
        Initiates a download of a media resource. If the resource has already been downloaded and the checksum
        is correct, it won't be re-downloaded. To force download of a ISO/VHDX use the -Force switch.
    .NOTES
        ISO media is downloaded to the default IsoPath location. VHD(X) files are downloaded directly into the
        ParentVhdPath location.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Id,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Uri,
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Checksum,
		[Parameter()] [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $destinationPath = Join-Path -Path $hostDefaults.HotfixPath -ChildPath $Id;
        $invokeResourceDownloadParams = @{
            DestinationPath = $destinationPath;
            Uri = $Uri;
        }
        if ($Checksum) {
            [ref] $null = $invokeResourceDownloadParams.Add('Checksum', $Checksum);
        }
        [ref] $null = InvokeResourceDownload @invokeResourceDownloadParams -Force:$Force;
        return (Get-Item -Path $destinationPath);
    } #end process
} #end function InvokeLabMediaHotfixDownload

function Register-LabMedia {
<#
    .SYNOPSIS
        Registers a custom media entry.
    .DESCRIPTION
        The Register-LabMedia cmdlet allows registering custom media circumventing the requirement of having to define custom media in the DSC Configuration Data.

        You can use the Register-LabMedia cmdlet to override the default media entries, e.g. you have the media hosted internally.
#>
    [CmdletBinding()]
    param (
        ## Unique media ID. You can override the built-in media if required.
        [Parameter(Mandatory)] [System.String] $Id,
        ## Media type
        [Parameter(Mandatory)] [ValidateSet('VHD','ISO','WIM')] [System.String] $MediaType,
        ## The source http/https/file Uri of the source file
        [Parameter(Mandatory)] [System.Uri] $Uri,
        ## Architecture of the source media
        [Parameter(Mandatory)] [ValidateSet('x64','x86')] [System.String] $Architecture,
        ## Media description
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Description,
        ## ISO/WIM image name
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $ImageName,
        ## Target local filename for the locally cached resource
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Filename,
        ## MD5 checksum of the resource
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Checksum,
        ## Media custom data
        [Parameter()] [ValidateNotNull()] [System.Collections.Hashtable] $CustomData,
        ## Media custom data
        [Parameter()] [ValidateNotNull()] [System.Collections.Hashtable[]] $Hotfixes,
        ## Override existing media entries
        [Parameter()] [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        ## Validate ImageName when media type is ISO/WIM
        if (($MediaType -eq 'ISO') -or ($MediaType -eq 'WIM')) {
            if (-not $PSBoundParameters.ContainsKey('ImageName')) {
                throw ($localized.ImageNameRequiredError -f '-ImageName');
            }
        }

        ## Resolve the media Id to see if it's already been used
        $media = ResolveLabMedia -Id $Id -ErrorAction SilentlyContinue;
        if ($media -and (-not $Force)) {
            throw ($localized.MediaAlreadyRegisteredError -f $Id, '-Force');
        }
    
        ## Get the custom media list (not the built in media)
        $existingCustomMedia = GetConfigurationData -Configuration CustomMedia;
        if (-not $existingCustomMedia) {
            WriteWarning ($localized.NoCustomMediaFoundWarning  -f $Id);
            $existingCustomMedia = @();
        }
    
        $customMedia = [PSCustomObject] @{
            Id = $Id;
            Filename = $Filename;
            Description = $Description;
            Architecture = $Architecture;
            ImageName = $ImageName;
            MediaType = $MediaType;
            Uri = $Uri;
            Checksum = $Checksum;
            CustomData = $CustomData;
            Hotfixes = $Hotfixes;
        }

        $hasExistingMediaEntry = $false;
        for ($i = 0; $i -lt $existingCustomMedia.Count; $i++) {
            if ($existingCustomMedia[$i].Id -eq $Id) {
                WriteVerbose ($localized.OverwritingCustomMediaEntry -f $Id);
                $hasExistingMediaEntry = $true;
                $existingCustomMedia[$i] = $customMedia;
            }
        }

        if (-not $hasExistingMediaEntry) {
            ## Add it to the array
            WriteVerbose ($localized.AddingCustomMediaEntry -f $Id);
            $existingCustomMedia += $customMedia;
        }
    
        WriteVerbose ($localized.SavingConfiguration -f $Id);
        SetConfigurationData -Configuration CustomMedia -InputObject @($existingCustomMedia);
        return $customMedia;
    
    } #end process
} #end function Register-LabMedia

function Unregister-LabMedia {
<#
    .SYNOPSIS
        Unregisters a custom media entry.
    .DESCRIPTION
        The Unregister-LabMedia cmdlet allows unregistering custom media entries.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Unique media ID. You can override the built-in media if required.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [System.String] $Id
    )
    process {
        ## Get the custom media list
        $customMedia = GetConfigurationData -Configuration CustomMedia;
        if (-not $customMedia) {
            ## We don't have anything defined
            WriteWarning ($localized.NoCustomMediaFoundWarning -f $Id);
            return;
        }
        else {
            ## Check if we have a matching Id
            $media = $customMedia | Where-Object { $_.Id -eq $Id };
            if (-not $media) {
                ## We don't have a custom matching Id registered
                WriteWarning ($localized.NoCustomMediaFoundWarning -f $Id);
                return;
            }
        }
        
        $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Unregister-LabMedia', $Id;
        $verboseProcessMessage = $localized.RemovingCustomMediaEntry -f $Id;
        if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {
            $customMedia = $customMedia | Where-Object { $_.Id -ne $Id };
            WriteVerbose ($localized.SavingConfiguration -f $Id);
            SetConfigurationData -Configuration CustomMedia -InputObject @($customMedia);
            return $media;
        }
        
    } #end process
} #end function Unregister-LabMedia
