function Get-LabVirtualMachineProperty {
<#
    .SYNOPSIS
        Gets the properties required by DSC xVMHyperV.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        [Parameter(Mandatory)]
        [System.UInt64] $StartupMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MinimumMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MaximumMemory,

        [Parameter(Mandatory)]
        [System.Int32] $ProcessorCount,

        [Parameter()]
        [AllowNull()]
        [System.String[]] $MACAddress,

        [Parameter()]
        [System.Boolean] $SecureBoot,

        [Parameter()]
        [System.Boolean] $GuestIntegrationServices,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        ## Resolve the media to determine whether we require a Generation 1 or 2 VM..
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

            $labMedia = ResolveLabMedia -Id $Media -ConfigurationData $ConfigurationData;
            $labImage = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData;
        }
        else {

            $labMedia = ResolveLabMedia -Id $Media;
            $labImage = Get-LabImage -Id $Media;
        }
        if (-not $labImage) {

            ## Should only trigger during a Reset-VM where parent image is not available?!
            ## It will be downloaded during any NewLabVM calls..
            $labImage = @{ Generation = 'VHDX'; }
        }
        $labMediaArchitecture = $labMedia.Architecture;

        if (-not [System.String]::IsNullOrEmpty($labMedia.CustomData.PartitionStyle)) {

            ## The partition style has been overridden so use this
            if ($labMedia.CustomData.PartitionStyle -eq 'MBR') {

                $labMediaArchitecture = 'x86';
            }
            elseif ($labMedia.CustomData.PartitionStyle -eq 'GPT') {

                $labMediaArchitecture = 'x64';
            }
        }

        if ($null -ne $labMedia.CustomData.VmGeneration) {

            ## Use the specified VM generation
            $PSBoundParameters.Add('Generation', $labMedia.CustomData.VmGeneration);
        }
        elseif ($labImage.Generation -eq 'VHD') {

            ## VHD files are only supported in G1 VMs
            $PSBoundParameters.Add('Generation', 1);
        }
        elseif ($labMediaArchitecture -eq 'x86') {

            ## Assume G1 for x86 media
            $PSBoundParameters.Add('Generation', 1);
        }
        elseif ($labMediaArchitecture -eq 'x64') {

            ## Assume G2 for x64 media
            $PSBoundParameters.Add('Generation', 2);
        }

        if ($null -eq $MACAddress) {

            [ref] $null = $PSBoundParameters.Remove('MACAddress');
        }

        if ($PSBoundParameters.ContainsKey('GuestIntegrationServices')) {

            [ref] $null = $PSBoundParameters.Add('EnableGuestService', $GuestIntegrationServices);
            [ref] $null = $PSBoundParameters.Remove('GuestIntegrationServices');
        }

        $vhdPath = ResolveLabVMDiskPath -Name $Name -Generation $labImage.Generation;

        [ref] $null = $PSBoundParameters.Remove('Media');
        [ref] $null = $PSBoundParameters.Remove('ConfigurationData');
        [ref] $null = $PSBoundParameters.Add('VhdPath', $vhdPath);
        [ref] $null = $PSBoundParameters.Add('RestartIfNeeded', $true);

        return $PSBoundParameters;

    } #end process
} #end function Get-LabVirtualMachineProperty
