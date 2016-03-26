function GetLabHostSetupConfiguration {
<#
    .SYNOPSIS
        Returns an array of hashtables defining the desired host configuration.
    .DESCRIPTION
        The GetLabHostSetupConfiguration function returns an array of hashtables used to determine whether the
        host is in the desired configuration.
    .NOTES
        The configuration is passed to avoid repeated calls to Get-LabHostDefault and polluting verbose output.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ( )
    process {
        [System.Boolean] $isDesktop = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType -eq 1;
        ## Due to the differences in client/server deployment for Hyper-V, determine the correct method before creating the host configuration array.
        $labHostSetupConfiguration = @();

        if ($isDesktop) {
            Write-Debug -Message 'Implementing desktop configuration.';
            $labHostSetupConfiguration += @{
                UseDefault = $true;
                Description = 'Hyper-V role';
                ModuleName = 'PSDesiredStateConfiguration';
                ResourceName = 'MSFT_WindowsOptionalFeature';
                Prefix = 'WindowsOptionalFeature';
                Parameters = @{
                    Ensure = 'Enable';
                    Name = 'Microsoft-Hyper-V-All';
                }
            };
        }
        else {
            Write-Debug -Message 'Implementing server configuration.';
            $labHostSetupConfiguration += @{
                UseDefault = $true;
                Description = 'Hyper-V Role';
                ModuleName = 'PSDesiredStateConfiguration';
                ResourceName = 'MSFT_RoleResource';
                Prefix = 'WindowsFeature';
                Parameters = @{
                    Ensure = 'Present';
                    Name = 'Hyper-V';
                    IncludeAllSubFeature = $true;
                }
            };
            $labHostSetupConfiguration += @{
                UseDefault = $true;
                Description = 'Hyper-V Tools';
                ModuleName = 'PSDesiredStateConfiguration';
                ResourceName = 'MSFT_RoleResource';
                Prefix = 'WindowsFeature';
                Parameters = @{
                    Ensure = 'Present';
                    Name = 'RSAT-Hyper-V-Tools';
                    IncludeAllSubFeature = $true;
                }
            };
        } #end Server configuration

        $labHostSetupConfiguration += @{
            ## Check for a reboot before continuing
            UseDefault = $false;
            Description = 'Pending reboot';
            ModuleName = 'xPendingReboot';
            ResourceName = 'MSFT_xPendingReboot';
            Prefix = 'PendingReboot';
            Parameters = @{
                Name = 'TestingForHypervReboot';
                SkipCcmClientSDK = $true;
            }
        };

        return $labHostSetupConfiguration;
    } #end process
} #end function GetLabHostSetupConfiguration

function Get-LabHostConfiguration {
<#
    .SYNOPSIS
        Retrieves the current lab host's configuration default values.
    .LINK
        Test-LabHostConfiguration
        Start-LabHostConfiguration
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param ( )
    process {
        $labHostSetupConfiguation = GetLabHostSetupConfiguration;
        foreach ($configuration in $labHostSetupConfiguation) {
            $importDscResourceParams = @{
                ModuleName = $configuration.ModuleName;
                ResourceName = $configuration.ResourceName;
                Prefix = $configuration.Prefix;
                UseDefault  = $configuration.UseDefault;
            }
            ImportDscResource @importDscResourceParams;
            $resource = GetDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters;
            $resource['Resource'] = $configuration.ResourceName;
            Write-Output -InputObject ([PSCustomObject] $resource);
        }
    } #end process
} #end function Get-LabHostConfiguration

function Test-LabHostConfiguration {
<#
    .SYNOPSIS
        Tests the lab host's configuration.
    .DESCRIPTION
        The Test-LabHostConfiguration tests the current configuration of the lab host.
    .PARAMETER IgnorePendingReboot
        Specifies a pending reboot does not fail the test.
    .LINK
        Get-LabHostConfiguration
        Test-LabHostConfiguration
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter()] [System.Management.Automation.SwitchParameter] $IgnorePendingReboot
    )
    process {
        WriteVerbose $localized.StartedHostConfigurationTest;
        ## Test folders/directories
        $hostDefaults = GetConfigurationData -Configuration Host;
        foreach ($property in $hostDefaults.PSObject.Properties) {
            if (($property.Name.EndsWith('Path')) -and (-not [System.String]::IsNullOrEmpty($property.Value))) {
                WriteVerbose ($localized.TestingPathExists -f $property.Value);
                $resolvedPath = ResolvePathEx -Path $property.Value;
                if (-not (Test-Path -Path $resolvedPath -PathType Container)) {
                    WriteVerbose -Message ($localized.PathDoesNotExist -f $resolvedPath);
                    return $false;
                }
            }
        }

        $labHostSetupConfiguration = GetLabHostSetupConfiguration;
        foreach ($configuration in $labHostSetupConfiguration) {
            $importDscResourceParams = @{
                ModuleName = $configuration.ModuleName;
                ResourceName = $configuration.ResourceName;
                Prefix = $configuration.Prefix;
                UseDefault = $configuration.UseDefault;
            }
            ImportDscResource @importDscResourceParams;
            WriteVerbose ($localized.TestingNodeConfiguration -f $Configuration.Description);
            if (-not (TestDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters)) {
                if ($configuration.Prefix -eq 'PendingReboot') {
                    WriteWarning $localized.PendingRebootWarning;
                    if (-not $IgnorePendingReboot) {
                        return $false;
                    }
                }
                else {
                    return $false;
                }
            }
        } #end foreach labHostSetupConfiguration
        WriteVerbose $localized.FinishedHostConfigurationTest;
        return $true;
    } #end process
} #end function Test-LabHostConfiguration

function Start-LabHostConfiguration {
<#
    .SYNOPSIS
        Invokes the configuration of the lab host.
    .DESCRIPTION
        The Start-LabHostConfiguration cmdlet invokes the configuration of the local host computer.
    .LINK
        Test-LabHostConfiguration
        Get-LabHostConfiguration
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ( )
    process {
        WriteVerbose $localized.StartedHostConfiguration;
        ## Create required directory structure
        $hostDefaults = GetConfigurationData -Configuration Host;
        foreach ($property in $hostDefaults.PSObject.Properties) {
            if (($property.Name.EndsWith('Path')) -and (-not [System.String]::IsNullOrEmpty($property.Value))) {
                [ref] $null = NewDirectory -Path $(ResolvePathEx -Path $Property.Value) -ErrorAction Stop;
            }
        }

        # Once all the path are created, check if the hostdefaults.Json file in the $env:ALLUSERSPROFILE is doesn't have entries with %SYSTEMDRIVE% in it
        # Many subsequent call are failing to Get-LabImage, Test-LabHostConfiguration which do not resolve the "%SYSTEMDRIVE%" in the path for Host defaults
        foreach ($property in $($hostDefaults.PSObject.Properties | Where-Object -Property TypeNameOfValue -eq 'System.String')) {
            if ($property.Value.Contains('%')) {
                # if the Path for host defaults contains a '%' character then resolve it
                $resolvedPath = ResolvePathEx -Path $Property.Value;
                # update the hostdefaults Object
                $hostDefaults.($property.Name)  = $resolvedPath;
                $hostdefaultupdated = $true;
            }
        }
        if ($hostdefaultupdated) {
            # Write the changes back to the json file in the $env:ALLUSERSPROFILE
            $hostDefaults | ConvertTo-Json | Out-File -FilePath $(ResolveConfigurationDataPath -Configuration host)
        }

        $labHostSetupConfiguation = GetLabHostSetupConfiguration;
        foreach ($configuration in $labHostSetupConfiguation) {
            ImportDscResource -ModuleName $configuration.ModuleName -ResourceName $configuration.ResourceName -Prefix $configuration.Prefix -UseDefault:$configuration.UseDefault;
            WriteVerbose ($localized.TestingNodeConfiguration -f $Configuration.Description);
            [ref] $null = InvokeDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters;
            ## TODO: Need to check for pending reboots..
        }
        WriteVerbose $localized.FinishedHostConfiguration;
    } #end process
} #end function Start-LabHostConfiguration

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
} #end function Export-LabHostConfiguration

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
        [ValidateNotNullOrEmpty()] [Alias("PSPath")]
        [System.String] $Path,

        # Specifies a literal export location path.
        [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
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

        if ($Media) {
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

    } #end process

} #end function