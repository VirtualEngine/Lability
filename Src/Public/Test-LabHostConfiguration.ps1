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
        ## Skips pending reboot check
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IgnorePendingReboot
    )
    process {

        Write-Verbose -Message $localized.StartedHostConfigurationTest;
        ## Test folders/directories
        $hostDefaults = Get-ConfigurationData -Configuration Host;
        foreach ($property in $hostDefaults.PSObject.Properties) {

            if (($property.Name.EndsWith('Path')) -and (-not [System.String]::IsNullOrEmpty($property.Value))) {

                ## DismPath is not a folder and should be ignored (#159)
                if ($property.Name -ne 'DismPath') {

                    Write-Verbose -Message ($localized.TestingPathExists -f $property.Value);
                    $resolvedPath = Resolve-PathEx -Path $property.Value;
                    if (-not (Test-Path -Path $resolvedPath -PathType Container)) {

                        Write-Verbose -Message ($localized.PathDoesNotExist -f $resolvedPath);
                        return $false;
                    }
                }
            }
        }

        $labHostSetupConfiguration = Get-LabHostSetupConfiguration;
        foreach ($configuration in $labHostSetupConfiguration) {

            $importDscResourceParams = @{
                ModuleName = $configuration.ModuleName;
                ResourceName = $configuration.ResourceName;
                Prefix = $configuration.Prefix;
                UseDefault = $configuration.UseDefault;
            }
            Import-LabDscResource @importDscResourceParams;
            Write-Verbose -Message ($localized.TestingNodeConfiguration -f $Configuration.Description);

            if (-not (Test-LabDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters)) {

                if ($configuration.Prefix -eq 'PendingReboot') {

                    Write-Warning -Message $localized.PendingRebootWarning;
                    if (-not $IgnorePendingReboot) {

                        return $false;
                    }
                }
                else {

                    return $false;
                }
            }
        } #end foreach labHostSetupConfiguration

        Write-Verbose -Message $localized.FinishedHostConfigurationTest;
        return $true;

    } #end process
} #end function
