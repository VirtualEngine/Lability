function TestDscResource {

<#
    .SYNOPSIS
        Tests the ResourceName DSC resource to determine if it's in the desired state.
    .DESCRIPTION
        The TestDscResource cmdlet invokes the target $ResourceName\Test-TargetResource function using the supplied
        $Parameters hastable.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Name of the DSC resource to test
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $ResourceName,

        ## The DSC resource's Test-TargetResource parameter hashtable
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Parameters
    )
    process {

        $testTargetResourceCommand = 'Test-{0}TargetResource' -f $ResourceName;
        Write-Debug ($localized.InvokingCommand -f $testTargetResourceCommand);
        $Parameters.Keys | ForEach-Object {
            Write-Debug -Message ($localized.CommandParameter -f $_, $Parameters.$_);
        }

        try {
            $testDscResourceResult = & $testTargetResourceCommand @Parameters;
        }
        catch {
            ## No point writing warnings as failures will occur, i.e. "VHD not found"
            ## when a VM does not yet exist.
            WriteWarning -Message ($localized.DscResourceFailedError -f $testTargetResourceCommand, $_);
            $testDscResourceResult = $false;
        }

        if (-not $testDscResourceResult) {
            WriteVerbose ($localized.TestFailed -f $testTargetResourceCommand);
        }

        return $testDscResourceResult;

    } #end process

}

