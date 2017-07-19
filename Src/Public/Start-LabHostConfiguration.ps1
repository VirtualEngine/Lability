function Start-LabHostConfiguration {
<#
    .SYNOPSIS
        Invokes the configuration of the lab host.
    .DESCRIPTION
        The Start-LabHostConfiguration cmdlet invokes the configuration of the local host computer.
    .PARAMETER IgnorePendingReboot
        Specifies a pending reboot does not fail the test.
    .LINK
        Test-LabHostConfiguration
        Get-LabHostConfiguration
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Ignores pending reboot check
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IgnorePendingReboot
    )
    process {

        WriteVerbose $localized.StartedHostConfiguration;
        ## Create required directory structure
        $hostDefaults = Get-ConfigurationData -Configuration Host;
        foreach ($property in $hostDefaults.PSObject.Properties) {

            if (($property.Name.EndsWith('Path')) -and (-not [System.String]::IsNullOrEmpty($property.Value))) {

                ## DismPath is not a folder and should be ignored (#159)
                if ($property.Name -ne 'DismPath') {

                    [ref] $null = NewDirectory -Path $(ResolvePathEx -Path $Property.Value) -ErrorAction Stop;
                }
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
                $hostDefaultsUpdated = $true;
            }
        }
        if ($hostDefaultsUpdated) {

            # Write the changes back to the json file in the $env:ALLUSERSPROFILE
            $hostDefaults | ConvertTo-Json | Out-File -FilePath $(Resolve-ConfigurationDataPath -Configuration Host);
        }

        $labHostSetupConfiguation = Get-LabHostSetupConfiguration;
        foreach ($configuration in $labHostSetupConfiguation) {

            ImportDscResource -ModuleName $configuration.ModuleName -ResourceName $configuration.ResourceName -Prefix $configuration.Prefix -UseDefault:$configuration.UseDefault;
            WriteVerbose ($localized.TestingNodeConfiguration -f $Configuration.Description);
            [ref] $null = InvokeDscResource -ResourceName $configuration.Prefix -Parameters $configuration.Parameters;
            ## TODO: Need to check for pending reboots..
        }
        WriteVerbose $localized.FinishedHostConfiguration;

    } #end process
} #end function
