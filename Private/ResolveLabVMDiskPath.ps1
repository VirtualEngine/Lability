function ResolveLabVMDiskPath {

<#
    .SYNOPSIS
        Resolves the specified VM name to it's target VHDX path.
#>
    param (
        ## VM/node name.
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter()] [ValidateSet('VHD','VHDX')]
        [System.String] $Generation = 'VHDX'
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $vhdName = '{0}.{1}' -f $Name, $Generation.ToLower();
        $vhdPath = Join-Path -Path $hostDefaults.DifferencingVhdPath -ChildPath $vhdName;
        return $vhdPath;
    } #end process

}

