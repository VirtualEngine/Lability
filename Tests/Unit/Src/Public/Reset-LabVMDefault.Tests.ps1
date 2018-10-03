#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Reset-LabVMDefault' {

    InModuleScope -ModuleName $moduleName {

        It 'Calls "Remove-ConfigurationData" method' {
            Mock Remove-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { }

            $null = Reset-LabVMDefault;

            Assert-MockCalled Remove-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -Scope It;
        }

    } #end InModuleScope

} #end describe
