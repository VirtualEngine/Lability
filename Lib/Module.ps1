function GetModule {
<#
    .SYNOPSIS
        Tests whether an exising PowerShell module meets the minimum or required version
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $Name
    )
    process {
        Write-Verbose ($localized.LocatingModule -f $Name);
        $module = Get-Module -Name $Name -ListAvailable;
        if (-not $module) {
            Write-Verbose ($localized.ModuleNotFound -f $Name);
        }
        else {
            Write-Verbose ($localized.ModuleFoundInPath -f $module.Path);
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
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $ModulePath,
        
        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')]
        [ValidateNotNullOrEmpty()] [System.Version] $MinimumVersion,
        
        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
        [System.Version] $RequiredVersion,
        
        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)] $RemainingArguments
    )
    process {
        try {
            WriteVerbose ($localized.QueryingModuleVersion -f $Name);
            $moduleManifest = Test-ModuleManifest -Path $module.Path;
            $moduleVersion = [System.Version] $moduleManifest.Version;
            Write-Verbose ($localized.ExistingModuleVersion -f $moduleVersion);
        }
        catch {
            Write-Error "Oops $Name"
        }
        if ($PSCmdlet.ParameterSetName -eq 'MinimumVersion') {
            return $moduleVersion -ge $MinimumVersion;
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'RequiredVersion') {
            return $moduleVersion -eq $RequiredVersion;
        }
    } #end process
} #end function TestModuleVersion
