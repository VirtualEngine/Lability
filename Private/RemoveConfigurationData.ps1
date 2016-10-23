function RemoveConfigurationData {

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

        $configurationPath = ResolveConfigurationDataPath -Configuration $Configuration;
        if (Test-Path -Path $configurationPath) {
            WriteVerbose ($localized.ResettingConfigurationDefaults -f $Configuration);
            Remove-Item -Path $configurationPath -Force;
        }

    } #end process

}

