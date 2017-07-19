#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Start-LabHostConfiguration' {

    InModuleScope -ModuleName $moduleName {

        # Guard mocks
        Mock ImportDscResource -MockWith { }
        Mock InvokeDscResource -MockWith { }
        Mock NewDirectory -MockWith { }

        It 'Does not attempt to create an empty path' {
            $fakeHostDefaults = '{ "APath": "" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { }

            Start-LabHostConfiguration;

            Assert-MockCalled NewDirectory -Exactly 0 -Scope It;
        }

        It 'Calls "NewDirectory" for each path' {
            $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { }

            Start-LabHostConfiguration;

            Assert-MockCalled NewDirectory -Exactly ($fakeHostDefaults.PSObject.Properties | Measure | Select -ExpandProperty Count) -Scope It;
        }

        It 'Calls "InvokeDscResource" for each host configuration item' {
            $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }

            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }

            Start-LabHostConfiguration;

            Assert-MockCalled InvokeDscResource -Exactly $fakeConfiguration.Count -Scope It;
        }

    } #end InModuleScope

} #end describe
