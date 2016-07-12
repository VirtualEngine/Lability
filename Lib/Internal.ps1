function NewDirectory {
<#
    .SYNOPSIS
       Creates a filesystem directory.
    .DESCRIPTION
       The New-Directory cmdlet will create the target directory if it doesn't already exist. If the target path
       already exists, the cmdlet does nothing.
#>
    [CmdletBinding(DefaultParameterSetName = 'ByString', SupportsShouldProcess)]
    [OutputType([System.IO.DirectoryInfo])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        # Target filesystem directory to create
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByDirectoryInfo')]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo[]] $InputObject,

        # Target filesystem directory to create
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByString')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath')]
        [System.String[]] $Path
    )
    process {

        Write-Debug -Message ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
        switch ($PSCmdlet.ParameterSetName) {

            'ByString' {

                foreach ($directory in $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)) {
                    Write-Debug -Message ("Testing target directory '{0}'." -f $directory);
                    if (!(Test-Path -Path $directory -PathType Container)) {
                        if ($PSCmdlet.ShouldProcess($directory, "Create directory")) {
                            WriteVerbose ($localized.CreatingDirectory -f $directory);
                            New-Item -Path $directory -ItemType Directory;
                        }
                    } else {
                        Write-Debug -Message ($localized.DirectoryExists -f $directory);
                        Get-Item -Path $directory;
                    }
                } #end foreach directory

            } #end byString

            'ByDirectoryInfo' {

                 foreach ($directoryInfo in $InputObject) {
                    Write-Debug -Message ("Testing target directory '{0}'." -f $directoryInfo.FullName);
                    if (!($directoryInfo.Exists)) {
                        if ($PSCmdlet.ShouldProcess($directoryInfo.FullName, "Create directory")) {
                            WriteVerbose ($localized.CreatingDirectory -f $directoryInfo.FullName);
                            New-Item -Path $directoryInfo.FullName -ItemType Directory;
                        }
                    } else {
                        Write-Debug -Message ($localized.DirectoryExists -f $directoryInfo.FullName);
                        $directoryInfo;
                    }
                } #end foreach directoryInfo

            } #end byDirectoryInfo

        } #end switch

    } #end process
} #end function NewDirectory


function ResolvePathEx {
<#
    .SYNOPSIS
        Resolves the wildcard characters in a path, and displays the path contents, ignoring non-existent paths.
    .DESCRIPTION
        The Resolve-Path cmdlet interprets the wildcard characters in a path and displays the items and containers at
        the location specified by the path, such as the files and folders or registry keys and subkeys.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory)]
        [System.String] $Path
    )
    process {

        try {
            $expandedPath = [System.Environment]::ExpandEnvironmentVariables($Path);
            $resolvedPath = Resolve-Path -Path $expandedPath -ErrorAction Stop;
            $Path = $resolvedPath.ProviderPath;
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            $Path = [System.Environment]::ExpandEnvironmentVariables($_.TargetObject);
            $Error.Remove($Error[-1]);
        }
        return $Path;

    } #end process
} #end function ResolvePathEx


function InvokeExecutable {
<#
    .SYNOPSIS
        Runs an executable and redirects StdOut and StdErr.
#>
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        # Executable path
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        # Executable arguments
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Array] $Arguments,

        # Redirected StdOut and StdErr log name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $LogName = ('{0}.log' -f $Path)
    )
    process {

        $processArgs = @{
            FilePath = $Path;
            ArgumentList = $Arguments;
            Wait = $true;
            RedirectStandardOutput = '{0}\{1}-StdOut.log' -f $env:temp, $LogName;
            RedirectStandardError = '{0}\{1}-StdErr.log' -f $env:temp, $LogName;
            NoNewWindow = $true;
            PassThru = $true;
        }
        Write-Debug -Message ($localized.RedirectingOutput -f 'StdOut', $processArgs.RedirectStandardOutput);
        Write-Debug -Message ($localized.RedirectingOutput -f 'StdErr', $processArgs.RedirectStandardError);
        WriteVerbose ($localized.StartingProcess -f $Path, [System.String]::Join(' ', $Arguments));
        $process = Start-Process @processArgs;
        if ($process.ExitCode -ne 0) {
            WriteWarning ($localized.ProcessExitCode -f $Path, $process.ExitCode)
        }
        else {
            WriteVerbose ($localized.ProcessExitCode -f $Path, $process.ExitCode);
        }
        ##TODO: Should this actually return the exit code?!

    } #end process
} #end function InvokeExecutable

function GetFormattedMessage {
<#
    .SYNOPSIS
        Generates a formatted output message.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Message
    )
    process {

        if (($labDefaults.CallStackLogging) -and ($labDefaults.CallStackLogging -eq $true)) {
            $parentCallStack = (Get-PSCallStack)[1]; # store the parent Call Stack
            $functionName = $parentCallStack.FunctionName;
            $lineNumber = $parentCallStack.ScriptLineNumber;
            $scriptName = ($parentCallStack.Location -split ':')[0];
            $formattedMessage = '[{0}] [Script:{1}] [Function:{2}] [Line:{3}] {4}' -f (Get-Date).ToLongTimeString(), $scriptName, $functionName, $lineNumber, $Message;
        }
        else {
            $formattedMessage = '[{0}] {1}' -f (Get-Date).ToLongTimeString(), $Message;
        }
        return $formattedMessage;

    } #end process
} #end function GetFormattedMessage


function WriteVerbose {
<#
    .SYNOPSIS
        Wrapper around Write-Verbose that adds a timestamp and/or call stack information to the output.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)] [AllowNull()]
        [System.String] $Message
    )
    process {

        if (-not [System.String]::IsNullOrEmpty($Message)) {
            $verboseMessage = GetFormattedMessage -Message $Message;
            Write-Verbose -Message $verboseMessage;
        }

    }
} #end function WriteVerbose


function WriteWarning {
<#
    .SYNOPSIS
        Wrapper around Write-Warning that adds a timestamp and/or call stack information to the output.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)] [AllowNull()]
        [System.String] $Message
    )
    process {

        if (-not [System.String]::IsNullOrEmpty($Message)) {
            $warningMessage = GetFormattedMessage -Message $Message;
            Write-Warning -Message $warningMessage;
        }

    }
} #end function WriteWarning


function ConvertPSObjectToHashtable {
<#
    .SYNOPSIS
        Converts a PSCustomObject's properties to a hashtable.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Object to convert to a hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSObject[]] $InputObject,

        ## Do not add empty/null values to the generated hashtable
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $IgnoreNullValues
    )
    process {

        foreach ($object in $InputObject) {

            $hashtable = @{ }
            foreach ($property in $object.PSObject.Properties) {

                if ($IgnoreNullValues) {
                    if ([System.String]::IsNullOrEmpty($property.Value)) {
                        ## Ignore empty strings
                        continue;
                    }
                }

                if ($property.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject') {
                    ## Convert nested custom objects to hashtables
                    $hashtable[$property.Name] = ConvertPSObjectToHashtable -InputObject $property.Value -IgnoreNullValues:$IgnoreNullValues;
                }
                else {
                    $hashtable[$property.Name] = $property.Value;
                }

            } #end foreach property
            Write-Output $hashtable;

        }
    } #end proicess
} #end function ConvertPSObjectToHashtable


function CopyDirectory {
<#
    .SYNOPSIS
        Copies a directory structure with progress.
#>
    [CmdletBinding()]
    param (
        ## Source directory path
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNull()]
        [System.IO.DirectoryInfo] $SourcePath,

        ## Destination directory path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNull()]
        [System.IO.DirectoryInfo] $DestinationPath,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        if ((Get-Item $SourcePath) -isnot [System.IO.DirectoryInfo]) {
            throw ($localized.CannotProcessArguentError -f 'CopyDirectory', 'SourcePath', $SourcePath, 'System.IO.DirectoryInfo');
        }
        elseif (Test-Path -Path $SourcePath -PathType Leaf) {
            throw ($localized.InvalidDestinationPathError -f $DestinationPath);
        }

    }
    process {

        $activity = $localized.CopyingResource -f $SourcePath.FullName, $DestinationPath;
        $status = $localized.EnumeratingPath -f $SourcePath;
        Write-Progress -Activity $activity -Status $status -PercentComplete 0;
        $fileList = Get-ChildItem -Path $SourcePath -File -Recurse;
        $currentDestinationPath = $SourcePath;

        for ($i = 0; $i -lt $fileList.Count; $i++) {
            if ($currentDestinationPath -ne $fileList[$i].DirectoryName) {
                ## We have a change of directory
                $destinationDirectoryName = $fileList[$i].DirectoryName.Substring($SourcePath.FullName.Trim('\').Length);
                $destinationDirectoryPath = Join-Path -Path $DestinationPath -ChildPath $destinationDirectoryName;
                [ref] $null = New-Item -Path $destinationDirectoryPath -ItemType Directory -ErrorAction Ignore;
                $currentDestinationPath = $fileList[$i].DirectoryName;
            }
           if (($i % 5) -eq 0) {
                [System.Int16] $percentComplete = (($i + 1) / $fileList.Count) * 100;
                $status = $localized.CopyingResourceStatus -f $i, $fileList.Count, $percentComplete;
                Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete;
            }

            $targetPath = Join-Path -Path $DestinationPath -ChildPath $fileList[$i].FullName.Replace($SourcePath, '');
            Copy-Item -Path $fileList[$i].FullName -Destination $targetPath -Force:$Force;
        } #end for

        Write-Progress -Activity $activity -Completed;

    } #end process
} #end function CopyDirectory


function TestComputerName {
<#
    .SYNOPSIS
        Validates a computer name is valid.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Source directory path
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $ComputerName
    )
    process {

        $invalidMatch = '[~!@#\$%\^&\*\(\)=\+_\[\]{}\\\|;:.''",<>\/\?\s]';
        return ($ComputerName -inotmatch $invalidMatch);

    }
} #end function TestComputerName


function ValidateTimeZone {
<#
    .SYNOPSIS
        Validates a timezone string.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $TimeZone
    )
    process {
        try {
            $TZ = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
            return $TZ.StandardName;
        }
        catch [System.TimeZoneNotFoundException] {
            throw $_;
        }
    } #end process
} #end function ValidateTimeZone
