function Get-LabModule {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name
    )
    process {

        Write-Verbose -Message ($localized.LocatingModule -f $Name);
        ## Only return modules in the %ProgramFiles%\WindowsPowerShell\Modules location, ignore other $env:PSModulePaths
        $programFiles = [System.Environment]::GetFolderPath('ProgramFiles');
        $modulesPath = ('{0}\WindowsPowerShell\Modules' -f $programFiles).Replace('\','\\');
        $module = Get-Module -Name $Name -ListAvailable -Verbose:$false | Where-Object Path -match $modulesPath;

        if (-not $module) {
            Write-Verbose -Message ($localized.ModuleNotFound -f $Name);
        }
        else {
            Write-Verbose -Message ($localized.ModuleFoundInPath -f $module.Path);
        }
        return $module;

    } #end process
} #end function
