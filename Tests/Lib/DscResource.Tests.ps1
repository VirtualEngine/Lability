#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Lib\DscResource' {

    InModuleScope $moduleName {

        Context 'Validates "ImportDscResource" method' {

            It 'Does not import module if command is already imported' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                $testPrefixedCommandName = "Test-$($testResourceName)TargetResource";
                Mock Get-Command -ParameterFilter { $Name -eq $testPrefixedCommandName } -MockWith { return $true; }

                ImportDscResource -ModuleName $testModuleName -ResourceName $testResourceName;

                Assert-MockCalled Get-Command -ParameterFilter { $Name -eq $testPrefixedCommandName } -Scope It;
            }

            It 'Does not call "GetDscModule" if "UseDefault" is not specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                Mock Import-Module -MockWith { };
                Mock Get-Command -MockWith { };
                Mock GetDscModule -MockWith { }

                ImportDscResource -ModuleName $testModuleName -ResourceName $testResourceName;

                Assert-MockCalled GetDscModule -Scope It -Exactly 0;
            }

            It 'Calls "GetDscModule" if "UseDefault" is specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                Mock Import-Module -MockWith { };
                Mock Get-Command -MockWith { };
                Mock GetDscModule -ParameterFilter { $ModuleName -eq $testModuleName -and $ResourceName -eq $testResourceName } -MockWith { return $env:TEMP; }

                ImportDscResource -ModuleName $testModuleName -ResourceName $testResourceName -UseDefault;

                Assert-MockCalled GetDscModule -ParameterFilter { $ModuleName -eq $testModuleName -and $ResourceName -eq $testResourceName } -Scope It;
            }

        } #end context Validates "ImportDscResource" method

        Context 'Validates "GetDscResource" method' {

            It 'Calls "Get-<ResourceName>TargetResource" method' {
                $testResourceName = 'TestLabResource';
                ## Cannot dynamically generate function names :|
                $getPrefixedCommandName = "Get-TestLabResourceTargetResource";
                function Get-TestLabResourceTargetResource { }
                Mock $getPrefixedCommandName -MockWith { }

                GetDscResource -ResourceName $testResourceName -Parameters @{};

                Assert-MockCalled $getPrefixedCommandName -Scope It;
            }

        } #end context Validates "GetDscResource" method

        Context 'Validates "TestDscResource" method' {

            ## Cannot dynamically generate function names :|
            $testPrefixedCommandName = 'Test-TestLabResourceTargetResource';
            function Test-TestLabResourceTargetResource { }

            It 'Calls "Test-<ResourceName>TargetResource" method' {
                $testResourceName = 'TestLabResource';
                Mock $testPrefixedCommandName -MockWith { }

                TestDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 };

                Assert-MockCalled $testPrefixedCommandName -Scope It;
            }

            It 'Return $false when "Test-<ResourceName>TargetResource" throws (#104)' {
                $testResourceName = 'TestLabResource';
                Mock $testPrefixedCommandName -MockWith { throw 'HideMe'; }

                $testResult = TestDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 } -WarningAction SilentlyContinue;

                $testResult | Should Be $false;
            }

        } #end context Validates "TestDscResource" method

        Context 'Validates "SetDscResource" method' {

            It 'Calls "Set-<ResourceName>TargetResource" method' {
                $testResourceName = 'TestLabResource';
                ## Cannot dynamically generate function names :|
                $setPrefixedCommandName = 'Set-TestLabResourceTargetResource';
                function Set-TestLabResourceTargetResource { }
                Mock $setPrefixedCommandName -MockWith { }

                SetDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 };

                Assert-MockCalled $setPrefixedCommandName -Scope It;
            }

        } #end context Validates "SetDscResource" method

        Context 'Validates "InvokeDscResource" method' {

            It 'Does not call "Set-<ResourceName>TargetResource" if "TestDscResource" passes' {
                $testResourceName = 'TestLabResource';

                Mock TestDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $true; }
                Mock SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { }

                InvokeDscResource -ResourceName $testResourceName -Parameters @{};

                Assert-MockCalled SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -Scope It -Exactly 0;
            }

            It 'Does call "Set-<ResourceName>TargetResource" if "TestDscResource" fails' {
                $testResourceName = 'TestLabResource';

                Mock TestDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $false; }
                Mock SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { }

                InvokeDscResource -ResourceName $testResourceName -Parameters @{};

                Assert-MockCalled SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -Scope It;
            }

            It 'Throws when "TestDscResource" fails and "ResourceName" matches "PendingReboot"' {
                $testResourceName = 'TestLabResourcePendingReboot';
                Mock TestDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $false; }

                { InvokeDscResource -ResourceName $testResourceName -Parameters @{} } | Should Throw;
            }

        } #end context Validates "InvokeDscResource" method

    } #end InModuleScope

} #end describe Lib\DscResource
