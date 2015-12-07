function ImportDscResource {
<#
    .NOTES
        Imports a DSC module resource as Test-<Prefix>TargetResource and Set-<Prefix>TargetResource etc.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [System.String] $ModuleName,
        [Parameter(Mandatory)] [System.String] $ResourceName,
        [Parameter()] [System.String] $Prefix = $ResourceName,
        ## Use the built-in/default resource
        [Parameter()] [System.Management.Automation.SwitchParameter] $UseDefault
    )
    process {
        ## Check whether the resource is already imported/registered
        WriteVerbose ($localized.CheckingDscResource -f $ModuleName, $ResourceName);
        $testCommandName = 'Test-{0}TargetResource' -f $Prefix;
        if (-not (Get-Command -Name $testCommandName -ErrorAction SilentlyContinue)) {
            if ($UseDefault) {
                WriteVerbose ($localized.ImportingDscResource -f $ModuleName, $ResourceName);
                $resourcePath = GetDscModule -ModuleName $ModuleName -ResourceName $ResourceName -ErrorAction Stop;
            }
            else {
                WriteVerbose ($localized.ImportingBundledDscResource -f $ModuleName, $ResourceName);
                $dscModuleRootPath = '{0}\{1}\{2}\DSCResources' -f $labDefaults.ModuleRoot, $labDefaults.DscResourceDirectory, $ModuleName;
                $dscResourcePath = '{0}\{0}.psm1' -f $ResourceName;
                $resourcePath = Join-Path -Path $dscModuleRootPath -ChildPath $dscResourcePath;
            }
            if ($resourcePath) {
                Import-Module -Name $resourcePath -Prefix $Prefix -Force -Verbose:$false;
            }
        }
        else {
            Write-Debug -Message ($localized.DscResourceAlreadyImported -f $ModuleName, $ResourceName);
        }
    } #end process
} #end function ImportDscResource

function GetDscResource {
<#
    .SYNOPSIS
        Gets the ResourceName DSC resource configuration.
    .DESCRIPTION
        The GetDscResource cmdlet invokes the target $ResourceName\Get-TargetResource function using the supplied
        $Parameters hastable.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [System.String] $ResourceName,
        [Parameter(Mandatory)] [System.Collections.Hashtable] $Parameters
    )
    process {
        $getTargetResourceCommand = 'Get-{0}TargetResource' -f $ResourceName;
        WriteVerbose ($localized.InvokingCommand -f $getTargetResourceCommand);
        $Parameters.Remove('Ensure');
        return (& $getTargetResourceCommand @Parameters);
    } #end process
} #end function GetDscResource

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
        [Parameter(Mandatory)] [System.String] $ResourceName,
        [Parameter(Mandatory)] [System.Collections.Hashtable] $Parameters
    )
    process {
        $testTargetResourceCommand = 'Test-{0}TargetResource' -f $ResourceName;
        WriteVerbose ($localized.InvokingCommand -f $testTargetResourceCommand);
        $Parameters.Keys | ForEach-Object {
            Write-Debug -Message ($localized.CommandParameter -f $_, $Parameters.$_);
        }
        $testDscResourceResult = & $testTargetResourceCommand @Parameters;
        if (-not $testDscResourceResult) {
            WriteVerbose ($localized.TestFailed -f $testTargetResourceCommand);
        }
        return $testDscResourceResult;
    } #end process
} #end function TestDscResource

function SetDscResource {
<#
    .SYNOPSIS
        Runs the ResourceName DSC resource ensuring it's in the desired state.
    .DESCRIPTION
        The SetDscResource cmdlet invokes the target $ResourceName\Set-TargetResource function using the supplied
        $Parameters hastable.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [System.String] $ResourceName,
        [Parameter(Mandatory)] [System.Collections.Hashtable] $Parameters
    )
    process {
        $setTargetResourceCommand = 'Set-{0}TargetResource' -f $ResourceName;
        WriteVerbose ($localized.InvokingCommand -f $setTargetResourceCommand);
        $Parameters.Keys | ForEach-Object {
            Write-Debug -Message ($localized.CommandParameter -f $_, $Parameters.$_);
        }
        return (& $setTargetResourceCommand @Parameters);
    } #end process
} #end function SetDscResource

function InvokeDscResource {
<#
    .SYNOPSIS
        Runs the ResourceName DSC resource ensuring it's in the desired state.
    .DESCRIPTION
        The InvokeDscResource cmdlet invokes the target $ResourceName\Test-TargetResource function using the supplied
        $Parameters hastable. If the resource is not in the desired state, the $ResourceName\Set-TargetResource
        function is called with the $Parameters hashtable to attempt to correct the resource.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [System.String] $ResourceName,
        [Parameter(Mandatory)] [System.Collections.Hashtable] $Parameters
    )
    process {
        if (-not (TestDscResource @PSBoundParameters)) {
            if ($ResourceName -match 'PendingReboot') {
                throw $localized.PendingRebootWarning;
            }
            return (SetDscResource @PSBoundParameters);
        }
        else {
            $setTargetResourceCommand = 'Set-{0}TargetResource' -f $ResourceName;
            WriteVerbose ($localized.SkippingCommand -f $setTargetResourceCommand);
        }
    } #end process
} #end function InvokeDscResource
