#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Get-LabHostDefault' {

    InModuleScope $moduleName {

        It 'Calls "Get-ConfigurationData"' {
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { }

            Get-LabHostDefault;

            Assert-MockCalled Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' }
        }

    } #end InModuleScope

} #end Describe
