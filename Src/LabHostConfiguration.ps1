function GetLabHostSetupConfiguration {
<#
    .SYNOPSIS
        Returns an array of hashtables defining the desired host configuration.
    .DESCRIPTION
        The GetLabHostSetupConfiguration function returns an array of hashtables used to determine whether the
        host is in the desired configuration.
    .NOTES
        The configuration is passed to avoid repeated calls to Get-LabHostDefaults and polluting verbose output.
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param (
        [Parameter(Mandatory)] [System.Object] $Configuration
    )
    process {
        [System.Boolean] $isDesktop = (Get-WmiObject -Class Win32_OperatingSystem).ProductType -eq 1;
        ## Due to the differences in client/server deployment for Hyper-V, determine the correct method before creating the host configuration array.
        if ($isDesktop) {
            Write-Debug 'Implementing desktop configuration.';
            $hypervConfiguration = @{
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
            Write-Debug 'Implementing server configuration.';
            $hypervConfiguration = @{
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
        }
        
        $labHostSetupConfiguration = @(
            @{  ## Create DSC resource share
                UseDefault = $false;
                Description = 'Local resource share';
                ModuleName = 'xSmbShare';
                ResourceName = 'MSFT_xSmbShare';
                Prefix = 'SmbShare'
                Parameters = @{
                    Ensure = 'Present';
                    Name = $configuration.ResourceShareName;
                    Path = $configuration.ResourcePath;
                    Description = 'Test Lab Resource Share';
                    FullAccess = 'BUILTIN\Administrators';
                    ReadAccess = 'Everyone';
                };
            },
            @{  ## Enable Guest account for DSC resource share
                UseDefault = $true;
                Description = 'Guest account enabled';
                ModuleName = 'PSDesiredStateConfiguration';
                ResourceName = 'MSFT_UserResource';
                Prefix = 'UserResource';
                Parameters = @{
                    UserName = 'Guest';
                    Ensure = 'Present';
                    Disabled = $false;
                };
            },
            ## Add Hyper-V role dependong on desktop or server setup
            $hypervConfiguration,
            @{  ## Check for a reboot before continuing
                UseDefault = $false;
                Description = 'Pending reboot';
                ModuleName = 'xPendingReboot';
                ResourceName = 'MSFT_xPendingReboot';
                Prefix = 'PendingReboot';
                Parameters = @{
                    Name = 'TestingForHypervReboot';
                };
            }
        );
        
        return $labHostSetupConfiguration;
    } #end process
} #end function GetLabHostSetupConfiguration

function Get-LabHostConfiguration {
<#
    .SYNOPSIS
        Retrieves the current Hyper-V host configuration.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ( )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $labHostSetupConfiguation = GetLabHostSetupConfiguration -Configuration $hostDefaults;
        foreach ($configuration in $labHostSetupConfiguation) {
            ImportDscResource -ModuleName $configuration.ModuleName -ResourceName $configuration.ResourceName -Prefix $configuration.Prefix;
            GetDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters;
        }
    } #end process
} #end function Get-LabHostSetup

function Test-LabHostConfiguration {
<#
    .SYNOPSIS
        Tests whether the Hyper-V host is configured correctly.
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
        $hostDefaultsPaths = $hostDefaults.PSObject.Properties | Where-Object { $_.Name -like '*Path' } | ForEach-Object { $_.Value }
        foreach ($property in $hostDefaults.PSObject.Properties) {
            if (($property.Name.EndsWith('Path')) -and (-not [System.String]::IsNullOrEmpty($property.Value))) {
                WriteVerbose ($localized.TestingPathExists -f $property.Value);
                if (-not (Test-Path -Path $property.Value -PathType Container)) {
                    return $false;
                }
            }
        }
        
        $labHostSetupConfiguration = GetLabHostSetupConfiguration -Configuration $hostDefaults;
        foreach ($configuration in $labHostSetupConfiguration) {
            ImportDscResource -ModuleName $configuration.ModuleName -ResourceName $configuration.ResourceName -Prefix $configuration.Prefix -UseDefault:$configuration.UseDefault;
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
} #end function Test-LabHostSetup

function Start-LabHostConfiguration {
<#
    .SYNOPSIS
        Invokes the configuration of the Hyper-V lab host.
    .NOTES
        Should this support passing of a specific configuration file to support updated ISO configs?
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
		[Parameter()] [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        WriteVerbose $localized.StartedHostConfiguration;
		## Create required directory structure
		$hostDefaults = GetConfigurationData -Configuration Host;
        $hostDefaultsPaths = $hostDefaults.PSObject.Properties | Where-Object { $_.Name -like '*Path' } | ForEach-Object { $_.Value }
        foreach ($property in $hostDefaults.PSObject.Properties) {
            if (($property.Name.EndsWith('Path')) -and (-not [System.String]::IsNullOrEmpty($property.Value))) {
                [ref] $null = NewDirectory -Path $property.Value -ErrorAction Stop;
            }
        }
        
        $hostDefaults = GetConfigurationData -Configuration Host;
        $labHostSetupConfiguation = GetLabHostSetupConfiguration -Configuration $hostDefaults;
        foreach ($configuration in $labHostSetupConfiguation) {
            ImportDscResource -ModuleName $configuration.ModuleName -ResourceName $configuration.ResourceName -Prefix $configuration.Prefix -UseDefault:$configuration.UseDefault;
            WriteVerbose ($localized.TestingNodeConfiguration -f $Configuration.Description);
            [ref] $null = InvokeDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters;
            ## TODO: Need to check for pending reboots..
        }
        WriteVerbose $localized.FinishedHostConfiguration;
    } #end process
} #end function Test-LabHostSetup
