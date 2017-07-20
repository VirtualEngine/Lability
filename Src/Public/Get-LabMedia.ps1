function Get-LabMedia {
<#
    .SYNOPSIS
        Gets registered lab media.
    .DESCRIPTION
        The Get-LabMedia cmdlet retrieves all built-in and registered custom media.
    .PARAMETER Id
        Specifies the specific media Id to return.
    .PARAMETER CustomOnly
        Specifies that only registered custom media are returned.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param (
        ## Media ID
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Only return custom media
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CustomOnly
    )
    process {

        ## Retrieve built-in media
        if (-not $CustomOnly) {

            $defaultMedia = Get-ConfigurationData -Configuration Media;
        }
        ## Retrieve custom media
        $customMedia = @(Get-ConfigurationData -Configuration CustomMedia);
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

        foreach ($mediaObject in $media) {

            $mediaObject.PSObject.TypeNames.Insert(0, 'VirtualEngine.Lability.Media');
            Write-Output -InputObject $mediaObject;
        }

    } #end process
} #end function
