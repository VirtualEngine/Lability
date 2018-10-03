#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-ConfigurationData' {

    InModuleScope $moduleName {

        It 'Removes configuration file' {
            $testConfigurationFilename = 'TestVMConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return ('%SYSTEMROOT%\{0}' -f $testConfigurationFilename); }
            Mock Test-Path -MockWith { return $true; }
            Mock Remove-Item -MockWith { }

            Remove-ConfigurationData -Configuration VM;

            Assert-MockCalled Remove-Item -ParameterFilter { $Path.EndsWith($testConfigurationFilename) } -Scope It;
        }

    } #end InModuleScope

} #end Describe
