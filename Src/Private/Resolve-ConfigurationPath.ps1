function Resolve-ConfigurationPath {
<#
    .SYNOPSIS
        Resolves a node's .mof configuration file path.
    .DESCRIPTION
        Searches the current working directory and host configuration data path for a node's .mof
        files, searching an environment name subdirectory if environment name is defined.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab vm/node name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Defined .mof path
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Path,

        ## Do not throw and return default configuration path
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $UseDefaultPath
    )
    process {

        Write-Verbose -Message ($localized.SearchingConfigurationPaths);
        try {

            ## Do we have an environment name?
            $configurationName = $ConfigurationData.NonNodeData[$labDefaults.moduleName].EnvironmentName;
        }
        catch {

            Write-Debug -Message 'No environment name defined';
        }

        if (-not [System.String]::IsNullOrEmpty($Path)) {

            ## Search the Specified path
            $resolvedPath = Resolve-PathEx -Path $Path;
            if (Test-ConfigurationPath -Name $Name -Path $resolvedPath) {

                return $resolvedPath;
            }
            elseif ($configurationName) {

                ## Search the Specified\ConfigurationName path
                $resolvedPath = Join-Path -Path $resolvedPath -ChildPath $configurationName;
                if (Test-ConfigurationPath -Name $Name -Path $resolvedPath) {

                    return $resolvedPath;
                }
            }
        }

        ## Search the ConfigurationPath path
        $configurationPath = Get-LabHostDscConfigurationPath;
        $resolvedPath = Resolve-PathEx -Path $configurationPath;
        if (Test-ConfigurationPath -Name $Name -Path $resolvedPath) {

            return $resolvedPath;
        }
        elseif ($configurationName) {

            ## Search the ConfigurationPath\ConfigurationName path
            $resolvedPath = Join-Path -Path $resolvedPath -ChildPath $configurationName;
            if (Test-ConfigurationPath -Name $Name -Path $resolvedPath) {

                return $resolvedPath;
            }
        }

        ## Search the Current path
        $currentPath = (Get-Location -PSProvider FileSystem).Path;
        $resolvedPath = Resolve-PathEx -Path $currentPath;
        if (Test-ConfigurationPath -Name $Name -Path $resolvedPath) {

            return $resolvedPath;
        }
        elseif ($configurationName) {

            ## Search the Current\ConfigurationName path
            $resolvedPath = Join-Path -Path $resolvedPath -ChildPath $configurationName;
            if (Test-ConfigurationPath -Name $Name -Path $resolvedPath) {

                return $resolvedPath;
            }
        }

        if ($UseDefaultPath) {

            if (-not [System.String]::IsNullOrEmpty($Path)) {

                ## Return the specified path
                return (Resolve-PathEx -Path $Path);
            }
            else {

                ## Return the default configuration path
                return Get-LabHostDscConfigurationPath;
            }
        }
        else {

            ## We cannot resolve/locate the mof files..
            throw ($localized.CannotLocateMofFileError -f $Name);
        }

    } #end process
} #end function Resolve-ConfigurationPath
