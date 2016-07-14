function ImportDscResource {
<#
    .SYNOPSIS
        Imports a DSC module resource.
    .DESCRIPTION
        Imports a DSC resource as Test-<Prefix>TargetResource and Set-<Prefix>TargetResource etc.
#>
    [CmdletBinding()]
    param (
        ##  DSC resource's module name containing the resource
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $ModuleName,

        ## DSC resource's name to import
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ResourceName,

        ## Local prefix, defaults to the resource name
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Prefix = $ResourceName,

        ## Use the built-in/default DSC resource
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $UseDefault
    )
    process {

        ## Check whether the resource is already imported/registered
        Write-Debug ($localized.CheckingDscResource -f $ModuleName, $ResourceName);
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
                ## Import the DSC module into the module's global scope to improve performance
                Import-Module -Name $resourcePath -Prefix $Prefix -Force -Verbose:$false -Scope Global;
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
            WriteWarning -Message ($localized.DscResourceFailedError -f $setTargetResourceCommand, $_);
        }

        return $setDscResourceResult;

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
        [Parameter(Mandatory)]
        [System.String] $ResourceName,

        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Parameters
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
