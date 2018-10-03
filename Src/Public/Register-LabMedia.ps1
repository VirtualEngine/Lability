function Register-LabMedia {
<#
    .SYNOPSIS
        Registers a custom media entry.
    .DESCRIPTION
        The Register-LabMedia cmdlet allows adding custom media to the host's configuration. This circumvents the requirement of having to define custom media entries in the DSC configuration document (.psd1).

        You can use the Register-LabMedia cmdlet to override the default media entries, e.g. you have the media hosted internally or you wish to replace the built-in media with your own implementation.

        To override a built-in media entry, specify the same media Id with the -Force switch.
    .LINK
        Get-LabMedia
        Unregister-LabMedia
#>
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param (
        ## Specifies the media Id to register. You can override the built-in media if required.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [System.String] $Id,

        ## Specifies the media's type.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateSet('VHD','ISO','WIM','NULL')]
        [System.String] $MediaType,

        ## Specifies the source Uri (http/https/file) of the media.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [System.Uri] $Uri,

        ## Specifies the architecture of the media.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateSet('x64','x86')]
        [System.String] $Architecture,

        ## Specifies a description of the media.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Description,

        ## Specifies the image name containing the target WIM image. You can specify integer values.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [System.String] $ImageName,

        ## Specifies the local filename of the locally cached resource file.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Filename,

        ## Specifies the MD5 checksum of the resource file.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Checksum,

        ## Specifies custom data for the media.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateNotNull()]
        [System.Collections.Hashtable] $CustomData,

        ## Specifies additional Windows hotfixes to install post deployment.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateNotNull()]
        [System.Collections.Hashtable[]] $Hotfixes,

        ## Specifies the media type. Linux VHD(X)s do not inject resources.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [ValidateSet('Windows','Linux')]
        [System.String] $OperatingSystem = 'Windows',

        ## Registers media via a JSON file hosted externally
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromUri')]
        [System.String] $FromUri,

        ## Specifies that an exiting media entry should be overwritten.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        switch ($PSCmdlet.ParameterSetName) {

            'FromUri' {

                ## Download the json content and convert into a hashtable
                $customMedia = Invoke-RestMethod -Uri $FromUri | Convert-PSObjectToHashtable;

                ## Recursively call Register-LabMedia and splat the properties
                return (Register-LabMedia @customMedia -Force:$Force);

            }

            default {

                ## Validate Linux VM media type is VHD or NULL
                if (($OperatingSystem -eq 'Linux') -and ($MediaType -notin 'VHD','NULL')) {

                    throw ($localized.InvalidOSMediaTypeError -f $MediaType, $OperatingSystem);
                }

                ## Validate ImageName when media type is ISO/WIM
                if (($MediaType -eq 'ISO') -or ($MediaType -eq 'WIM')) {

                    if (-not $PSBoundParameters.ContainsKey('ImageName')) {

                        throw ($localized.ImageNameRequiredError -f '-ImageName');
                    }
                }

                ## Resolve the media Id to see if it's already been used
                $media = Resolve-LabMedia -Id $Id -ErrorAction SilentlyContinue;
                if ($media -and (-not $Force)) {

                    throw ($localized.MediaAlreadyRegisteredError -f $Id, '-Force');
                }

                ## Get the custom media list (not the built in media)
                $existingCustomMedia = @(Get-ConfigurationData -Configuration CustomMedia);
                if (-not $existingCustomMedia) {

                    $existingCustomMedia = @();
                }

                $customMedia = [PSCustomObject] @{
                    Id = $Id;
                    Filename = $Filename;
                    Description = $Description;
                    Architecture = $Architecture;
                    ImageName = $ImageName;
                    MediaType = $MediaType;
                    OperatingSystem = $OperatingSystem;
                    Uri = $Uri;
                    Checksum = $Checksum;
                    CustomData = $CustomData;
                    Hotfixes = $Hotfixes;
                }

                $hasExistingMediaEntry = $false;
                for ($i = 0; $i -lt $existingCustomMedia.Count; $i++) {

                    if ($existingCustomMedia[$i].Id -eq $Id) {

                        Write-Verbose -Message ($localized.OverwritingCustomMediaEntry -f $Id);
                        $hasExistingMediaEntry = $true;
                        $existingCustomMedia[$i] = $customMedia;
                    }
                }

                if (-not $hasExistingMediaEntry) {

                    ## Add it to the array
                    Write-Verbose -Message ($localized.AddingCustomMediaEntry -f $Id);
                    $existingCustomMedia += $customMedia;
                }

                Write-Verbose -Message ($localized.SavingConfiguration -f $Id);
                Set-ConfigurationData -Configuration CustomMedia -InputObject @($existingCustomMedia);
                return $customMedia;

            } #end default
        } #end switch

    } #end process
} #end function
