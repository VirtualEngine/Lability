function Clear-LabModuleCache {
 <#
    .SYNOPSIS
        Removes all cached modules from the Lability module cache.
    .DESCRIPTION
        The Clear-LabModuleCache removes all cached PowerShell module and DSC resource modules stored in Lability's
        internal cache.
    .PARAMETER Force
        Forces the cmdlet to remove items that cannot otherwise be changed, such as hidden or read-only files or
        read-only aliases or variables.
    .EXAMPLE
        Clear-LabModuleCache -Force

        Removes all previously downloaded/cached PowerShell modules and DSC resources.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        $moduleCachePath = (Get-ConfigurationData -Configuration 'Host').ModuleCachePath;
        $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Clear-LabModuleCache', $moduleCachePath;
        $verboseProcessMessage = Get-FormattedMessage -Message ($localized.RemovingDirectory -f $moduleCachePath);
        $shouldProcessWarning = $localized.ShouldProcessWarning;
        if (($Force) -or
            ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $shouldProcessWarning))) {

                Remove-Item -Path $moduleCachePath -Recurse -Force:$Force;
                $moduleCachePathParent = Split-Path -Path $moduleCachePath -Parent;
                $moduleCachePathName = Split-Path -Path $moduleCachePath -Leaf;

                $newItemParams = @{
                    Path = $moduleCachePathParent;
                    Name = $moduleCachePathName;
                    ItemType = 'Directory';
                    Force = $true;
                    Confirm = $false;
                }
                [ref] $null = New-Item @newItemParams;
            }

    } #end process
} #end function
