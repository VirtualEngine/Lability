#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\New-DiskImageGpt' {

    InModuleScope $moduleName {

        $stubPartition = Get-Partition | Select-Object -Last 1;

        ## Guard mocks
        Mock Start-ShellHWDetectionService { }
        Mock Stop-ShellHWDetectionService { }
        Mock Format-Volume { }
        Mock New-Partition { }

        It 'Stops and starts Shell Hardware Detection service' {
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock New-Partition -MockWith { return $stubPartition }
            Mock New-DiskPartFat32Partition -MockWith { }

            New-DiskImageGpt -Vhd $vhdImage;

            Assert-MockCalled Stop-ShellHWDetectionService -Scope It;
            Assert-MockCalled Start-ShellHWDetectionService -Scope It;
        }

        It 'Creates 250MB system partition' {
            $parameterFilter = { $Size -eq 250MB -and $GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' }
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock New-Partition -MockWith { return $stubPartition }
            Mock New-Partition -ParameterFilter $parameterFilter -MockWith { return $stubPartition }

            New-DiskImageGpt -Vhd $vhdImage;

            Assert-MockCalled New-Partition -ParameterFilter $parameterFilter -Scope It -Exactly 1;
        }

        It 'Creates OS partition' {
            $parameterFilter = { $GptType -eq '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' }
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock New-Partition -MockWith { return $stubPartition }
            Mock New-Partition -ParameterFilter $parameterFilter -MockWith { return $stubPartition }

            New-DiskImageGpt -Vhd $vhdImage;

            Assert-MockCalled New-Partition -ParameterFilter $parameterFilter -Scope It -Exactly 1;
        }

        It 'Formats volume as NTFS' {
            $parameterFilter = { $FileSystem -eq 'NTFS' };
            $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
            Mock New-Partition -MockWith { return $stubPartition }
            Mock Format-Volume -ParameterFilter $parameterFilter -MockWith { }

            New-DiskImageGpt -Vhd $vhdImage;

            Assert-MockCalled Format-Volume -ParameterFilter $parameterFilter -Scope It;
        }

    } #end InModuleScope
} #end Describe
