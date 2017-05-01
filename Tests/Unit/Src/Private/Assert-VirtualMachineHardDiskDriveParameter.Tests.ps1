#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Assert-VirtualMachineHardDiskDriveParameter' {

    InModuleScope -ModuleName $moduleName {

        It 'Should throw if mandatory parameters are missing' {

            { Assert-VirtualMachineHardDiskDriveParameter } | Should Throw 'missing mandatory';
        }

        It 'Should throw if VHD type and VHD path are specified' {

            { Assert-VirtualMachineHardDiskDriveParameter -Type 'Vhd' -VhdPath $testDrive } | Should Throw 'Cannot resolve';
        }

        It 'Should throw if VHD size and VHD path are specified' {

            { Assert-VirtualMachineHardDiskDriveParameter -MaximumSizeBytes 127GB -VhdPath $testDrive } | Should Throw 'Cannot resolve';
        }

        It 'Should throw if VHD size is less than 3MB' {

            { Assert-VirtualMachineHardDiskDriveParameter -Type 'Vhd' -MaximumSizeBytes 2MB } | Should Throw 'size';
        }

        It 'Should throw if VHD size is greater than 2040GB' {

            { Assert-VirtualMachineHardDiskDriveParameter -Type 'Vhd' -MaximumSizeBytes 2041GB } | Should Throw 'size';
        }

        It 'Should throw if VHD path is a directory path' {

            { Assert-VirtualMachineHardDiskDriveParameter -VhdPath $testDrive } | Should Throw 'Cannot locate';
        }

        It 'Should throw if VHD type is VHD and virtual machine is generation 2' {

            { Assert-VirtualMachineHardDiskDriveParameter -Type 'Vhd' -MaximumSizeBytes 127GB -VMGeneration 2 } | Should Throw 'not supported';
        }

        It 'Should not throw if VHD type is VHDX and virtual machine is generation 2' {

            { Assert-VirtualMachineHardDiskDriveParameter -Type 'Vhdx' -MaximumSizeBytes 127GB -VMGeneration 2 } | Should Not Throw;
        }

    } #end InModuleScope

} #end describe
