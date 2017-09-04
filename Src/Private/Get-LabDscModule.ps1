function Get-LabDscModule {
<#
    .SYNOPSIS
        Locates the directory path of the ResourceName within the specified DSC ModuleName.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory)]
        [System.String] $ModuleName,

        [Parameter()]
        [System.String] $ResourceName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $MinimumVersion
    )
    process {

        $module = Get-Module -Name $ModuleName -ListAvailable;
        $dscModulePath = Split-Path -Path $module.Path -Parent;

        if ($ResourceName) {

            $ModuleName = '{0}\{1}' -f $ModuleName, $ResourceName;
            $dscModulePath = Join-Path -Path $dscModulePath -ChildPath "DSCResources\$ResourceName";
        }

        if (-not (Test-Path -Path $dscModulePath)) {

            Write-Error -Message ($localized.DscResourceNotFoundError -f $ModuleName);
            return $null;
        }

        if ($MinimumVersion) {

            if ($Module.Version -lt [System.Version]$MinimumVersion) {

                Write-Error -Message ($localized.ResourceVersionMismatchError -f $ModuleName, $module.Version.ToString(), $MinimumVersion);
                return $null;
            }
        }

        return $dscModulePath;

    } #end process
} #end function
