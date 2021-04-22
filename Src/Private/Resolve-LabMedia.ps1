function Resolve-LabMedia {
<#
    .SYNOPSIS
        Resolves the specified media using the registered media and configuration data.
    .DESCRIPTION
        Resolves the specified lab media from the registered media, but permitting the defaults to be overridden by configuration data.

        This also permits specifying of media within Configuration Data and not having to be registered on the lab host.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param
    (
        ## Media ID or alias
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Id,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process
    {
        ## Avoid any $media variable scoping issues
        $media = $null

        ## If we have configuration data specific instance, return that
        if ($PSBoundParameters.ContainsKey('ConfigurationData'))
        {
            $customMedia = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Media.Where({ $_.Id -eq $Id -or $_.Alias -eq $Id })
            if ($customMedia)
            {
                $newLabMediaParams = @{ }
                foreach ($key in $customMedia.Keys)
                {
                    $newLabMediaParams[$key] = $customMedia.$key
                }
                $media = New-LabMedia @newLabMediaParams
            }
        }

        ## If we have custom media, return that
        if (-not $media)
        {
            $media = Get-ConfigurationData -Configuration CustomMedia
            $media = $media | Where-Object { $_.Id -eq $Id -or $_.Alias -eq $Id }
        }

        ## If we still don't have a media image, return the built-in object
        if (-not $media)
        {
            $media = Get-LabMedia -Id $Id
        }

        ## We don't have any defined, custom or built-in media
        if (-not $media)
        {
            throw ($localized.CannotLocateMediaError -f $Id)
        }

        return $media

    } #end process
} #end function
