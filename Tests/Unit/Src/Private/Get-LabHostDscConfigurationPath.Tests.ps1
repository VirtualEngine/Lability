#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-LabHostDefault' {

    InModuleScope $moduleName {

        It 'Returns host configuration path' {
            $testConfigurationPath = 'TestDrive:\';
            Mock Get-ConfigurationData -MockWith { return [PSCustomObject] @{ ConfigurationPath = $testConfigurationPath; } }

            Get-LabHostDscConfigurationPath | Should Be $testConfigurationPath;
        }

    } #end InModuleScope

} #end Describe
