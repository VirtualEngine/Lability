function Test-LabConfiguration {
<#
    .SYNOPSIS
        Invokes a lab configuration from a DSC configuration document.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        WriteVerbose $localized.StartedLabConfigurationTest;
        $nodes = $ConfigurationData.AllNodes | Where { $_.NodeName -ne '*' };
        foreach ($node in $nodes) {
            [PSCustomObject] @{
                Name = $node.NodeName;
                IsConfigured = Test-LabVM -Name $node.NodeName -ConfigurationData $ConfigurationData;
            }
        }
        WriteVerbose $localized.FinishedLabConfigurationTest;
    } #end process
} #end function Test-LabConfiguration

function TestLabConfigurationMof {
<#
    .SYNOPSIS
        Checks for node MOF and meta MOF configuration files.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData,
        ## Lab vm/node name
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Name,
        ## Path to .MOF files created from the DSC configuration
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Path = (GetLabHostDSCConfigurationPath),
        ## Ignores missing MOF file
        [Parameter()] [System.Management.Automation.SwitchParameter] $SkipMofCheck
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $Path = Resolve-Path -Path $Path -ErrorAction Stop;
        $node = $ConfigurationData.AllNodes | Where { $_.NodeName -eq $Name };
        
        $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $node.NodeName);
        WriteVerbose ($localized.CheckingForNodeFile -f $mofPath);
        if (-not (Test-Path -Path $mofPath -PathType Leaf)) {
            if ($SkipMofCheck) {
                WriteWarning ($localized.CannotLocateMofFileError -f $mofPath)
            }
            else {
                throw ($localized.CannotLocateMofFileError -f $mofPath);
            }
        }

        $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $node.NodeName);
        WriteVerbose ($localized.CheckingForNodeFile -f $metaMofPath);
        if (-not (Test-Path -Path $metaMofPath -PathType Leaf)) {
            WriteWarning ($localized.CannotLocateLCMFileWarning -f $metaMofPath);
        }
    } #end process
} #end function TestLabConfigurationMof

function Start-LabConfiguration {
<#
    .SYNOPSIS
        Invokes a lab configuration from a DSC configuration document.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData,
        ## Path to .MOF files created from the DSC configuration
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Path = (GetLabHostDSCConfigurationPath),
        ## Skip creating baseline snapshots
        [Parameter()] [System.Management.Automation.SwitchParameter] $NoSnapshot,
        ## Forces a reconfiguration/redeployment of all nodes.
        [Parameter()] [System.Management.Automation.SwitchParameter] $Force,
        ## Ignores missing MOF file
        [Parameter()] [System.Management.Automation.SwitchParameter] $SkipMofCheck
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        if (-not (Test-LabHostConfiguration)) {
            throw $localized.HostConfigurationTestError;
        }
    }
    process {
        WriteVerbose $localized.StartedLabConfiguration;
        $nodes = $ConfigurationData.AllNodes | Where { $_.NodeName -ne '*' };

        $Path = Resolve-Path -Path $Path -ErrorAction Stop;
        foreach ($node in $nodes) {
            $testLabConfigurationMofParams = @{
                ConfigurationData = $ConfigurationData;
                Name = $node.NodeName;
                Path = $Path;
            }
            TestLabConfigurationMof @testLabConfigurationMofParams -SkipMofCheck:$SkipMofCheck;
        } #end foreach node

        foreach ($node in (Test-LabConfiguration -ConfigurationData $ConfigurationData)) {
            
            if ($node.IsConfigured -and $Force) {
                WriteVerbose ($localized.NodeForcedConfiguration -f $node.Name);
                NewLabVM -Name $node.Name -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot;
                if ($Start) { Start-VM -Name $node.Name; }
            }
            elseif ($node.IsConfigured) {
                WriteVerbose ($localized.NodeAlreadyConfigured -f $node.Name);
            }
            else {
                WriteVerbose ($localized.NodeMissingOrMisconfigured -f $node.Name);
                NewLabVM -Name $node.Name -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot;
            }
        }
        WriteVerbose $localized.FinishedLabConfiguration;
    } #end process
} #end function Restore-Lab

function Remove-LabConfiguration {
<#
    .SYNOPSIS
        Removes a lab configuration from a DSC configuration document.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData,
        ## Include removal of virtual switch(es). By default virtual switches are not removed.
        [Parameter()] [System.Management.Automation.SwitchParameter] $RemoveSwitch
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        WriteVerbose $localized.StartedLabConfiguration;
        $nodes = $ConfigurationData.AllNodes | Where { $_.NodeName -ne '*' };
        foreach ($node in $nodes) {
            RemoveLabVM -Name $node.NodeName -ConfigurationData $ConfigurationData -RemoveSwitch:$RemoveSwitch;
        }
        WriteVerbose $localized.FinishedLabConfiguration;
    } #end process
} #end function Restore-Lab
