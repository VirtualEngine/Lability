#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Get-LabHostConfiguration' {

    InModuleScope -ModuleName $moduleName {

        # Guard mocks
        Mock Import-LabDscResource
        Mock Get-LabDscResource

        It 'Calls "Import-LabDscResource once for each host configuration item' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock Get-LabDscResource -MockWith { return $fakeConfiguration[0]; }

            Get-LabHostConfiguration;

            Assert-MockCalled Import-LabDscResource -Exactly $fakeConfiguration.Count -Scope It;
        }

        It 'Calls "Get-LabDscResource once for each host configuration item' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock Get-LabDscResource -MockWith { return $fakeConfiguration[0]; }

            Get-LabHostConfiguration;

            Assert-MockCalled Get-LabDscResource -Exactly $fakeConfiguration.Count -Scope It;
        }

    } #end InModuleScope

} #end describe
