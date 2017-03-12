#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Remove-LabVM' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Restore-Lab -MockWith { }

        It 'Removes existing virtual machine' {
            $testVMName = 'TestVM';
            Mock Resolve-LabVMImage -MockWith { 'TestVMImageId'; }
            Mock RemoveLabVM -ParameterFilter { $Name -eq $testVMName } -MockWith { }

            Remove-LabVM -Name $testVMName -Confirm:$false;

            Assert-MockCalled RemoveLabVM -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

    } #end InModuleScope

} #end describe
