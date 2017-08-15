#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\New-DiskImageMbr' {

    InModuleScope $moduleName {

        ## We're going to Mock Get-Partition so best grab a copy now!
        $stubPartition = Get-Partition | Select-Object -Last 1;

        ## Guard mocks
        Mock Format-Volume -MockWith { }
        Mock Start-ShellHWDetectionService { }
        Mock Stop-ShellHWDetectionService { }
        Mock New-Partition -MockWith { }

        It 'Stops Shell Hardware Detection service' {
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock New-Partition -MockWith { return $stubPartition }
            Mock Add-PartitionAccessPath -MockWith { return $stubPartition }
            Mock Get-Partition -MockWith { return $stubPartition }


            New-DiskImageMbr -Vhd $vhdImage;

            Assert-MockCalled Stop-ShellHWDetectionService -Scope It;
            Assert-MockCalled Start-ShellHWDetectionService -Scope It;
        }

        It 'Creates a full size active IFS partition' {
            $parameterFilter = { $MbrType -eq 'IFS' };
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock Add-PartitionAccessPath -MockWith { return $stubPartition }
            Mock Get-Partition -MockWith { return $stubPartition }
            Mock New-Partition -ParameterFilter $parameterFilter -MockWith { return $stubPartition }

            New-DiskImageMbr -Vhd $vhdImage;

            Assert-MockCalled New-Partition -ParameterFilter $parameterFilter -Scope It;
        }

        It 'Formats volume as NTFS' {
            $parameterFilter = { $FileSystem -eq 'NTFS' }
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock New-Partition -MockWith { return $stubPartition }
            Mock Add-PartitionAccessPath -MockWith { return $stubPartition }
            Mock Get-Partition -MockWith { return $stubPartition }
            Mock Format-Volume -ParameterFilter $parameterFilter -MockWith { }

            New-DiskImageMbr -Vhd $vhdImage;

            Assert-MockCalled Format-Volume -ParameterFilter $parameterFilter -Scope It;
        }

    } #end InModuleScope
} #end Describe
