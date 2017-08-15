#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-DiskImageBootVolume' {

    InModuleScope $moduleName {

        It 'Calls "Set-DiskImageBootVolumeGpt" when partition style is GPT' {
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock Set-DiskImageBootVolumeGpt -MockWith { };

            Set-DiskImageBootVolume -Vhd $vhdImage -PartitionStyle GPT;

            Assert-MockCalled Set-DiskImageBootVolumeGpt -Scope It;
        }

        It 'Calls "Set-DiskImageBootVolumeMbr" when partition style is MBR' {
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock Set-DiskImageBootVolumeMbr -MockWith { };

            Set-DiskImageBootVolume -Vhd $vhdImage -PartitionStyle MBR;

            Assert-MockCalled Set-DiskImageBootVolumeMbr -Scope It;
        }

    } #end InModuleScope
} #end Describe
