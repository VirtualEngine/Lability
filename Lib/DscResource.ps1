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

function GetDscResourcePSGalleryUri {
 <#
    .SYNOPSIS
        Returns the DSC resource direct download Uri
#>  
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## PowerShell DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $Name,
        
        ## The minimum version of the DSC module required
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,
        
        ## The exact version of the DSC module required
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Uri,
        
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments  
    )
    process {
        if ($PSBoundParameters.ContainsKey('Uri')) {
            return $Uri;
        }
        elseif ($PSBoundParameters.ContainsKey('RequiredVersion')) {
            ## Download the specific version
            return ('http://www.powershellgallery.com/api/v2/package/{0}/{1}' -f $Name, $RequiredVersion);
        }
        else {
            ## Download the latest version
            return ('http://www.powershellgallery.com/api/v2/package/{0}' -f $Name);
        }
    } #end process
} #end function GetDscResourcePSGalleryUri

function InvokeDscResourceDownload {
<#
    .SYNOPSIS
        Downloads a DSC resource if it has not already been downloaded or the checksum is incorrect.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable[]] $DSCResource,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,
        
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        
        foreach ($resourceDefinition in $DSCResource) {
            ## Ensure we at least have a -MinimumVersion key
            if ((-not $resourceDefinition.ContainsKey('MinimumVersion')) -and (-not $resourceDefinition.ContainsKey('RequiredVersion'))) {
                $resourceDefinition['MinimumVersion'] = '0.0';
            }
            if ((-not (TestModule @resourceDefinition) -or $Force)) {
                switch ($resourceDefinition.Provider) {
                    'GitHub' {
                        [ref] $null = InvokeDscResourceDownloadFromGitHub @resourceDefinition -Force:$Force;
                    }
                    default {
                        ## Use the PSGallery provider bu default.
                        [ref] $null = InvokeDscResourceDownloadFromPSGallery @resourceDefinition -Force:$Force;
                    }
                }
            } #end if module not present
            
            $module = GetModule -Name $resourceDefinition.Name;
            Write-Output (Get-Item -Path $module.Path).Directory;
        } #end foreach DSC resource
        
    } #end process
} #end function InvokeDscResourceDownload

function InvokeDscResourceDownloadFromPSGallery {
<#
    .SYNOPSIS
        Downloads a DSC resource if it has not already been downloaded from the Powershell Gallery.
#>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        
        ## PowerShell DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $Name,
        
        ## The minimum version of the DSC module required
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,
        
        ## The exact version of the DSC module required
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,
        
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        $windowsPowerShellModules = Join-Path -Path $env:ProgramFiles -ChildPath '\WindowsPowerShell\Modules';
        $tempModuleFilename = '{0}.zip' -f $Name;
        $tempDestinationPath = Join-Path -Path $env:Temp -ChildPath $tempModuleFilename;
        
        $psGalleryUri = GetDscResourcePSGalleryUri @PSBoundParameters;
        $tempFileInfo = SetResourceDownload -DestinationPath $tempDestinationPath -Uri $psGalleryUri;
                    
        ## Extract .Zip to PSModulePath
        $modulePath = Join-Path $windowsPowerShellModules -ChildPath $Name;
        [ref] $null = ExpandZipArchive -Path $tempFileInfo -DestinationPath $modulePath -ExcludeNuSpecFiles -Force:$Force;
        return (Get-Item -Path $modulePath);
    } #end process
} #end function 

function InvokeDscResourceDownloadFromGitHub {
    <#
    .SYNOPSIS
        Downloads a DSC resource if it has not already been downloaded from Github.
    .NOTES
        Uses the GitHubRepository module!
#>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        ## PowerShell DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Owner,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Repository = $Name,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Branch = 'master',
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $OverrideRepositoryName = $Name,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,
        
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    begin {
        ## Bootstrap the GithubRepository module
        if (-not (TestModule -Name GitHubRepository -MinimumVersion '0.9.3')) {
            [ref] $null = InvokeDscResourceDownloadFromPSGallery -Name 'GitHubRepository';
        }
    }
    process {
        Import-Module -Name 'GitHubRepository' -Verbose:$false;
        $installGitHubRepositoryParams = @{
            Owner = $Owner;
            Repository = $Repository;
            Branch = $Branch;
            OverrideRepository = $OverrideRepositoryName;
        }
        return (Install-GitHubRepository @installGitHubRepositoryParams -Verbose:$false -Force:$Force);
    } #end process
} #end function Invoke-DscResourceDownloadFromGitHub
