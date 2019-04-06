function Set-LabDscResource {
<#
    .SYNOPSIS
        Runs the ResourceName DSC resource ensuring it's in the desired state.
    .DESCRIPTION
        The Set-LabDscResource cmdlet invokes the target $ResourceName\Set-TargetResource function using the supplied
        $Parameters hastable.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Name of the DSC resource to invoke
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $ResourceName,

        ## The DSC resource's Set-TargetResource parameter hashtable
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Parameters
    )
    process {

        $setTargetResourceCommand = 'Set-{0}TargetResource' -f $ResourceName;
        Write-Debug ($localized.InvokingCommand -f $setTargetResourceCommand);
        $Parameters.Keys | ForEach-Object {

            Write-Debug -Message ($localized.CommandParameter -f $_, $Parameters.$_);
        }

        try {

            $setDscResourceResult = & $setTargetResourceCommand @Parameters;
        }
        catch {

            Write-Warning -Message ($localized.DscResourceFailedError -f $setTargetResourceCommand, $_);
        }

        return $setDscResourceResult;

    } #end process
} #end function
