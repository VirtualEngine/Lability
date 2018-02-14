function Assert-LabConfigurationMof {
<#
    .SYNOPSIS
        Checks for node MOF and meta MOF configuration files.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab vm/node name
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Path to .MOF files created from the DSC configuration
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path = (Get-LabHostDscConfigurationPath),

        ## Ignores missing MOF file
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $SkipMofCheck
    )
    process {

        $Path = Resolve-Path -Path $Path -ErrorAction Stop;
        $node = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -eq $Name };

        $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $node.NodeName);
        Write-Verbose -Message ($localized.CheckingForNodeFile -f $mofPath);
        if (-not (Test-Path -Path $mofPath -PathType Leaf)) {

            if ($SkipMofCheck) {

                Write-Warning -Message ($localized.CannotLocateMofFileError -f $mofPath)
            }
            else {

                throw ($localized.CannotLocateMofFileError -f $mofPath);
            }
        }

        $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $node.NodeName);
        Write-Verbose -Message ($localized.CheckingForNodeFile -f $metaMofPath);
        if (-not (Test-Path -Path $metaMofPath -PathType Leaf)) {

            Write-Warning -Message ($localized.CannotLocateLCMFileWarning -f $metaMofPath);
        }

    } #end process
} #end function Assert-LabConfigurationMof
