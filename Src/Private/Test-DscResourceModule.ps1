function Test-DscResourceModule {
<#
    .SYNOPSIS
        Tests whether the specified PowerShell module directory is a DSC resource.
    .DESCRIPTION
        The Test-DscResourceModule determines whether the specified path is a PowerShell DSC resource module. This is
        used to only copy DSC resources to a VM's VHD(X) file - not ALL modules!
    .NOTES
        THIS METHOD IS DEPRECATED IN FAVOUR OF THE NEW MODULE CACHE FUNCTIONALITY
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ModuleName
    )
    process {

        ## This module contains a \DSCResources folder, but we don't want to enumerate this!
        if ($Path -notmatch "\\$($labDefaults.ModuleName)$") {

            Write-Debug -Message ('Testing for MOF-based DSC Resource ''{0}'' directory.' -f "$Path\DSCResources");
            if (Test-Path -Path "$Path\DSCResources" -PathType Container) {

                ## We have a WMF 4.0/MOF DSC resource module
                Write-Debug -Message ('Found MOF-based DSC resource ''{0}''.' -f $Path);
                return $true;
            }

            Write-Debug -Message ('Testing for Class-based DSC resource definition ''{0}''.' -f "$Path\$ModuleName.psm1");
            if (Test-Path -Path "$Path\$ModuleName.psm1") {

                $psm1Content = Get-Content -Path "$Path\$ModuleName.psm1";
                ## If there's a .psm1 file, check if it's a class-based DSC resource
                if ($psm1Content -imatch '^(\s*)\[DscResource\(\)\](\s*)$') {

                    ## File has a [DscResource()] declaration
                    Write-Debug -Message ('Found Class-based DSC resource ''{0}''.' -f $Path);
                    return $true;
                }
            }
        } #end if this module

        return $false;

    } #end process
} #end function