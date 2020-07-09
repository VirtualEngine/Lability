function Unregister-LabMedia {
<#
    .SYNOPSIS
        Unregisters a custom media entry.
    .DESCRIPTION
        The Unregister-LabMedia cmdlet allows removing custom media entries from the host's configuration.
    .LINK
        Get-LabMedia
        Register-LabMedia
#>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideDefaultParameterValue', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param
    (
        ## Specifies the custom media Id (or alias) to unregister. You cannot unregister the built-in media.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Id
    )
    process
    {
        ## Get the custom media list
        $customMedia = Get-ConfigurationData -Configuration CustomMedia
        if (-not $customMedia)
        {
            ## We don't have anything defined
            Write-Warning -Message ($localized.NoCustomMediaFoundWarning -f $Id)
            return
        }
        else
        {
            ## Check if we have a matching Id
            $media = $customMedia | Where-Object { $_.Id -eq $Id -or $_.Alias -eq $Id }
            if (-not $media)
            {
                ## We don't have a custom matching Id registered
                Write-Warning -Message ($localized.NoCustomMediaFoundWarning -f $Id)
                return
            }
        }

        $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Unregister-LabMedia', $Id
        $verboseProcessMessage = $localized.RemovingCustomMediaEntry -f $Id
        if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning))
        {
            $customMedia = $customMedia | Where-Object { $_.Id -ne $Id }
            Write-Verbose -Message ($localized.SavingConfiguration -f $Id)
            Set-ConfigurationData -Configuration CustomMedia -InputObject @($customMedia)
            return $media
        }

    } #end process
} #end function
