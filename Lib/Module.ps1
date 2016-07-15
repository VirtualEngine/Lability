function GetModule {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Name
    )
    process {
        WriteVerbose -Message ($localized.LocatingModule -f $Name);
        ## Only return modules in the %ProgramFiles%\WindowsPowerShell\Modules location, ignore other $env:PSModulePaths
        $programFiles = [System.Environment]::GetFolderPath('ProgramFiles');
        $modulesPath = ('{0}\WindowsPowerShell\Modules' -f $programFiles).Replace('\','\\');
        $module = Get-Module -Name $Name -ListAvailable -Verbose:$false | Where-Object Path -match $modulesPath;
        if (-not $module) {
            WriteVerbose -Message ($localized.ModuleNotFound -f $Name);
        }
        else {
            WriteVerbose -Message ($localized.ModuleFoundInPath -f $module.Path);
        }
        return $module;
    } #end process
} #end function GetModule

function TestModuleVersion {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Path to the module's manifest file
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $ModulePath,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')] [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
        [System.Version] $RequiredVersion,

        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)] $RemainingArguments
    )
    process {
        try {
            WriteVerbose -Message ($localized.QueryingModuleVersion -f [System.IO.Path]::GetFileNameWithoutExtension($ModulePath));
            #$moduleManifest = Test-ModuleManifest -Path $ModulePath -Verbose:$false;
            $moduleManifest = ConvertToConfigurationData -ConfigurationData $ModulePath;
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
} #end function TestModuleVersion

function TestModule {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')] [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
        [System.Version] $RequiredVersion,

        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        $module = GetModule -Name $Name;
        if ($module) {
            $testModuleVersionParams = @{
                ModulePath = $module.Path;
            }
            if ($MinimumVersion) {
                $testModuleVersionParams['MinimumVersion'] = $MinimumVersion;
            }
            if ($RequiredVersion) {
                $testModuleVersionParams['RequiredVersion'] = $RequiredVersion;
            }
            return (TestModuleVersion @testModuleVersionParams);
        }
        else {
            return $false;
        }
    }
} #end function TestModule
