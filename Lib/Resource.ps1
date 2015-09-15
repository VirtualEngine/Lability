function NewDirectory {
<#
    .SYNOPSIS
       Creates a filesystem directory.
    .DESCRIPTION
       The New-Directory cmdlet will create the target directory if it doesn't already exist. If the target path
       already exists, the cmdlet does nothing.
#>
    [CmdletBinding(DefaultParameterSetName = 'ByString', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        # Target filesystem directory to create
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            Position = 0, ParameterSetName = 'ByDirectoryInfo')]
        [ValidateNotNullOrEmpty()] [System.IO.DirectoryInfo[]] $InputObject,
        
        # Target filesystem directory to create
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true,
            Position = 0, ParameterSetName = 'ByString')] [Alias('PSPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $Path
    )
    process {
        Write-Debug ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
        switch ($PSCmdlet.ParameterSetName) {
            'ByString' {
                foreach ($directory in $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)) {
                    Write-Debug ("Testing target directory '{0}'." -f $directory);
                    if (!(Test-Path $directory -PathType Container)) {
                        if ($PSCmdlet.ShouldProcess($directory, "Create directory")) {
                            WriteVerbose ($localized.CreatingDirectory -f $directory);
                            New-Item -Path $directory -ItemType Directory;
                        }
                    } else {
                        WriteVerbose ($localized.DirectoryExists -f $directory);
                        Get-Item -Path $directory;
                    }
                } #end foreach directory
            } #end byString

            'ByDirectoryInfo' {
                 foreach ($directoryInfo in $InputObject) {
                    Write-Debug ("Testing target directory '{0}'." -f $directoryInfo.FullName);
                    if (!($directoryInfo.Exists)) {
                        if ($PSCmdlet.ShouldProcess($directoryInfo.FullName, "Create directory")) {
                            WriteVerbose ($localized.CreatingDirectory -f $directoryInfo.FullName);
                            New-Item -Path $directoryInfo.FullName -ItemType Directory;
                        }
                    } else {
                        WriteVerbose ($localized.DirectoryExists -f $directoryInfo.FullName);
                        $directoryInfo;
                    }
                } #end foreach directoryInfo
            } #end byDirectoryInfo
        } #end switch
    } #end process
} #end function NewDirectory

function GetResourceDownload {
<#
    .SYNOPSIS
        Retrieves a downloaded resource's checksum.
    .NOTES
        Based upon https://github.com/iainbrighton/cRemoteFile/blob/master/DSCResources/VE_RemoteFile/VE_RemoteFile.ps1
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $DestinationPath,
	    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Uri,
        [Parameter()] [AllowNull()] [System.String] $Checksum
        ##TODO: Support Headers and UserAgent
    )
    process {
        $checksumPath = '{0}.checksum' -f $DestinationPath;
		if (-not (Test-Path -Path $DestinationPath)) {
			WriteVerbose ($localized.MissingResourceFile -f $DestinationPath);
		}
        elseif (-not (Test-Path -Path $checksumPath)) {
            ## As it can take a long time to calculate the checksum, write it out to disk for future reference
            WriteVerbose ($localized.CalculatingResourceChecksum -f $checksumPath);
            $fileHash = Get-FileHash -Path $DestinationPath -Algorithm MD5 -ErrorAction Stop | Select-Object -ExpandProperty Hash;
            WriteVerbose ($localized.WritingResourceChecksum -f $fileHash, $checksumPath);
            $fileHash | Set-Content -Path $checksumPath -Force;
        }
        if (Test-Path -Path $checksumPath) {
            Write-Debug ('MD5 checksum file ''{0}'' found.' -f $checksumPath);
            $md5Checksum = (Get-Content -Path $checksumPath -Raw).Trim();
            Write-Debug ('Discovered MD5 checksum ''{0}''.' -f $md5Checksum);
            if ($Checksum -and ($md5Checksum -eq $Checksum)) {
                WriteVerbose ($localized.ResourceChecksumMatch -f $DestinationPath, $Checksum);
            }
            elseif ($Checksum) {
                WriteVerbose ($localized.ResourceChecksumMismatch  -f $DestinationPath, $Checksum);
            }
        }
        else {
            Write-Debug ('MD5 checksum file ''{0}'' not found.' -f $checksumPath);
        }
        $resource = @{
            DestinationPath = $DestinationPath;
            Uri = $Uri;
            Checksum = $md5Checksum;
        }
        return $resource;
    } #end process
} #end function GetResourceDownload

function TestResourceDownload {
<#
    .SYNOPSIS
        Tests if a web resource has been downloaded and whether the MD5 checksum is correct.
    .NOTES
        Based upon https://github.com/iainbrighton/cRemoteFile/blob/master/DSCResources/VE_RemoteFile/VE_RemoteFile.ps1
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $DestinationPath,
	    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Uri,
        [Parameter()] [AllowNull()] [System.String] $Checksum
        ##TODO: Support Headers and UserAgent
    )
    process {
        $resource = GetResourceDownload @PSBoundParameters;
        if ([System.String]::IsNullOrEmpty($Checksum) -and (Test-Path -Path $DestinationPath -PathType Leaf)) {
            return $true;
        }
        elseif ($Checksum -eq $resource.Checksum) {
            return $true;
        }
        else {
            return $false;
        }
    } #end process
} #end function TestResourceDownload

function SetResourceDownload {
<#
    .SYNOPSIS
        Downloads a (web) resource and creates a MD5 checksum.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $DestinationPath,
	    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Uri,
        [Parameter()] [AllowNull()] [System.String] $Checksum
        ##TODO: Support Headers and UserAgent
    )
    begin {
        $parentDestinationPath = Split-Path -Path $DestinationPath -Parent;
        [ref] $null = NewDirectory -Path $parentDestinationPath;
    }
    process {
        $destinationFilename = [System.IO.Path]::GetFileName($DestinationPath);
        $startBitsTransferParams = @{
            Source = $Uri;
            Destination = $DestinationPath;
            TransferType = 'Download';
            DisplayName = $localized.DownloadingActivity -f $destinationFilename;
            Description = $Uri;
            Priority = 'Foreground';
        }
        WriteVerbose ($localized.DownloadingResource -f $Uri, $DestinationPath);
        Start-BitsTransfer @startBitsTransferParams -ErrorAction Stop;

        ## Create the checksum file for future reference
        $checksumPath = '{0}.checksum' -f $DestinationPath;
        $fileHash = Get-FileHash -Path $DestinationPath -Algorithm MD5 -ErrorAction Stop | Select-Object -ExpandProperty Hash;
        WriteVerbose ($localized.WritingResourceChecksum -f $fileHash, $checksumPath);
        [ref] $null = $fileHash | Set-Content -Path $checksumPath -Force;
    } #end process
} #end function SetResourceDownload

function InvokeResourceDownload {
<#
    .SYNOPSIS
        Downloads a web resource if it has not already been downloaded or the checksum is incorrect.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $DestinationPath,
	    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Uri,
        [Parameter()] [AllowNull()] [System.String] $Checksum,
		[Parameter()] [System.Management.Automation.SwitchParameter] $Force
        ##TODO: Support Headers and UserAgent
    )
    process {
		$PSBoundParameters.Remove('Force');
        if (-not (TestResourceDownload @PSBoundParameters) -or $Force) {
            SetResourceDownload @PSBoundParameters -Verbose:$false;
        }
        return (GetResourceDownload @PSBoundParameters);
    } #end process
} #end function InvokeResourceDownload
