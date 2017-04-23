#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabVMDiskPath' {

    InModuleScope $moduleName {

        It 'Appends the VM''s name to the host "DifferencingVhdPath"' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.vhdx";
        }

    } #end InModuleScope

} #end describe
