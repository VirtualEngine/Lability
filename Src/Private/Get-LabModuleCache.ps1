function Get-LabModuleCache {
<#
    .SYNOPSIS
        Returns the requested cached PowerShell module zip [System.IO.FileInfo] object.
    .NOTES
        File system modules are not stored in the module cache.
#>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,

        ## GitHub repository owner
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Owner,

        ## GitHub repository branch
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch,

        ## Source Filesystem module path
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Provider used to download the module
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateSet('PSGallery','GitHub', 'AzDo', 'FileSystem')]
        [System.String] $Provider,

        ## Lability PowerShell module info hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Module')]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Module,

        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)] $RemainingArguments
    )
    begin {

        if ([System.String]::IsNullOrEmpty($Provider)) {
            $Provider = 'PSGallery'
        }

        if ($PSCmdlet.ParameterSetName -eq 'Module') {

            $requiredParameters = 'Name';
            foreach ($parameterName in $requiredParameters) {

                if ([System.String]::IsNullOrEmpty($Module[$parameterName])) {

                    throw ($localized.RequiredModuleParameterError -f $parameterName);
                }
            } #end foreach required parameter

            $validParameters = 'Name','Provider','MinimumVersion','RequiredVersion','Owner','Branch','Path';
            foreach ($parameterName in $Module.Keys) {

                if ($parameterName -notin $validParameters) {

                    throw ($localized.InvalidtModuleParameterError -f $parameterName);
                }
                else {

                    Set-Variable -Name $parameterName -Value $Module[$parameterName];
                }
            } #end foreach parameter

        } #end if Module

        if ($Provider -eq 'GitHub') {

            if ([System.String]::IsNullOrEmpty($Owner)) {
                throw ($localized.RequiredModuleParameterError -f 'Owner');
            }

            ## Default to master branch if none specified
            if ([System.String]::IsNullOrEmpty($Branch)) {
                $Branch = 'master';
            }

            $Branch = $Branch.Replace('/','_') # Fix branch names with slashes (#361)

        } #end if GitHub
        elseif ($Provider -eq 'FileSystem') {

            if ([System.String]::IsNullOrEmpty($Path)) {
                throw ($localized.RequiredModuleParameterError -f 'Path');
            }
            elseif (-not (Test-Path -Path $Path)) {
                throw ($localized.InvalidPathError -f 'Module', $Path);
            }
            else {

                ## If we have a file, ensure it's a .Zip file
                $fileSystemInfo = Get-Item -Path $Path;
                if ($fileSystemInfo -is [System.IO.FileInfo]) {
                    if ($fileSystemInfo.Extension -ne '.zip') {
                        throw ($localized.InvalidModulePathExtensionError -f $Path);
                    }
                }
            }

        } #end if FileSystem

    }
    process {

        $moduleCachePath = (Get-ConfigurationData -Configuration Host).ModuleCachePath;

        ## If no provider specified, default to the PSGallery
        if (([System.String]::IsNullOrEmpty($Provider)) -or ($Provider -eq 'PSGallery')) {

            ## PowerShell Gallery modules are just suffixed with -v<Version>.zip
            $moduleRegex = '^{0}-v.+\.zip$' -f $Name;
        }
        elseif ($Provider -eq 'GitHub') {

            ## GitHub modules are suffixed with -v<Version>_<Owner>_<Branch>.zip
            $moduleRegex = '^{0}(-v.+)?_{1}_{2}\.zip$' -f $Name, $Owner, $Branch;
        }
        Write-Debug -Message ("Searching for files matching pattern '$moduleRegex'.");
        if ($Provider -in 'FileSystem') {

            ## We have a directory or a .zip file, so just return this
            return (Get-Item -Path $Path);
        }
        elseif ($Provider -in 'PSGallery', 'AzDo', 'GitHub') {
            $modules = Get-ChildItem -Path $moduleCachePath -ErrorAction SilentlyContinue |
                Where-Object Name -match $moduleRegex |
                    ForEach-Object {

                        Write-Debug -Message ("Discovered file '$($_.FullName)'.");
                        $trimStart = '{0}-v' -f $Name;
                        $moduleVersionString = $PSItem.Name.TrimStart($trimStart);
                        $moduleVersionString = $moduleVersionString -replace '(_\S+_\S+)?\.zip', '';

                        ## If we have no version number, default to the lowest version
                        if ([System.String]::IsNullOrEmpty($moduleVersionString)) {
                            $moduleVersionString = '0.0';
                        }

                        $discoveredModule = [PSCustomObject] @{
                            Name = $Name;
                            Version = $moduleVersionString -as [System.Version];
                            FileInfo = $PSItem;
                        }
                        Write-Output -InputObject $discoveredModule;
                    }
        }

        if ($null -ne $RequiredVersion) {
            Write-Debug -Message ("Checking for modules that match version '$RequiredVersion'.");
            Write-Output -InputObject (
                $modules | Where-Object { $_.Version -eq $RequiredVersion } |
                    Select-Object -ExpandProperty FileInfo);
        }
        elseif ($null -ne $MinimumVersion) {
            Write-Debug -Message ("Checking for modules with a minimum version of '$MinimumVersion'.");
            Write-Output -InputObject (
                $modules | Where-Object Version -ge $MinimumVersion |
                    Sort-Object -Property Version |
                        Select-Object -Last 1 -ExpandProperty FileInfo);
        }
        else {
            Write-Debug -Message ("Checking for the latest module version.");
            Write-Output -InputObject (
                $modules | Sort-Object -Property Version |
                    Select-Object -Last 1 -ExpandProperty FileInfo);
        }

    } #end process
} #end function Get-ModuleCache
