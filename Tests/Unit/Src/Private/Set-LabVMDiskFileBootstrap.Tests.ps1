#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileBootstrap' {

    InModuleScope $moduleName {

        $testDriveLetter = $env:SystemDrive.Trim(':');

        It 'Calls "Set-LabBootStrap" to inject default bootstrap' {
            Mock Set-LabBootStrap -MockWith { }
            Mock Set-LabSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileBootstrap @testParams;

            Assert-MockCalled Set-LabBootStrap -ParameterFilter { $null -eq $CustomBootstrap } -Scope It;
        }

        It 'Calls "Set-LabBootStrap" to inject custom bootstrap when specified' {
            Mock Set-LabBootStrap -MockWith { }
            Mock Set-LabSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
                CustomBootStrap = 'Test Bootstrap';
            }
            Set-LabVMDiskFileBootstrap @testParams;

            Assert-MockCalled Set-LabBootStrap -ParameterFilter { $null -ne $CustomBootstrap } -Scope It;
        }

        It 'Calls "Set-LabBootStrap" with "CoreCLR" to inject CoreCLR bootstrap when specified' {
            Mock Set-LabBootStrap -MockWith { }
            Mock Set-LabSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
                CoreCLR = $true;
            }
            Set-LabVMDiskFileBootstrap @testParams;

            Assert-MockCalled Set-LabBootStrap -ParameterFilter { $CoreCLR -eq $true } -Scope It;
        }

        It 'Calls "Set-LabSetupCompleteCmd" with "\Windows\Setup\Scripts" path' {
            Mock Set-LabBootStrap -MockWith { }
            Mock Set-LabSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileBootstrap @testParams;

            $expectedPath = '{0}:\Windows\Setup\Scripts' -f $testDriveLetter;
            Assert-MockCalled Set-LabSetupCompleteCmd -ParameterFilter { $Path -eq $expectedPath } -Scope It;
        }

    } #end InModuleScope

} #end describe
