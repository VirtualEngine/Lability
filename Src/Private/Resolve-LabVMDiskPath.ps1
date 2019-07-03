function Resolve-LabVMDiskPath {
<#
    .SYNOPSIS
        Resolves the specified VM name to it's target VHDX path.
#>
    param (
        ## VM/node name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter()]
        [ValidateSet('VHD','VHDX')]
        [System.String] $Generation = 'VHDX',

        ## Configuration environment name
        [Parameter()]
        [AllowNull()]
        [System.String] $EnvironmentName,

        ## Return the parent/folder path
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Parent
    )
    process {

        $hostDefaults = Get-ConfigurationData -Configuration Host;
        $differencingVhdPath = $hostDefaults.DifferencingVhdPath;

        if ((-not $hostDefaults.DisableVhdEnvironmentName) -and
            (-not [System.String]::IsNullOrEmpty($EnvironmentName))) {

            $differencingVhdPath = Join-Path -Path $differencingVhdPath -ChildPath $EnvironmentName;
        }

        if ($Parent) {

            $vhdPath = $differencingVhdPath;
        }
        else {

            $vhdName = '{0}.{1}' -f $Name, $Generation.ToLower();
            $vhdPath = Join-Path -Path $differencingVhdPath -ChildPath $vhdName;
        }

        return $vhdPath;

    } #end process
} #end function
