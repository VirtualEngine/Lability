function RenameModuleCacheVersion {

<#
    .SYNOPSIS
        Renames a cached module zip file with its version number.
#>
    [CmdletBinding(DefaultParameterSetName = 'PSGallery')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## GitHub module repository owner
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GitHub')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Owner,

        ## GitHub module branch
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GitHub')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'GitHub') {
            $moduleManifest = GetModuleCacheManifest -Path $Path -Provider 'GitHub';
            $versionedModuleFilename = '{0}-v{1}_{2}_{3}.zip' -f $Name, $moduleManifest.ModuleVersion, $Owner, $Branch;
        }
        else {
            $moduleManifest = GetModuleCacheManifest -Path $Path;
            $versionedModuleFilename = '{0}-v{1}.zip' -f $Name, $moduleManifest.ModuleVersion;
        }

        $versionedModulePath = Join-Path -Path (Split-Path -Path $Path -Parent) -ChildPath $versionedModuleFilename;

        if (Test-Path -Path $versionedModulePath -PathType Leaf) {
            ## Remove existing version module
            Remove-Item -Path $versionedModulePath -Force -Confirm:$false;
        }

        Rename-Item -Path $Path -NewName $versionedModuleFilename;
        return (Get-Item -Path $versionedModulePath);

    } #end process

}

