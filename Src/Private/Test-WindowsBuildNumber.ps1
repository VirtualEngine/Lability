function Test-WindowsBuildNumber {
    <#
        .SYNOPSIS
            Validates the host build meets the specified requirements.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Minimum Windows build number required
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Int32] $MinimumVersion
    )
    begin {

        if (($null -ne $PSVersion.PSEdition) -and ($PSVersion.PSEdition -eq 'Core')) {

            # New-NotSupportedException
        }
    }
    process {

        $buildNumber = $PSVersionTable.BuildVersion.Build;
        return $buildNumber -ge $MinimumVersion;

    } #end process
} #end function
