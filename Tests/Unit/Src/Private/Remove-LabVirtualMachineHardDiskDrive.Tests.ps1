#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabVirtualMachineHardDiskDrive' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock Import-LabDscResource -MockWith { }
        Mock Invoke-LabDscResource -MockWith { }

        It "Should not call 'Invoke-LabDscResource' when 'VhdPath' is specified" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @( @{ VhdPath = $testDrive; } )

            Remove-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled Invoke-LabDscResource -Scope It -Exactly 0;
        }

        It "Should call 'Invoke-LabDscResource' once for each additional disk" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @(
                @{ Generation = 'Vhd'; MaximumSizeBytes = 10GB; }
                @{ Generation = 'Vhd'; MaximumSizeBytes = 15GB; }
            )

            Remove-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled Invoke-LabDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -Scope It -Exactly $testHardDiskDrive.Count;
        }

        It "Should call 'Invoke-LabDscResource' with 'Ensure' = 'Absent'" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @(
                @{ Generation = 'Vhd'; MaximumSizeBytes = 10GB; }
            )

            Remove-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled Invoke-LabDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -Scope It;
        }

    } #end InModuleScope

} #end describe
