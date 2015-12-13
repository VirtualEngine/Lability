function TestDscResourceModule {
<#
    .SYNOPSIS
        Tests whether the specified PowerShell module directory is a DSC resource.
    .DESCRIPTION
        The TestDscResourceModule determines whether the specified path is a PowerShell DSC resource module. This is
        used to only copy DSC resources to a VM's VHD(X) file - not ALL modules!
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [System.String] $Path,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [System.String] $ModuleName
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
} #end TestDscResourceModule

function GetDscResourceModule {
<#
    .SYNOPSIS
        Enumerates a directory path and returns list of all valid DSC resources.
    .DESCRIPTION
        The GetDscResourceModule returns all the PowerShell DSC resource modules in the specified path. This is used to
        determine which directories to copy to a VM's VHD(X) file. Only the latest version of module that is installed
        is returned, removing any versioned folders that are introduced in WMF 5.0, but cannot be interpreted by
        down-level WMF versions.
    .NOTES
        More context can be found here https://github.com/VirtualEngine/Lab/issues/25
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [System.String[]] $Path
    )
    process {
        foreach ($basePath in $Path) {
            Get-ChildItem -Path $basePath -Directory | ForEach-Object {
                $moduleInfo = $PSItem;
                ## Check to see if we have a MOF or class resource in the module
                if (TestDscResourceModule -Path $moduleInfo.FullName -ModuleName $moduleInfo.Name) {
                    Write-Debug -Message ('Discovered DSC resource ''{0}''.' -f $moduleInfo.FullName);
                    $module = Test-ModuleManifest -Path "$($moduleInfo.FullName)\$($moduleInfo.Name).psd1";
                    Write-Output -InputObject ([PSCustomObject] @{
                        ModuleName = $moduleInfo.Name;
                        ModuleVersion = [System.Version] $module.Version;
                        Path = $moduleInfo.FullName;
                    });
                }
                else {
                    ## Enumerate each module\<number>.<number> subdirectory
                    Get-ChildItem -Path $moduleInfo.FullName -Directory | Where-Object Name -match '^\d+\.\d+' | ForEach-Object {
                        Write-Debug -Message ('Checking module versioned directory ''{0}''.' -f $PSItem.FullName);
                        ## Test to see if it's a DSC resource module
                        if (TestDscResourceModule -Path $PSItem.FullName -ModuleName $moduleInfo.Name) {
                            try {
                                #$moduleVersion = [System.Version] $PSItem.Name;
                                Write-Debug -Message ('Discovered versioned DSC resource ''{0}''.' -f $PSItem.FullName);
                                Write-Output -InputObject ([PSCustomObject] @{
                                    ModuleName = $moduleInfo.Name;
                                    ModuleVersion = [System.Version] $PSItem.Name;
                                    Path = "$($moduleInfo.FullName)\$($PSItem.Name)";
                                });
                            }
                            catch { }
                        }
                    } | #end foreach module\<number>.<number> sub directory
                        Sort-Object -Property ModuleVersion -Descending | Select-Object -First 1;
                } 
            } #end foreach module directory
        } #end foreach path
    } #end process
} #end function GetDscResourceModule
