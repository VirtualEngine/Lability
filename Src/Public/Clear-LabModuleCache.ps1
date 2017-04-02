function Clear-LabModuleCache {
 <#
    .SYNOPSIS
        Empties all Lability cached modules.
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
        if ($Force -or ($PSCmdlet.ShouldProcess($moduleCachePath, "Empty directory"))) {

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
