function Resolve-ConfigurationDataPath {
<#
    .SYNOPSIS
        Resolves the lab configuration data path.
    .NOTES
        When -IncludeDefaultPath is specified, if the configuration data file is not found, the default
        module configuration path is returned.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Host','VM','Media','CustomMedia')]
        [System.String] $Configuration,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IncludeDefaultPath
    )
    process {

        switch ($Configuration) {

            'Host' {

                $configPath = $labDefaults.HostConfigFilename;
            }
            'VM' {

                $configPath = $labDefaults.VMConfigFilename;
            }
            'Media' {

                $configPath = $labDefaults.MediaConfigFilename;
            }
            'CustomMedia' {

                $configPath = $labDefaults.CustomMediaConfigFilename;
            }
        }
        $configPath = Join-Path -Path $labDefaults.ConfigurationData -ChildPath $configPath;
        $resolvedPath = Join-Path -Path "$env:ALLUSERSPROFILE\$($labDefaults.ModuleName)" -ChildPath $configPath;
        if ($IncludeDefaultPath) {

            if (-not (Test-Path -Path $resolvedPath)) {

                $resolvedPath = Join-Path -Path $labDefaults.ModuleRoot -ChildPath $configPath;
            }
        }
        $resolvedPath = ResolvePathEx -Path $resolvedPath;
        Write-Debug -Message ('Resolved ''{0}'' configuration file to ''{1}''.' -f $Configuration, $resolvedPath);
        return $resolvedPath;

    } #end process
} #end function ReolveConfigurationPath
