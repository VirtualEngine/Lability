#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Remove-LabVM' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Restore-Lab -MockWith { }
        Mock Remove-LabVirtualMachine -MockWith { }

        It 'Removes existing virtual machine' {
            $testVMName = 'TestVM';
            Mock Resolve-LabVMImage -MockWith { 'TestVMImageId'; }

            Remove-LabVM -Name $testVMName -Confirm:$false;

            Assert-MockCalled Remove-LabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

    } #end InModuleScope

} #end describe
