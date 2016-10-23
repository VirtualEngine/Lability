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
        THIS METHOD IS DEPRECATED IN FAVOUR OF THE NEW MODULE CACHE FUNCTIONALITY
        More context can be found here https://github.com/VirtualEngine/Lab/issues/25
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String[]] $Path
    )
    process {

        foreach ($basePath in $Path) {

            Get-ChildItem -Path $basePath -Directory | ForEach-Object {

                $moduleInfo = $PSItem;
                ## Check to see if we have a MOF or class resource in the module
                if (TestDscResourceModule -Path $moduleInfo.FullName -ModuleName $moduleInfo.Name) {
                    Write-Debug -Message ('Discovered DSC resource ''{0}''.' -f $moduleInfo.FullName);
                    $testModuleManifestPath = '{0}\{1}.psd1' -f $moduleInfo.FullName, $moduleInfo.Name;
                    ## Convert the .psd1 file into a hashtable (Test-ModuleManifest can actually load the module)
                    if (Test-Path -Path $testModuleManifestPath -PathType Leaf) {

                        $module = ConvertToConfigurationData -ConfigurationData $testModuleManifestPath;
                        Write-Output -InputObject ([PSCustomObject] @{
                            ModuleName = $moduleInfo.Name;
                            ModuleVersion = $module.ModuleVersion -as [System.Version];
                            Path = $moduleInfo.FullName;
                        });
                    }
                }
                else {
                    ## Enumerate each module\<number>.<number> subdirectory
                    Get-ChildItem -Path $moduleInfo.FullName -Directory | Where-Object Name -match '^\d+\.\d+' | ForEach-Object {
                        Write-Debug -Message ('Checking module versioned directory ''{0}''.' -f $PSItem.FullName);
                        ## Test to see if it's a DSC resource module
                        if (TestDscResourceModule -Path $PSItem.FullName -ModuleName $moduleInfo.Name) {
                            try {
                                Write-Debug -Message ('Discovered DSC resource ''{0}''.' -f  $PSItem.FullName);
                                $testModuleManifestPath = '{0}\{1}.psd1' -f  $PSItem.FullName, $moduleInfo.Name;
                                ## Convert the .psd1 file into a hashtable (Test-ModuleManifest can actually load the module)
                                $module = ConvertToConfigurationData -ConfigurationData $testModuleManifestPath;
                                Write-Output -InputObject ([PSCustomObject] @{
                                    ModuleName =  $moduleInfo.Name;
                                    ModuleVersion = [System.Version] $module.ModuleVersion;
                                    Path = $PSItem.FullName;
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

}

