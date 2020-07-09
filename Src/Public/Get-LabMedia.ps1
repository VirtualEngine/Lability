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
    .PARAMETER Legacy
        Specifies that legacy evaluation media definition(s) are returned. These deprecated media definitions can be
        reregistered using the Register-LabMedia cmdlet with the -Legacy switch.
    .EXAMPLE
        Get-LabMedia -Legacy

        Id                                     Arch Media Description
        --                                     ---- ----- -----------
        WIN10_x64_Enterprise_1709_EN_Eval       x64   ISO Windows 10 64bit Enterprise 1709 English Evaluation
        WIN10_x64_Enterprise_1803_EN_Eval       x64   ISO Windows 10 64bit Enterprise 1804 English Evaluation
        WIN10_x64_Enterprise_1809_EN_Eval       x64   ISO Windows 10 64bit Enterprise 1809 English Evaluation
        WIN10_x64_Enterprise_1903_EN_Eval       x64   ISO Windows 10 64bit Enterprise 1903 English Evaluation
        WIN10_x64_Enterprise_LTSB_2016_EN_Eval  x64   ISO Windows 10 64bit Enterprise LTSB 2016 English Evaluation
        WIN10_x86_Enterprise_1709_EN_Eval       x86   ISO Windows 10 32bit Enterprise 1709 English Evaluation
        WIN10_x86_Enterprise_1803_EN_Eval       x86   ISO Windows 10 32bit Enterprise 1804 English Evaluation
        WIN10_x86_Enterprise_1809_EN_Eval       x86   ISO Windows 10 32bit Enterprise 1809 English Evaluation
        WIN10_x86_Enterprise_1903_EN_Eval       x86   ISO Windows 10 32bit Enterprise 1903 English Evaluation
        WIN10_x86_Enterprise_LTSB_2016_EN_Eval  x86   ISO Windows 10 32bit Enterprise LTSB 2016 English Evaluation

        Returns deprecated/previous media definitions.
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param
    (
        ## Media ID or alias to return
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Only return custom media
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [System.Management.Automation.SwitchParameter] $CustomOnly,

        ## Only return legacy media
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Legacy')]
        [System.Management.Automation.SwitchParameter] $Legacy
    )
    process
    {
        if ($PSBoundParameters.ContainsKey('Legacy'))
        {
            $legacyMediaPath = Resolve-ConfigurationDataPath -Configuration LegacyMedia -IsDefaultPath
            $media = Get-ChildItem -Path $legacyMediaPath | ForEach-Object {
                        Get-Content -Path $_.FullName | ConvertFrom-Json
                    }

            if ($Id)
            {
                $media = $media | Where-Object { $_.Id -eq $Id };
            }
        }
        else
        {
            ## Retrieve built-in media
            if (-not $CustomOnly)
            {
                $defaultMedia = Get-ConfigurationData -Configuration Media;
            }
            ## Retrieve custom media
            $customMedia = @(Get-ConfigurationData -Configuration CustomMedia);
            if (-not $customMedia)
            {
                $customMedia = @();
            }

            ## Are we looking for a specific media Id
            if ($Id)
            {
                ## Return the custom media definition first (if it exists)
                $media = $customMedia | Where-Object { $_.Id -eq $Id -or $_.Alias -eq $Id };
                if ((-not $media) -and (-not $CustomOnly))
                {
                    ## We didn't find a custom media entry, return a default entry (if it exists)
                    $media = $defaultMedia | Where-Object { $_.Id -eq $Id -or $_.Alias -eq $Id };
                }
            }
            else
            {
                ## Return all media
                $media = $customMedia;
                if (-not $CustomOnly)
                {
                    foreach ($mediaEntry in $defaultMedia)
                    {
                        ## Determine whether the media is present in the custom media, i.e. make sure
                        ## we don't override a custom entry with the default one.
                        $defaultMediaEntry = $customMedia | Where-Object { $_.Id -eq $mediaEntry.Id }
                        ## If not, add it to the media array to return
                        if (-not $defaultMediaEntry)
                        {
                            $media += $mediaEntry;
                        }
                    } #end foreach default media
                } #end if not custom only
            }
        }

        foreach ($mediaObject in $media)
        {
            $mediaObject.PSObject.TypeNames.Insert(0, 'VirtualEngine.Lability.Media');
            Write-Output -InputObject $mediaObject;
        }

    } #end process
} #end function
