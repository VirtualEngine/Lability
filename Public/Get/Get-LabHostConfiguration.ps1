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

}

