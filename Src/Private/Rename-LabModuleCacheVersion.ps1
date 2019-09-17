function Rename-LabModuleCacheVersion {
<#
    .SYNOPSIS
        Renames a cached module zip file with its version number.
#>
    [CmdletBinding(DefaultParameterSetName = 'PSGallery')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## GitHub module repository owner
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GitHub')]
        [System.String] $Owner,

        ## GitHub module branch
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GitHub')]
        [System.String] $Branch,

        ## The minimum version of the module required
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Version] $RequiredVersion
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
            $moduleManifest = Get-LabModuleCacheManifest -Path $Path -Provider 'GitHub';
            $moduleVersion = $moduleManifest.ModuleVersion;
            $versionedModuleFilename = '{0}-v{1}_{2}_{3}.zip' -f $Name, $moduleVersion, $Owner, $Branch;
        }
        else {
            $moduleManifest = Get-LabModuleCacheManifest -Path $Path;
            $moduleVersion = $moduleManifest.ModuleVersion;
            $versionedModuleFilename = '{0}-v{1}.zip' -f $Name, $moduleVersion;
        }

        if ($PSBoundParameters.ContainsKey('RequiredVersion')) {

            if ($moduleVersion -ne $RequiredVersion) {
                throw ($localized.ModuleVersionMismatchError -f $Name, $moduleVersion, $RequiredVersion);
            }
        }
        elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {

            if ($moduleVersion -lt $MinimumVersion) {
                throw ($localized.ModuleVersionMismatchError -f $Name, $moduleVersion, $MinimumVersion);
            }
        }

        $versionedModulePath = Join-Path -Path (Split-Path -Path $Path -Parent) -ChildPath $versionedModuleFilename;

        if (Test-Path -Path $versionedModulePath -PathType Leaf) {
            ## Remove existing version module
            Remove-Item -Path $versionedModulePath -Force -Confirm:$false;
        }

        Rename-Item -Path $Path -NewName $versionedModuleFilename;
        return (Get-Item -Path $versionedModulePath);

    } #end process
} #end function
