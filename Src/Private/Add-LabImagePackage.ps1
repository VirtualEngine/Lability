function Add-LabImageWindowsPackage {
<#
    .SYNOPSIS
        Adds a Windows package to an image.
#>
    [CmdletBinding()]
    param (
        ## Windows packages (.cab) files to add to the image after expansion
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String[]] $Package,

        ## Path to the .cab files
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $PackagePath,

        ## Mounted VHD(X) Operating System disk drive
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        ## Package localization directory/extension (primarily used for Nano Server)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $PackageLocale = 'en-US',

        ## DISM log path
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LogPath = $DestinationPath
    )
    process {

        foreach ($packageName in $Package) {

            WriteVerbose ($localized.AddingWindowsPackage -f $packagename, $DestinationPath);
            $packageFilename = '{0}.cab' -f $packageName;
            $packageFilePath = Join-Path -Path $PackagePath -ChildPath $packageFilename;
            Add-DiskImagePackage -Name $packageName -Path $packageFilePath -DestinationPath $DestinationPath;

            ## Check for language-specific package (Change from Server 2016 TP releases and Server 2016 Nano RTM)
            if ($PSBoundParameters.ContainsKey('PackageLocale')) {

                $localizedPackageName = '{0}_{1}' -f $packageName, $packageLocale;
                $localizedPackageFilename = '{0}.cab' -f $localizedPackageName;
                $localizedPackageDirectoryPath = Join-Path -Path $PackagePath -ChildPath $PackageLocale;
                $localizedPackagePath = Join-Path -Path $localizedPackageDirectoryPath -ChildPath $localizedPackageFilename;
                if (Test-Path -Path $localizedPackagePath -PathType Leaf) {

                    WriteVerbose ($localized.AddingLocalizedWindowsPackage -f $localizedPackageName, $DestinationPath);
                    $addDiskImagePackageParams = @{
                        Name = $localizedPackageName;
                        Path = $localizedPackagePath;
                        DestinationPath = $DestinationPath;
                    }
                    Add-DiskImagePackage @addDiskImagePackageParams;
                }
            }

        } #end foreach package

    } #end process
} #end function Add-LabImageWindowsPackage
