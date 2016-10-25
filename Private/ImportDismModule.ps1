function ImportDismModule {

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
        WriteVerbose -Message ("Loaded Dism module version '{0}'." -f $dismModule.Version);

    } #end process

}

