#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Reset-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Restore-Lab -MockWith { }

        It 'Calls "Restore-Lab" with -Force switch' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                )
            }

            Reset-Lab -ConfigurationData $configurationData;

            Assert-MockCalled Restore-Lab -ParameterFilter { $Force -eq $true } -Scope It;
        }

    } #end InModuleScope

} #end describe
