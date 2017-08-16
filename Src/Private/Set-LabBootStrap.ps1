function Set-LabBootStrap {
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
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DefaultShell
    )
    process {

        $newBootStrapParams = @{
            CoreCLR = $CoreCLR;
        }
        if (-not [System.String]::IsNullOrEmpty($DefaultShell)) {

            $newBootStrapParams['DefaultShell'] = $DefaultShell;
        }
        $bootStrap = New-LabBootStrap @newBootStrapParams;

        if ($CustomBootStrap) {

            $bootStrap = $bootStrap -replace '<#CustomBootStrapInjectionPoint#>', $CustomBootStrap;
        }

        [ref] $null = New-Directory -Path $Path -Confirm:$false;
        $bootStrapPath = Join-Path -Path $Path -ChildPath 'BootStrap.ps1';
        Set-Content -Path $bootStrapPath -Value $bootStrap -Encoding UTF8 -Force -Confirm:$false;

    } #end process
} #end function
