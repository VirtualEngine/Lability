function Import-LabHostConfiguration {
<#
    .SYNOPSIS
        Restores the lab host configuration from a backup.
    .LINK
        Export-LabHostConfiguration
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Path')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        # Specifies the export path location.
        [Parameter(Mandatory, ParameterSetName = 'Path', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [System.String] $Path,

        # Specifies a literal export location path.
        [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $LiteralPath,

        ## Restores only the lab host default settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Host,

        ## Restores only the lab VM default settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $VM,

        ## Restores only the lab custom media default settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Media
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {

            # Resolve any relative paths
            $Path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {

            $Path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LiteralPath);
        }

        if (-not (Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {

            $errorMessage = $localized.InvalidPathError -f 'Import', $Path;
            $ex = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage;
            $errorCategory = [System.Management.Automation.ErrorCategory]::ResourceUnavailable;
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'FileNotFound', $errorCategory, $Path;
            $PSCmdlet.WriteError($errorRecord);
            return;
        }

        WriteVerbose -Message ($localized.ImportingConfiguration -f $labDefaults.ModuleName, $Path);
        $configurationDocument = Get-Content -Path $Path -Raw -ErrorAction Stop;
        try {

            $configuration = ConvertFrom-Json -InputObject $configurationDocument -ErrorAction Stop;
        }
        catch {

            $errorMessage = $localized.InvalidConfigurationError -f $Path;
            throw $errorMessage;
        }

        if ((-not $PSBoundParameters.ContainsKey('Host')) -and
                (-not $PSBoundParameters.ContainsKey('VM')) -and
                    (-not $PSBoundParameters.ContainsKey('Media'))) {

            ## Nothing specified to load 'em all!
            $VM = $true;
            $Host = $true;
            $Media = $true;
        }

        WriteVerbose -Message ($localized.ImportingConfigurationSettings -f $configuration.GenerationDate, $configuration.GenerationHost);

        if ($Host) {

            $verboseMessage = GetFormattedMessage -Message ($localized.RestoringConfigurationSettings -f 'Host');
            $operationMessage = $localized.ShouldProcessOperation -f 'Import', 'Host';
            if ($PSCmdlet.ShouldProcess($verboseMessage, $operationMessage, $localized.ShouldProcessActionConfirmation)) {

                [ref] $null = Reset-LabHostDefault -Confirm:$false;
                $hostDefaultObject = $configuration.HostDefaults;
                $hostDefaults = ConvertPSObjectToHashtable -InputObject $hostDefaultObject;
                Set-LabHostDefault @hostDefaults -Confirm:$false;
                WriteVerbose -Message ($localized.ConfigurationRestoreComplete -f 'Host');
            }
        } #end if restore host defaults

        if ($Media) {

            ## Restore media before VM defaults as VM defaults may reference custom media!
            $verboseMessage = GetFormattedMessage -Message ($localized.RestoringConfigurationSettings -f 'Media');
            $operationMessage = $localized.ShouldProcessOperation -f 'Import', 'Media';
            if ($PSCmdlet.ShouldProcess($verboseMessage, $operationMessage, $localized.ShouldProcessActionConfirmation)) {

                [ref] $null = Reset-LabMedia -Confirm:$false;
                foreach ($mediaObject in $configuration.CustomMedia) {

                    $customMedia = ConvertPSObjectToHashtable -InputObject $mediaObject -IgnoreNullValues;
                    Write-Output (Register-LabMedia @customMedia -Force);
                }
                WriteVerbose -Message ($localized.ConfigurationRestoreComplete -f 'Media');
            }
        } #end if restore custom media

        if ($VM) {

            $verboseMessage = GetFormattedMessage -Message ($localized.RestoringConfigurationSettings -f 'VM');
            $operationMessage = $localized.ShouldProcessOperation -f 'Import', 'VM';
            if ($PSCmdlet.ShouldProcess($verboseMessage, $operationMessage, $localized.ShouldProcessActionConfirmation)) {

                [ref] $null = Reset-LabVMDefault -Confirm:$false;
                $vmDefaultObject = $configuration.VMDefaults;
                $vmDefaults = ConvertPSObjectToHashtable -InputObject $vmDefaultObject;
                ## Boot order is exposed externally
                $vmDefaults.Remove('BootOrder');
                Set-LabVMDefault @vmDefaults -Confirm:$false;
                WriteVerbose -Message ($localized.ConfigurationRestoreComplete -f 'VM');
            }
        } #end if restore VM defaults

    } #end process
} #end function
