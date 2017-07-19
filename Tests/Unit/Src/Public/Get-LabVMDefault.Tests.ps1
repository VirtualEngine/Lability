#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Get-LabVMDefault' {

    InModuleScope -ModuleName $moduleName {

        It 'Returns a "System.Management.Automation.PSCustomObject" object type' {
            $defaults = Get-LabVMDefault;

            $defaults -is [System.Management.Automation.PSCustomObject] | Should Be $true;
        }

        It 'Does not return "BootOrder" property' {
            $defaults = Get-LabVMDefault;

            $defaults.BootOrder | Should BeNullOrEmpty;
        }

    } #end InModuleScope

} #end describe
