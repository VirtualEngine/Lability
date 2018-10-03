#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Test-LabImage' {

    InModuleScope -ModuleName $moduleName {

        It 'Passes when parent image is found' {
            $testImageId = '42';
            Mock Get-LabImage -ParameterFilter { $Id -eq $testImageId } -MockWith { return $true; }

            Test-LabImage -Id $testImageId | Should Be $true;
        }

        It 'Fails when parent image is not found' {
            $testImageId = '42';
            Mock Get-LabImage -ParameterFilter { $Id -eq $testImageId } -MockWith { return $false; }

            Test-LabImage -Id $testImageId | Should Be $false;
        }

        It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
            $testImageId = '42';
            Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

            Test-LabImage -Id $testImageId -ConfigurationData @{};

            Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope

} #end describe
