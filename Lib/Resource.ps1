function NewDirectory {
<#
    .SYNOPSIS
       Creates a filesystem directory.
    .DESCRIPTION
       The New-Directory cmdlet will create the target directory if it doesn't already exist. If the target path
       already exists, the cmdlet does nothing.
#>
    [CmdletBinding(DefaultParameterSetName = 'ByString', SupportsShouldProcess)]
    [OutputType([System.IO.DirectoryInfo])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        # Target filesystem directory to create
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByDirectoryInfo')]
        [ValidateNotNullOrEmpty()] [System.IO.DirectoryInfo[]] $InputObject,
        
        # Target filesystem directory to create
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByString')] [Alias('PSPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $Path
    )
    process {
        Write-Debug -Message ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
        switch ($PSCmdlet.ParameterSetName) {
            'ByString' {
                foreach ($directory in $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)) {
                    Write-Debug -Message ("Testing target directory '{0}'." -f $directory);
                    if (!(Test-Path -Path $directory -PathType Container)) {
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
                    Write-Debug -Message ("Testing target directory '{0}'." -f $directoryInfo.FullName);
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

function SetResourceChecksum {
<#
    .SYNOPSIS
        Creates a resource's checksum file.
#>
    param (
        ## Path of file to create the checksum of
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $Path
    )
    process {
        $checksumPath = '{0}.checksum' -f $Path;
        ## As it can take a long time to calculate the checksum, write it out to disk for future reference
        WriteVerbose ($localized.CalculatingResourceChecksum -f $checksumPath);
        $fileHash = Get-FileHash -Path $Path -Algorithm MD5 -ErrorAction Stop | Select-Object -ExpandProperty Hash;
        WriteVerbose ($localized.WritingResourceChecksum -f $fileHash, $checksumPath);
        $fileHash | Set-Content -Path $checksumPath -Force;
    }
} #end function SetResourceChecksum

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
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Uri,
        
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.String] $Checksum,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    process {
        $checksumPath = '{0}.checksum' -f $DestinationPath;
        if (-not (Test-Path -Path $DestinationPath)) {
            WriteVerbose ($localized.MissingResourceFile -f $DestinationPath);
        }
        elseif (-not (Test-Path -Path $checksumPath)) {
            [ref] $null = SetResourceChecksum -Path $DestinationPath;
        }
        if (Test-Path -Path $checksumPath) {
            Write-Debug -Message ('MD5 checksum file ''{0}'' found.' -f $checksumPath);
            $md5Checksum = (Get-Content -Path $checksumPath -Raw).Trim();
            Write-Debug -Message ('Discovered MD5 checksum ''{0}''.' -f $md5Checksum);
        }
        else {
            Write-Debug -Message ('MD5 checksum file ''{0}'' not found.' -f $checksumPath);
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
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Uri,
        
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.String] $Checksum,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    process {
        $resource = GetResourceDownload @PSBoundParameters;
        if ([System.String]::IsNullOrEmpty($Checksum) -and (Test-Path -Path $DestinationPath -PathType Leaf)) {
            WriteVerbose ($localized.ResourceChecksumNotSpecified -f $DestinationPath);
            return $true;
        }
        elseif ($Checksum -eq $resource.Checksum) {
            WriteVerbose ($localized.ResourceChecksumMatch -f $DestinationPath, $Checksum);
            return $true;
        }
        else {
            WriteVerbose ($localized.ResourceChecksumMismatch  -f $DestinationPath, $Checksum);
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
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Uri,
        
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.String] $Checksum,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    begin {
        $parentDestinationPath = Split-Path -Path $DestinationPath -Parent;
        [ref] $null = NewDirectory -Path $parentDestinationPath;
    }
    process {
        if (-not $PSBoundParameters.ContainsKey('BufferSize')) {
            $systemUri = New-Object -TypeName System.Uri -ArgumentList @($uri);
            if ($systemUri.IsFile) {
                $BufferSize = 1MB;
            }
        }
        WriteVerbose ($localized.DownloadingResource -f $Uri, $DestinationPath);
        InvokeWebClientDownload -DestinationPath $DestinationPath -Uri $Uri -BufferSize $BufferSize;

        ## Create the checksum file for future reference
        [ref] $null = SetResourceChecksum -Path $DestinationPath;
    } #end process
} #end function SetResourceDownload

function InvokeWebClientDownload {
<#
    .SYNOPSIS
        Downloads a (web) resource using System.Net.WebClient.
    .NOTES
        This solves issue #19 when running downloading resources using BITS under alternative credentials.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $DestinationPath,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Uri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB,
        
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    process {
        try {
            [System.Net.WebClient] $webClient = New-Object -TypeName 'System.Net.WebClient';
            $webClient.Headers.Add('user-agent', $labDefaults.ModuleName);
            $webClient.Proxy = [System.Net.WebRequest]::GetSystemWebProxy();
            if (-not $webClient.Proxy.IsBypassed($Uri)) {
                $proxyInfo = $webClient.Proxy.GetProxy($Uri);
                WriteVerbose ($localized.UsingProxyServer -f $proxyInfo.AbsoluteUri);
            }
            if ($Credential) {
                $webClient.Credentials = $Credential;
                $webClient.Proxy.Credentials = $Credential;
            }
            else {
                $webClient.UseDefaultCredentials = $true;
                $webClient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials;
            }
            [System.IO.Stream] $inputStream = $webClient.OpenRead($Uri);
            [System.UInt64] $contentLength = $webClient.ResponseHeaders['Content-Length'];
            $path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationPath);
            [System.IO.Stream] $outputStream = [System.IO.File]::Create($path);
            [System.Byte[]] $buffer = New-Object -TypeName System.Byte[] -ArgumentList $BufferSize;
            [System.UInt64] $bytesRead = 0;
            [System.UInt64] $totalBytes = 0;
            $writeProgessActivity = $localized.DownloadingActivity -f $Uri;
            do {
                $bytesRead = $inputStream.Read($buffer, 0, $buffer.Length);
                $totalBytes += $bytesRead;
                $outputStream.Write($buffer, 0, $bytesRead);
                ## Avoid divide by zero
                if ($contentLength -gt 0) {
                    [System.Byte] $percentComplete = ($totalBytes/$contentLength) * 100;
                    $writeProgressParams = @{
                        Activity = $writeProgessActivity;
                        PercentComplete = $percentComplete;
                        Status = $localized.DownloadStatus -f $totalBytes, $contentLength, $percentComplete;
                    }
                    Write-Progress @writeProgressParams;
                }
            }
            while ($bytesRead -ne 0)
            $outputStream.Close();
            return (Get-Item -Path $path);
        }
        catch {
            throw ($localized.ResourceDownloadFailedError -f $Uri);
        }
        finally {
            Write-Progress -Activity $writeProgessActivity -Completed;
            if ($null -ne $outputStream) { $outputStream.Close(); }
            if ($null -ne $inputStream) { $inputStream.Close(); }
            if ($null -ne $webClient) { $webClient.Dispose(); }
        }
    } #end process
} #end function InvokeWebClientDownload

function InvokeResourceDownload {
<#
    .SYNOPSIS
        Downloads a web resource if it has not already been downloaded or the checksum is incorrect.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Uri,
        
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.String] $Checksum,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    process {
        [ref] $null = $PSBoundParameters.Remove('Force');
        if (-not (TestResourceDownload @PSBoundParameters) -or $Force) {
            SetResourceDownload @PSBoundParameters -Verbose:$false;
        }
        $resource = GetResourceDownload @PSBoundParameters;
        return [PSCustomObject] $resource;
    } #end process
} #end function InvokeResourceDownload
