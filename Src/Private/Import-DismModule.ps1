function Import-DismModule {
<#
    .SYNOPSIS
        Imports the required DISM dll.
#>
    [CmdletBinding()]
    param ( )
    process {

        $dismPath = (Get-LabHostDefault).DismPath;
        Remove-Module -Name 'Microsoft.Dism.PowerShell' -ErrorAction SilentlyContinue;
        $dismModule = Import-Module -Name $dismPath -Force -Scope Global -PassThru -Verbose:$false;
        WriteVerbose -Message ($localized.LoadedModuleVersion -f 'Dism', $dismModule.Version);

    } #end process
} #end function
