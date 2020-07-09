function Get-LabMediaId
{
<#
    .SYNOPSIS
        Helper method for dynamic media Id parameters, returning all valid media Ids and Aliases.
#>
    [CmdletBinding()]
    param( )
    process
    {
        $availableMedia = Get-LabMedia
        $mediaIds = @{ }
        foreach ($media in $availableMedia)
        {
            $mediaIds[$media.Id] = $media.Id
            if ($null -ne $media.Alias)
            {
                if ($mediaIds.ContainsKey($media.Alias))
                {
                    Write-Warning -Message ($localizedData.DuplicateMediaAliasIgnoredWarning -f $media.Id, $media.Alias)
                }
                else
                {
                    $mediaIds[$media.Alias] = $media.Alias
                }
            }
        }
        return $mediaIds.Keys
    }
}
