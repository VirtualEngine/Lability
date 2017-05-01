#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVirtualMachineHardDiskDrive' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock ImportDscResource -MockWith { }
        Mock InvokeDscResource -MockWith { }
        Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDrive; } }
        Mock Test-Path { $true; }

        It "Should call 'InvokeDscResource' to create VHD when 'VhdPath' is not specified" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @( @{ Type = 'Vhd'; MaximumSizeBytes = 10GB; } )

            Set-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'Vhd' } -Scope It;
        }

        It "Should call 'InvokeDscResource' once for each additional disk" {

            $testNodeName = 'TestVM';
            $testHardDiskDrive = @(
                @{ VhdPath = $testDrive; }
                @{ Type = 'Vhd'; MaximumSizeBytes = 10GB; }
            )

            Set-LabVirtualMachineHardDiskDrive -NodeName $testNodeName -HardDiskDrive $testHardDiskDrive;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'HardDiskDrive' } -Scope It -Exactly $testHardDiskDrive.Count;
        }

    } #end InModuleScope

} #end describe
