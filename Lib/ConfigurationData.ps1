function ConvertToConfigurationData {
<#
    .SYNOPSIS
        Converts a file path string to a hashtable. This mimics the -ConfigurationData parameter of the
        Start-DscConfiguration cmdlet.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    process {
        if ($ConfigurationData -is [System.String]) {
            $configurationDataPath = Resolve-Path -Path $ConfigurationData -ErrorAction Stop;
            if (-not (Test-Path -Path $configurationDataPath -PathType Leaf)) {
                throw "Invalid configuration data file";
            }
            elseif ([System.IO.Path]::GetExtension($configurationDataPath) -ne '.psd1') {
                throw "Invalid configuration data file";
            }
            $configurationDataContent = Get-Content -Path $configurationDataPath -Raw;
            $ConfigurationData = Invoke-Command -ScriptBlock ([System.Management.Automation.ScriptBlock]::Create($configurationDataContent));
        }
        if ($ConfigurationData -isnot [System.Collections.Hashtable]) {
            throw "Invalid configuration data type";
        }
        return $ConfigurationData;
    }
} #end function ConvertToConfigurationData

function ResolveConfigurationDataPath {
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
        [Parameter(Mandatory)] [ValidateSet('Host','VM','Media','CustomMedia')] [System.String] $Configuration,
        [Parameter()] [System.Management.Automation.SwitchParameter] $IncludeDefaultPath
    )
    process {
        switch ($Configuration) {
            'Host' { $configPath = $labDefaults.HostConfigFilename; }
            'VM' { $configPath = $labDefaults.VMConfigFilename; }
            'Media' { $configPath = $labDefaults.MediaConfigFilename; }
            'CustomMedia' { $configPath = $labDefaults.CustomMediaConfigFilename; }
        }
        $configPath = Join-Path -Path $labDefaults.ConfigurationData -ChildPath $configPath;
        $resolvedPath = Join-Path -Path "$env:ALLUSERSPROFILE\$($labDefaults.ModuleName)" -ChildPath $configPath;
        if ($IncludeDefaultPath) {
            if (-not (Test-Path -Path $resolvedPath)) {
                $resolvedPath = Join-Path -Path $labDefaults.ModuleRoot -ChildPath $configPath;
            }
        }
        Write-Debug -Message ('Resolved ''{0}'' configuration file to ''{1}''.' -f $Configuration, $resolvedPath);
        return $resolvedPath;
    } #end process
} #end function ReolveConfigurationPath

function GetConfigurationData {
<#
    .SYNOPSIS
        Gets lab configuration data.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)] [ValidateSet('Host','VM','Media','CustomMedia')] [System.String] $Configuration
    )
    process {
        $configurationPath = ResolveConfigurationDataPath -Configuration $Configuration -IncludeDefaultPath;
        $expandedPath = [System.Environment]::ExpandEnvironmentVariables($configurationPath);
        if (Test-Path -Path $expandedPath) {
            $configurationData = Get-Content -Path $expandedPath -Raw | ConvertFrom-Json;
            
            # Expand any environment variables in configuration data
            $configurationData.psobject.Members | Where-Object {
                ($_.MemberType -eq 'NoteProperty') -and ($_.IsSettable) -and ($_.TypeNameOfValue -eq 'System.String')
            } | ForEach-Object {
                $_.Value = [System.Environment]::ExpandEnvironmentVariables($_.Value) 
            }
            
            switch ($Configuration) {
                'VM' {
                    ## This property may not be present in the original VM default file TODO: Could be deprecated in the future
                    if ($configurationData.PSObject.Properties.Name -notcontains 'CustomBootstrapOrder') {
                        [ref] $null = Add-Member -InputObject $configurationData -MemberType NoteProperty -Name 'CustomBootstrapOrder' -Value 'MediaFirst';
                    }
                }
                Default {
                    ## Do nothing
                }
            } #end switch
            return $configurationData;
        }
    } #end process
} #end function GetConfigurationData

function SetConfigurationData {
<#
    .SYNOPSIS
        Saves lab configuration data.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)] [ValidateSet('Host','VM','Media','CustomMedia')] [System.String] $Configuration,
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $InputObject
    )
    process {
        $configurationPath = ResolveConfigurationDataPath -Configuration $Configuration;
        $expandedPath = [System.Environment]::ExpandEnvironmentVariables($configurationPath);
        [ref] $null = NewDirectory -Path (Split-Path -Path $expandedPath -Parent);
        Set-Content -Path $expandedPath -Value (ConvertTo-Json -InputObject $InputObject) -Force -Confirm:$false;
    }
} #end function SetConfigurationData

function RemoveConfigurationData {
<#
    .SYNOPSIS
        Removes custom lab configuration data file.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)] [ValidateSet('Host','VM','Media','CustomMedia')] [System.String] $Configuration
    )
    process {
        $configurationPath = ResolveConfigurationDataPath -Configuration $Configuration;
        $expandedPath = [System.Environment]::ExpandEnvironmentVariables($configurationPath);
        if (Test-Path -Path $expandedPath) {
            WriteVerbose ($localized.ResettingConfigurationDefaults -f $Configuration);
            Remove-Item -Path $expandedPath -Force;
        }
    }
} # end function RemoveConfigurationData
