#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileBootstrap' {

    InModuleScope $moduleName {

        $testDriveLetter = $env:SystemDrive.Trim(':');

        It 'Calls "SetBootStrap" to inject default bootstrap' {
            Mock SetBootStrap -MockWith { }
            Mock SetSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileBootstrap @testParams;

            Assert-MockCalled SetBootStrap -ParameterFilter { $null -eq $CustomBootstrap } -Scope It;
        }

        It 'Calls "SetBootStrap" to inject custom bootstrap when specified' {
            Mock SetBootStrap -MockWith { }
            Mock SetSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
                CustomBootStrap = 'Test Bootstrap';
            }
            Set-LabVMDiskFileBootstrap @testParams;

            Assert-MockCalled SetBootStrap -ParameterFilter { $null -ne $CustomBootstrap } -Scope It;
        }

        It 'Calls "SetBootStrap" with "CoreCLR" to inject CoreCLR bootstrap when specified' {
            Mock SetBootStrap -MockWith { }
            Mock SetSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
                CoreCLR = $true;
            }
            Set-LabVMDiskFileBootstrap @testParams;

            Assert-MockCalled SetBootStrap -ParameterFilter { $CoreCLR -eq $true } -Scope It;
        }

        It 'Calls "SetSetupCompleteCmd" with "\Windows\Setup\Scripts" path' {
            Mock SetBootStrap -MockWith { }
            Mock SetSetupCompleteCmd -MockWith { }

            $testParams = @{
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileBootstrap @testParams;

            $expectedPath = '{0}:\Windows\Setup\Scripts' -f $testDriveLetter;
            Assert-MockCalled SetSetupCompleteCmd -ParameterFilter { $Path -eq $expectedPath } -Scope It;
        }

    } #end InModuleScope

} #end describe
