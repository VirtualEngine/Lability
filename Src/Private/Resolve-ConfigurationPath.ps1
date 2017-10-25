function Resolve-ConfigurationPath {
<#
    .SYNOPSIS
        Resolves a Lability image by its path.
    .DESCRIPTION
        When running Remove-LabVM there is not always a configuration document supplied. This
        causes issues removing a VMs VHD/X file. The ResolveLabImage function locates the image
        by its physical path.
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
            if (Test-Configurationpath -Name $Name -Path $resolvedPath) {

                return $resolvedPath;
            }
            elseif ($configurationName) {

                ## Search the Specified\ConfigurationName path
                $resolvedPath = Join-Path -Path $resolvedPath -ChildPath $configurationName;
                if (Test-Configurationpath -Name $Name -Path $resolvedPath) {

                    return $resolvedPath;
                }
            }
        }

        ## Search the ConfigurationPath path
        $configurationPath = Get-LabHostDscConfigurationPath;
        $resolvedPath = Resolve-PathEx -Path $configurationPath;
        if (Test-Configurationpath -Name $Name -Path $resolvedPath) {

            return $resolvedPath;
        }
        elseif ($configurationName) {

            ## Search the ConfigurationPath\ConfigurationName path
            $resolvedPath = Join-Path -Path $resolvedPath -ChildPath $configurationName;
            if (Test-Configurationpath -Name $Name -Path $resolvedPath) {

                return $resolvedPath;
            }
        }

        ## Search the Current path
        $currentPath = (Get-Location -PSProvider FileSystem).Path;
        $resolvedPath = Resolve-PathEx -Path $currentPath;
        if (Test-Configurationpath -Name $Name -Path $resolvedPath) {

            return $resolvedPath;
        }
        elseif ($configurationName) {

            ## Search the Current\ConfigurationName path
            $resolvedPath = Join-Path -Path $resolvedPath -ChildPath $configurationName;
            if (Test-Configurationpath -Name $Name -Path $resolvedPath) {

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
