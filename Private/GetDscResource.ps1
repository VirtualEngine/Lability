function GetDscResource {

<#
    .SYNOPSIS
        Gets the ResourceName DSC resource configuration.
    .DESCRIPTION
        The GetDscResource cmdlet invokes the target $ResourceName\Get-TargetResource function using the supplied
        $Parameters hashtable.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Name of the DSC resource to get
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $ResourceName,

        ## The DSC resource's Get-TargetResource parameter hashtable
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Parameters
    )
    process {

        $getTargetResourceCommand = 'Get-{0}TargetResource' -f $ResourceName;
        Write-Debug ($localized.InvokingCommand -f $getTargetResourceCommand);
        # Code to factor in the parameters which can be passed to the Get-<Prefix>TargetResource function.
        $CommandInfo = Get-Command -Name $getTargetResourceCommand;
        $RemoveParameters = $Parameters.Keys |
            Where-Object -FilterScript { $($CommandInfo.Parameters.Keys) -notcontains $PSItem };
        $RemoveParameters |
            ForEach-Object -Process { [ref] $null = $Parameters.Remove($PSItem) };

        try {
            $getDscResourceResult = & $getTargetResourceCommand @Parameters;
        }
        catch {
            WriteWarning -Message ($localized.DscResourceFailedError -f $getTargetResourceCommand, $_);
        }

        return $getDscResourceResult;

    } #end process

}

