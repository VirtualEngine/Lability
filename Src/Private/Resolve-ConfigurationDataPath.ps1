function Resolve-ConfigurationDataPath {
<#
    .SYNOPSIS
        Resolves the lab configuration data path.
    .NOTES
        When -IncludeDefaultPath is specified, if the configuration data file is not found, the default
        module configuration path is returned.
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Host', 'VM', 'Media', 'CustomMedia','LegacyMedia')]
        [System.String] $Configuration,

        [Parameter(ParameterSetName = 'Default')]
        [System.Management.Automation.SwitchParameter] $IncludeDefaultPath,

        [Parameter(Mandatory, ParameterSetName = 'IsDefaultPath')]
        [System.Management.Automation.SwitchParameter] $IsDefaultPath
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
            'LegacyMedia' {

                $configPath = $labDefaults.LegacyMediaPath;
            }
        }
        $configPath = Join-Path -Path $labDefaults.ConfigurationData -ChildPath $configPath;
        $resolvedPath = Join-Path -Path "$env:ALLUSERSPROFILE\$($labDefaults.ModuleName)" -ChildPath $configPath;

        if ($IsDefaultPath) {

            $resolvedPath = Join-Path -Path $labDefaults.ModuleRoot -ChildPath $configPath;
        }
        elseif ($IncludeDefaultPath) {

            if (-not (Test-Path -Path $resolvedPath)) {

                $resolvedPath = Join-Path -Path $labDefaults.ModuleRoot -ChildPath $configPath;
            }
        }
        $resolvedPath = Resolve-PathEx -Path $resolvedPath;
        Write-Debug -Message ('Resolved ''{0}'' configuration path to ''{1}''.' -f $Configuration, $resolvedPath);
        return $resolvedPath;

    } #end process
} #end function ReolveConfigurationPath
