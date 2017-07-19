#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Get-LabHostConfiguration' {

    InModuleScope -ModuleName $moduleName {

        # Guard mocks
        Mock ImportDscResource
        Mock GetDscResource

        It 'Calls "ImportDscResource once for each host configuration item' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock GetDscResource -MockWith { return $fakeConfiguration[0]; }

            Get-LabHostConfiguration;

            Assert-MockCalled ImportDscResource -Exactly $fakeConfiguration.Count -Scope It;
        }

        It 'Calls "GetDscResource once for each host configuration item' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock GetDscResource -MockWith { return $fakeConfiguration[0]; }

            Get-LabHostConfiguration;

            Assert-MockCalled GetDscResource -Exactly $fakeConfiguration.Count -Scope It;
        }

    } #end InModuleScope

} #end describe
