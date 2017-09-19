function Add-DiskImagePackage {
<#
    .SYNOPSIS
        Adds a Windows package (.cab) to an image. This is implmented primarily to support injection of
        packages into Nano server images.
    .NOTES
        The real difference between a hotfix and package is that a package can either be specified in the
        master VHD(X) image creation OR be injected into VHD(X) differencing disk.
#>
    [CmdletBinding()]
    param (
        ## Package name (used for logging)
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Name,

        ## File path to the package (.cab) file
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## Destination operating system path (mounted VHD), i.e. G:\
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $DestinationPath
    )
    begin {

        ## We just want the drive letter
        if ($DestinationPath.Length -gt 1) {

            $DestinationPath = $DestinationPath.Substring(0,1);
        }

    }
    process {

        $logPath = '{0}:\Windows\Logs\{1}' -f $DestinationPath, $labDefaults.ModuleName;
        [ref] $null = New-Directory -Path $logPath -Verbose:$false;

        Write-Verbose -Message ($localized.AddingImagePackage -f $Name, $DestinationPath);
        $addWindowsPackageParams = @{
            PackagePath = $Path;
            Path = '{0}:\' -f $DestinationPath;
            LogPath = '{0}\{1}.log' -f $logPath, $Name;
            LogLevel = 'Errors';
        }
        [ref] $null = Microsoft.Dism.Powershell\Add-WindowsPackage @addWindowsPackageParams -Verbose:$false;

    } #end process
} #end function
