function Register-LabMedia {
<#
    .SYNOPSIS
        Registers a custom media entry.
    .DESCRIPTION
        The Register-LabMedia cmdlet allows adding custom media to the host's configuration. This circumvents the requirement of having to define custom media entries in the DSC configuration document (.psd1).

        You can use the Register-LabMedia cmdlet to override the default media entries, e.g. you have the media hosted internally or you wish to replace the built-in media with your own implementation.

        To override a built-in media entry, specify the same media Id with the -Force switch.
    .PARAMETER Legacy
        Specifies registering a legacy Windows 10 media as custom media.
    .EXAMPLE
        Register-LabMedia -Legacy WIN10_x64_Enterprise_1809_EN_Eval

        Reregisters the deprecated Windows 10 Enterprise x64 English evaluation media.
    .LINK
        Get-LabMedia
        Unregister-LabMedia
#>
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param
    (
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

        ## Specifies the media alias (Id).
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ID')]
        [System.String] $Alias,

        ## Registers media via a JSON file hosted externally.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromUri')]
        [System.String] $FromUri,

        ## Registers media using a custom Id.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'FromUri')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Legacy')]
        [System.String] $CustomId,

        ## Specifies that an exiting media entry should be overwritten.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    DynamicParam
    {
        ## Adds a dynamic -Legacy parameter that returns the available legacy Windows 10 media Ids
        $parameterAttribute = New-Object -TypeName 'System.Management.Automation.ParameterAttribute'
        $parameterAttribute.ParameterSetName = 'Legacy'
        $parameterAttribute.Mandatory = $true
        $attributeCollection = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Attribute]'
        $attributeCollection.Add($parameterAttribute)
        $mediaIds = (Get-LabMedia -Legacy).Id
        $validateSetAttribute = New-Object -TypeName 'System.Management.Automation.ValidateSetAttribute' -ArgumentList $mediaIds
        $attributeCollection.Add($validateSetAttribute)
        $runtimeParameter = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameter' -ArgumentList @('Legacy', [System.String], $attributeCollection)
        $runtimeParameterDictionary = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameterDictionary'
        $runtimeParameterDictionary.Add('Legacy', $runtimeParameter)
        return $runtimeParameterDictionary
    }
    process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            Legacy {

                ## Download the json content and convert into a hashtable
                $legacyMedia = Get-LabMedia -Id $PSBoundParameters.Legacy -Legacy | Convert-PSObjectToHashtable

                if ($PSBoundParameters.ContainsKey('CustomId'))
                {
                    $legacyMedia['Id'] = $CustomId
                }

                ## Recursively call Register-LabMedia and splat the properties
                return (Register-LabMedia @legacyMedia -Force:$Force)
            }

            FromUri {

                ## Download the json content and convert into a hashtable
                $customMedia = Invoke-RestMethod -Uri $FromUri | Convert-PSObjectToHashtable

                if ($PSBoundParameters.ContainsKey('CustomId'))
                {
                    $customMedia['Id'] = $CustomId
                }

                ## Recursively call Register-LabMedia and splat the properties
                return (Register-LabMedia @customMedia -Force:$Force)
            }

            default {

                ## Validate Linux VM media type is VHD or NULL
                if (($OperatingSystem -eq 'Linux') -and ($MediaType -notin 'VHD','NULL'))
                {
                    throw ($localized.InvalidOSMediaTypeError -f $MediaType, $OperatingSystem)
                }

                ## Validate ImageName when media type is ISO/WIM
                if (($MediaType -eq 'ISO') -or ($MediaType -eq 'WIM'))
                {
                    if (-not $PSBoundParameters.ContainsKey('ImageName'))
                    {
                        throw ($localized.ImageNameRequiredError -f '-ImageName')
                    }
                }

                ## Resolve the media Id to see if it's already been used
                try
                {
                    $media = Resolve-LabMedia -Id $Id -ErrorAction SilentlyContinue
                }
                catch
                {
                    Write-Debug -Message ($localized.CannotLocateMediaError -f $Id)
                }

                if ($media -and (-not $Force))
                {
                    throw ($localized.MediaAlreadyRegisteredError -f $Id, '-Force')
                }

                if ($PSBoundParameters.ContainsKey('Alias'))
                {
                    ## Check to see whether the alias is already registered
                    $existingMediaIds = Get-LabMediaId
                    if ($existingMediaIds.Contains($Alias))
                    {
                        throw ($localized.MediaAliasAlreadyRegisteredError -f $Alias)
                    }
                }

                ## Get the custom media list (not the built in media)
                $existingCustomMedia = @(Get-ConfigurationData -Configuration CustomMedia)
                if (-not $existingCustomMedia)
                {
                    $existingCustomMedia = @()
                }

                $customMedia = [PSCustomObject] @{
                    Id              = $Id
                    Alias           = $Alias
                    Filename        = $Filename
                    Description     = $Description
                    Architecture    = $Architecture
                    ImageName       = $ImageName
                    MediaType       = $MediaType
                    OperatingSystem = $OperatingSystem
                    Uri             = $Uri
                    Checksum        = $Checksum
                    CustomData      = $CustomData
                    Hotfixes        = $Hotfixes
                }

                $hasExistingMediaEntry = $false
                for ($i = 0; $i -lt $existingCustomMedia.Count; $i++)
                {
                    if ($existingCustomMedia[$i].Id -eq $Id)
                    {
                        Write-Verbose -Message ($localized.OverwritingCustomMediaEntry -f $Id)
                        $hasExistingMediaEntry = $true
                        $existingCustomMedia[$i] = $customMedia
                    }
                }

                if (-not $hasExistingMediaEntry)
                {
                    ## Add it to the array
                    Write-Verbose -Message ($localized.AddingCustomMediaEntry -f $Id)
                    $existingCustomMedia += $customMedia
                }

                Write-Verbose -Message ($localized.SavingConfiguration -f $Id)
                Set-ConfigurationData -Configuration CustomMedia -InputObject @($existingCustomMedia)
                return $customMedia

            } #end default
        } #end switch

    } #end process
} #end function
