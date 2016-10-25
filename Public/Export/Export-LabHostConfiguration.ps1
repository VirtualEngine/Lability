function Export-LabHostConfiguration {

<#
    .SYNOPSIS
        Backs up the current lab host configuration.
    .LINK
        Import-LabHostConfiguration
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Specifies the export path location.
        [Parameter(Mandatory, ParameterSetName = 'Path', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [Alias("PSPath")]
        [System.String] $Path,

        # Specifies a literal export location path.
        [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $LiteralPath,

        ## Do not overwrite an existing file
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoClobber
    )
    process {
        $now = [System.DateTime]::UtcNow;
        $configuration = [PSCustomObject] @{
            Author = $env:USERNAME;
            GenerationHost = $env:COMPUTERNAME;
            GenerationDate = '{0} {1}' -f $now.ToShortDateString(), $now.ToString('hh:mm:ss');
            ModuleVersion = (Get-Module -Name $labDefaults.ModuleName).Version.ToString();
            HostDefaults = [PSCustomObject] (GetConfigurationData -Configuration Host);
            VMDefaults = [PSCustomObject] (GetConfigurationData -Configuration VM);
            CustomMedia = @([PSCustomObject] (GetConfigurationData -Configuration CustomMedia));
        }

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            # Resolve any relative paths
            $Path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LiteralPath);
        }

        if ($NoClobber -and (Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
            $errorMessage = $localized.FileAlreadyExistsError -f $Path;
            $ex = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage;
            $errorCategory = [System.Management.Automation.ErrorCategory]::ResourceExists;
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'FileExists', $errorCategory, $Path;
            $PSCmdlet.WriteError($errorRecord);
        }
        else {
            $verboseMessage = GetFormattedMessage -Message ($localized.ExportingConfiguration -f $labDefaults.ModuleName, $Path);
            $operationMessage = $localized.ShouldProcessOperation -f 'Export', $Path;
            $setContentParams = @{
                Path = $Path;
                Value = ConvertTo-Json -InputObject $configuration -Depth 5;
                Force = $true;
                Confirm = $false;
            }
            if ($PSCmdlet.ShouldProcess($verboseMessage, $operationMessage, $localized.ShouldProcessActionConfirmation)) {
                try {
                    ## Set-Content won't actually throw a terminating error?!
                    Set-Content @setContentParams -ErrorAction Stop;
                    Write-Output -InputObject (Get-Item -Path $Path);
                }
                catch {
                    throw $_;
                }
            }
        }

    } #end process

}

