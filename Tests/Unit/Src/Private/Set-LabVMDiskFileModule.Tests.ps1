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
                Path = '.\';
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
                Path = '.\';
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
                Path = '.\';
            }
            Set-LabVMDiskFileModule @testParams;

            Assert-MockCalled Set-LabVMDiskModule -Scope It -Exactly 2;
        }

        Context 'No .mof modules' {

            It 'Does not call "Test-LabMofModule" when no external module dependencies are found (#316)' {
                Mock Test-LabMofModule -MockWith { }
                Mock Resolve-LabModule -MockWith { return $testModules; }
                Mock Test-Path { return $true; }
                Mock Get-LabMofModule -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                    Path = '.\';
                }
                Set-LabVMDiskFileModule @testParams;

                Assert-MockCalled Test-LabMofModule -Exactly 0 -Scope It;
            }

        }

    } #end InModuleScope

} #end describe
