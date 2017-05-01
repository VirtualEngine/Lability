#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabVirtualMachineHardDiskDrive' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock ImportDscResource -MockWith { }
        Mock InvokeDscResource -MockWith { }

        It "Should not call 'InvokeDscResource' when 'VhdPath' is specified" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @( @{ VhdPath = $testDrive; } )

            Remove-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled InvokeDscResource -Scope It -Exactly 0;
        }

        It "Should call 'InvokeDscResource' once for each additional disk" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @(
                @{ Type = 'Vhd'; MaximumSizeBytes = 10GB; }
                @{ Type = 'Vhd'; MaximumSizeBytes = 15GB; }
            )

            Remove-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -Scope It -Exactly $testHardDiskDrive.Count;
        }

        It "Should call 'InvokeDscResource' with 'Ensure' = 'Absent'" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @(
                @{ Type = 'Vhd'; MaximumSizeBytes = 10GB; }
            )

            Remove-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -Scope It;
        }

    } #end InModuleScope

} #end describe
