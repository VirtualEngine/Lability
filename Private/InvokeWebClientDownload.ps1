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

            throw ($localized.WebResourceDownloadFailedError -f $Uri);
        }
        finally {

            if ($null -ne $writeProgressActivity) {
                Write-Progress -Activity $writeProgessActivity -Completed;
            }
            if ($null -ne $outputStream) {
                $outputStream.Close();
            }
            if ($null -ne $inputStream) {
                $inputStream.Close();
            }
            if ($null -ne $webClient) {
                $webClient.Dispose();
            }
        }

    } #end process

}

