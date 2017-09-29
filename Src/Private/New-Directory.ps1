function New-Directory {
<#
    .SYNOPSIS
       Creates a filesystem directory.
    .DESCRIPTION
       The New-Directory cmdlet will create the target directory if it doesn't already exist. If the target path
       already exists, the cmdlet does nothing.
#>
    [CmdletBinding(DefaultParameterSetName = 'ByString', SupportsShouldProcess)]
    [OutputType([System.IO.DirectoryInfo])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        # Target filesystem directory to create
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByDirectoryInfo')]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo[]] $InputObject,

        # Target filesystem directory to create
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByString')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [System.String[]] $Path
    )
    process {

        Write-Debug -Message ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
        switch ($PSCmdlet.ParameterSetName) {

            'ByString' {

                foreach ($directory in $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)) {

                    Write-Debug -Message ("Testing target directory '{0}'." -f $directory);
                    if (-not (Test-Path -Path $directory -PathType Container)) {

                        if ($PSCmdlet.ShouldProcess($directory, "Create directory")) {

                            Write-Verbose -Message ($localized.CreatingDirectory -f $directory);
                            New-Item -Path $directory -ItemType Directory;
                        }
                    }
                    else {

                        Write-Debug -Message ($localized.DirectoryExists -f $directory);
                        Get-Item -Path $directory;
                    }
                } #end foreach directory
            } #end byString

            'ByDirectoryInfo' {

                 foreach ($directoryInfo in $InputObject) {

                    Write-Debug -Message ("Testing target directory '{0}'." -f $directoryInfo.FullName);
                    if (-not ($directoryInfo.Exists)) {

                        if ($PSCmdlet.ShouldProcess($directoryInfo.FullName, "Create directory")) {

                            Write-Verbose -Message ($localized.CreatingDirectory -f $directoryInfo.FullName);
                            New-Item -Path $directoryInfo.FullName -ItemType Directory;
                        }
                    }
                    else {

                        Write-Debug -Message ($localized.DirectoryExists -f $directoryInfo.FullName);
                        Write-Output -InputObject $directoryInfo;
                    }
                } #end foreach directoryInfo
            } #end byDirectoryInfo

        } #end switch

    } #end process
} #end function
