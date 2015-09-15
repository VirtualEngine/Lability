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
        [Parameter()] [ValidateNotNull()] [System.Collections.Hashtable] $CustomData,
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
        ## Confirm we have a valid image/edition configuration
        foreach ($edition in $Editions) {
            TestLabImageParameters -OperatingSystem $OperatingSystem -Architecture $Architecture -Edition $edition -Locale $Locale;
        }
    }
    process {
        [PSCustomObject] @{
            Id = $Id;
            Filename = $Filename;
            Description = $Description;
            #OperatingSystem = $OperatingSystem;
            Architecture = $Architecture;
            #Edition = $Edition;
            ImageName = $ImageName;
            MediaType = $MediaType;
            Uri = [System.Uri] $Uri;
            Checksum = $Checksum;
            ProductKey = $ProductKey;
            #Locale = $Locale;
            CustomData = $CustomData;
            Hotfixes = $Hotfixes;
        }
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
		Gets the current lab media settings.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
	param (
        ## Media ID
        [Parameter(ValueFromPipeline)] [ValidateNotNullOrEmpty()] [System.String] $Id
    )
    process {
        $media = GetConfigurationData -Configuration Media;
        if ($Id) {
            $media = $media | Where-Object { $_.Id -eq $Id };
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
            TestResourceDownload @testResourceDownloadParams;
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
    .DESCRIPTIONS
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
		[Parameter()] [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $media = ResolveLabMedia -Id $Id;
        if ($media.MediaType -eq 'VHD') {
            $destinationPath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $media.Filename;
        }
        else {
            $destinationPath = Join-Path -Path $hostDefaults.IsoPath -ChildPath $media.Filename;
        }
        $invokeResourceDownloadParams = @{
            DestinationPath = $destinationPath;
            uri = $media.Uri;
            Checksum = $media.Checksum;
        }
        [ref] $null = InvokeResourceDownload @invokeResourceDownloadParams -Force:$Force;
        return (Get-Item -Path $destinationPath);
    } #end process
} #end Invoke-LabMediaDownload

function InvokeLabMediaHotfixDownload {
<#
    .SYNOPSIS
        Downloads resources.
    .DESCRIPTIONS
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
