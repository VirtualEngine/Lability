function Remove-ConfigurationData {
<#
    .SYNOPSIS
        Removes custom lab configuration data file.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Host','VM','Media','CustomMedia')]
        [System.String] $Configuration
    )
    process {

        $configurationPath = Resolve-ConfigurationDataPath -Configuration $Configuration;
        if (Test-Path -Path $configurationPath) {
            Write-Verbose -Message ($localized.ResettingConfigurationDefaults -f $Configuration);
            Remove-Item -Path $configurationPath -Force;
        }

    } #end process
} # end function Remove-ConfigurationData
