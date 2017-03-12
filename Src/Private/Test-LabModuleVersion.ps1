function Test-LabModuleVersion {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Path to the module's manifest file
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ModulePath,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')] [ValidateNotNullOrEmpty()]
        [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,

        ## Catch all to be able to pass parameters via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)] $RemainingArguments
    )
    process {

        try {

            WriteVerbose -Message ($localized.QueryingModuleVersion -f [System.IO.Path]::GetFileNameWithoutExtension($ModulePath));
            $moduleManifest = ConvertTo-ConfigurationData -ConfigurationData $ModulePath;
            WriteVerbose -Message ($localized.ExistingModuleVersion -f $moduleManifest.ModuleVersion);
        }
        catch {

            Write-Error "Oops $ModulePath"
        }

        if ($PSCmdlet.ParameterSetName -eq 'MinimumVersion') {

            return (($moduleManifest.ModuleVersion -as [System.Version]) -ge $MinimumVersion);
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'RequiredVersion') {

            return (($moduleManifest.ModuleVersion -as [System.Version]) -eq $RequiredVersion);
        }

    } #end process
} #end function Test-LabModuleVersion
