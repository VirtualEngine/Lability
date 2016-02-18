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
        The Test-LabHostConfiguration test the current configuration of the lab host.
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
                if (-not (Test-Path -Path $(ResolvePathEx -Path $property.Value) -PathType Container)) {
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
