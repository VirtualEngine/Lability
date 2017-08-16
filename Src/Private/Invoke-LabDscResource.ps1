function Invoke-LabDscResource {
<#
    .SYNOPSIS
        Runs the ResourceName DSC resource ensuring it's in the desired state.
    .DESCRIPTION
        The Invoke-LabDscResource cmdlet invokes the target $ResourceName\Test-TargetResource function using the supplied
        $Parameters hastable. If the resource is not in the desired state, the $ResourceName\Set-TargetResource
        function is called with the $Parameters hashtable to attempt to correct the resource.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $ResourceName,

        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Parameters
    )
    process {

        ## Attempt to expand any paths where parameter name contains 'Path'. Requires
        ## creating another hashtable to avoid modifying the collection.
        $resolvedParameters = @{ }
        foreach ($key in $Parameters.Keys) {

            $resolvedParameters[$key] = $Parameters[$key];

            if ($key -match 'Path') {

                $resolvedParameters[$key] = Resolve-PathEx -Path $Parameters[$key];
                if ($Parameters[$key] -ne $resolvedParameters[$key]) {

                    Write-Debug -Message ("Expanding path '{0}' with value '{1}'." -f $key, $Parameters[$key]);
                    Write-Debug -Message ("Resolved path '{0}' to value '{1}'." -f $key, $resolvedParameters[$key]);
                }
            }
        }
        $PSBoundParameters['Parameters'] = $resolvedParameters;

        if (-not (Test-LabDscResource @PSBoundParameters)) {

            if ($ResourceName -match 'PendingReboot') {

                throw $localized.PendingRebootWarning;
            }
            return (Set-LabDscResource @PSBoundParameters);
        }
        else {

            $setTargetResourceCommand = 'Set-{0}TargetResource' -f $ResourceName;
            WriteVerbose ($localized.SkippingCommand -f $setTargetResourceCommand);
        }

    } #end process
} #end function
