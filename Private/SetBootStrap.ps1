function SetBootStrap {

<#
    .SYNOPSIS
        Writes the lab BootStrap.ps1 file to the target directory.
#>
    [CmdletBinding()]
    param (
        ## Destination Bootstrap directory path.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootStrap,

        ## Is a CoreCLR VM. The PowerShell switches are different in the CoreCLR, i.e. Nano Server
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR
    )
    process {

        [ref] $null = NewDirectory -Path $Path;
        $bootStrapPath = Join-Path -Path $Path -ChildPath 'BootStrap.ps1';
        $bootStrap = (NewBootStrap -CoreCLR:$CoreCLR).ToString();
        if ($CustomBootStrap) {

            $bootStrap = $bootStrap -replace '<#CustomBootStrapInjectionPoint#>', $CustomBootStrap;
        }
        Set-Content -Path $bootStrapPath -Value $bootStrap -Encoding UTF8 -Force;

    } #end process

}

