function Clear-ModulePath {
<#
    .SYNOPSIS
        Removes all PowerShell modules installed in a given scope.
    .DESCRIPTION
        The Clear-ModulePath removes all existing PowerShell module and DSC resources from either the current user's
        or the local machine's module path.
    .PARAMETER Scope
        Specifies the scope to install module(s) in to. The default value is 'CurrentUser'.
    .PARAMETER Force
        Forces the cmdlet to remove items that cannot otherwise be changed, such as hidden or read-only files or
        read-only aliases or variables.
    .EXAMPLE
        Clear-ModulePath -Scope CurrentUser

        Removes all PowerShell modules and DSC resources from the current user's module path.
    .EXAMPLE
        Clear-ModulePath -Scope AllUsers -Force

        Removes all PowerShell modules and DSC resources from the local machine's module path.
    .NOTES
        USE WITH CAUTION! Not sure thsi should even be in this module?
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('AllUsers','CurrentUser')]
        [System.String] $Scope = 'CurrentUser',

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        if ($Scope -eq 'AllUsers') {

            $localizedProgramFiles = Resolve-ProgramFilesFolder -Path $env:SystemRoot;
            $modulePath = Join-Path -Path $localizedProgramFiles -ChildPath 'WindowsPowerShell\Modules';
        }
        elseif ($Scope -eq 'CurrentUser') {

            $userDocuments = [System.Environment]::GetFolderPath('MyDocuments');
            $modulePath = Join-Path -Path $userDocuments -ChildPath 'WindowsPowerShell\Modules';
        }

        if (Test-Path -Path $modulePath) {

            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Clear-ModulePath', $moduleCachePath;
            $verboseProcessMessage = Get-FormattedMessage -Message ($localized.RemovingDirectory -f $moduleCachePath);
            $shouldProcessWarning = $localized.ShouldProcessWarning;
            if (($Force) -or
                ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $shouldProcessWarning))) {

                ## The -Force on Remove-Item supresses the confirmation :()
                Remove-Item -Path $modulePath -Recurse -Force:$Force;
            }
        }
        else {

            Write-Verbose -Message ($localized.PathDoesNotExist -f $modulePath);
        }

    } #end process
} #end function
