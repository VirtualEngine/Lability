function Import-LabDscResource {
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

                Write-Verbose -Message ($localized.ImportingDscResource -f $ModuleName, $ResourceName);
                $resourcePath = Get-LabDscModule -ModuleName $ModuleName -ResourceName $ResourceName -ErrorAction Stop;
            }
            else {

                Write-Verbose -Message ($localized.ImportingBundledDscResource -f $ModuleName, $ResourceName);
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
} #end function
