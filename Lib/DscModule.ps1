function ExpandDscModule {
<#
	.SYNOPSIS
		Extracts a DSC resource .zip archive using Windows Explorer and removes -master or -dev directory suffixes.
#>
    [CmdletBinding()]
	param (
		[Parameter(Mandatory)] [System.String] $ModuleName,
		[Parameter(Mandatory)] [System.String] $Path,
		[Parameter(Mandatory)] [System.String] $DestinationPath,
		[Parameter()] [System.Management.Automation.SwitchParameter] $Force
	)
	process {
		$targetPath = Join-Path -Path $DestinationPath -ChildPath $ModuleName;
        if (-not (Test-Path -Path $targetPath) -or $Force) {
            if (Test-Path -Path $targetPath) {
                WriteVerbose ($localized.RemovingDirectory -f $targetPath);
                Remove-Item -Path $targetPath -Recurse -Force -ErrorAction Stop;
            }
            WriteVerbose ($localized.ExpandingArchive -f $Path, $DestinationPath);
            $shellApplication = New-Object -ComObject Shell.Application;
            $archiveItems = $shellApplication.Namespace($Path).Items();
            $shellApplication.NameSpace($DestinationPath).CopyHere($archiveItems);
            ## Rename any -master branch folder where no GitHub release available
            Get-ChildItem -Path $DestinationPath -Directory | Where-Object { $_.Name -like '*-dev' -or $_.Name -like '*-master' } | ForEach-Object {
                $destinationFilename = $_.Name -replace '-dev','' -replace '-master','';
                WriteVerbose ($localized.RenamingPath -f $_.FullName, $destinationFilename);
                Rename-Item -Path $_.FullName -NewName $destinationFilename -ErrorAction Stop;
            }
        }
	} #end process
} #end function ExpandDscModule

function TestDscModule {
<#
    .SYNOPSIS
        Tests whether the ResourceName of the specified ModuleName can be located on the system.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)] [System.String] $ModuleName,
        [Parameter()] [System.String] $ResourceName,
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $MinimumVersion
    )
    process {
        if (GetDscModule @PSBoundParameters -ErrorAction SilentlyContinue) { return $true; }
        else { return $false; }
    }
} #end function TestDscModule

function GetDscModule {
<#
    .SYNOPSIS
        Locates the directory path of the ResourceName within the specified DSC ModuleName.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory)] [System.String] $ModuleName,
        [Parameter()] [System.String] $ResourceName,
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $MinimumVersion
    )
    process {
        $module = Get-Module -Name $ModuleName -ListAvailable;
        $dscModulePath = Split-Path -Path $module.Path -Parent;
        if ($ResourceName) {
            $ModuleName = '{0}\{1}' -f $ModuleName, $ResourceName;
            $dscModulePath = Join-Path -Path $dscModulePath -ChildPath "DSCResources\$ResourceName";
        }
        if (-not (Test-Path -Path $dscModulePath)) {
            Write-Error -Message ($localized.DscResourceNotFoundError -f $ModuleName);
            return $null;
        }
        if ($MinimumVersion) {
            if ($Module.Version -lt [System.Version]$MinimumVersion) {
                Write-Error -Message ($localized.ResourceVersionMismatchError -f $ModuleName, $module.Version.ToString(), $MinimumVersion);
                return $null;
            }
        }
        return $dscModulePath;
    } #end process
} #end function GetDscModule
