#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileModule' {

    InModuleScope $moduleName {

        # Guard mocks
        Mock Set-LabVMDiskModule -MockWith { }

        $testNode = 'TestNode';
        $testConfigurationData = @{}
        $testDriveLetter = $env:SystemDrive.Trim(':');

        $testModules = @(
            @{ Name = 'PowerShellModule'; }
            @{ Name = 'DscResourceModule'; }
        )

        It 'Calls "Resolve-LabModule" to query DSC resource modules' {
            Mock Resolve-LabModule -MockWith { return $testModules; }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileModule @testParams;

            Assert-MockCalled Resolve-LabModule -ParameterFilter { $ModuleType -eq 'DscResource'; } -Scope It;
        }

        It 'Calls "Resolve-LabModule" to query PowerShell modules' {
            Mock Resolve-LabModule -MockWith { return $testModules; }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileModule @testParams;

            Assert-MockCalled Resolve-LabModule -ParameterFilter { $ModuleType -eq 'Module'; } -Scope It;
        }

        It 'Calls "Set-LabVMDiskModule" to expand modules' {
            Mock Resolve-LabModule -MockWith { return $testModules; }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileModule @testParams;

            Assert-MockCalled Set-LabVMDiskModule -Scope It -Exactly 2;
        }

    } #end InModuleScope

} #end describe
