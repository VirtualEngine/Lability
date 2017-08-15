function TestModule {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,

        ## Catch all to be able to pass parameters via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $module = Get-LabModule -Name $Name;
        if ($module) {

            $testLabModuleVersionParams = @{
                ModulePath = $module.Path;
            }

            if ($MinimumVersion) {
                $testLabModuleVersionParams['MinimumVersion'] = $MinimumVersion;
            }

            if ($RequiredVersion) {
                $testLabModuleVersionParams['RequiredVersion'] = $RequiredVersion;
            }

            return (Test-LabModuleVersion @testLabModuleVersionParams);
        }
        else {
            return $false;
        }

    } #end process
} #end function
