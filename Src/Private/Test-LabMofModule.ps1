function Test-LabMofModule {
<#
    .SYNOPSIS
        Tests whether the modules defined in a .mof file match the modules defined in the Lability
        configuration document.
#>
    [CmdletBinding()]
    param (
        ## List of resource modules defined in the Lability configuration file
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Module,

        ## List of resource modules defined in the MOF file
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $MofModule
    )
    process {

        $isCompliant = $true;

        foreach ($mof in $mofModule) {

            foreach ($labModule in $Module) {

                if ($labModule.Name -eq $mof.Name) {

                    $isModuleDefined = $true;
                    $isVersionMismatch = $false;

                    if ($labModule.MinimumVersion) {

                        Write-Warning -Message ($localized.ModuleUsingMinimumVersionWarning -f $labModule.Name);
                        if ($labModule.MinimumVersion -ne $mof.RequiredVersion) {

                            $isVersionMismatch = $true;
                            $version = $labModule.MinimumVersion;

                        }
                    }
                    elseif ($labModule.RequiredVersion) {

                        if ($labModule.RequiredVersion -ne $mof.RequiredVersion) {

                            $isVersionMismatch = $true;
                            $version = $labModule.RequiredVersion;

                        }
                    }
                    else {

                        ## We have no way of knowing whether we have the right version :()
                        Write-Warning -Message ($locaized.ModuleMissingRequiredVerWarning -f $labModule.Name);
                    }

                    if ($isVersionMismatch) {

                        $isCompliant = $false;
                        Write-Warning -Message ($localized.MofModuleVersionMismatchWarning -f $labModule.Name, $mof.RequiredVersion, $version);
                    }
                }

            } #end foreach configuration module

            if (-not $isModuleDefined) {

                $isCompliant = $false;
                Write-Warning -Message ($localized.ModuleMissingDefinitionWarning -f $mof.Name);
            }

        } #end foreach Mof module

        return $isCompliant;

    } #end process
} #end function
