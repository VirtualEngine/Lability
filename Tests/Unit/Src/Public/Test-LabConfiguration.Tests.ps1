#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Test-LabConfiguration' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks

        It 'Calls "Test-LabVM" for each node' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                )
            }
            Mock Test-LabVM -MockWith { }

            Test-LabConfiguration -ConfigurationData $configurationData;

            Assert-MockCalled Test-LabVM -Exactly $configurationData.AllNodes.Count -Scope It;
        }

    } #end InModuleScope

} #end describe
