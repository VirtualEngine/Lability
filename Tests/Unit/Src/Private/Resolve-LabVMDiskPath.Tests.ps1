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

        It 'Defaults to "VHDX" when no "Generation" is specified' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.vhdx";
        }

        It 'Returns "VHD" when VHD "Generation" is specified' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName -Generation 'VHD';

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.vhd";
        }

        It 'Adds environment name to host "DifferencingVhdPath" when "EnvironmentName" is defined' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            $testEnvironmentName = 'TestEnvironment';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName -EnvironmentName $testEnvironmentName;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testEnvironmentName\$testVMName.vhdx";
        }

        It 'Does not add environment name to host "DifferencingVhdPath" when "EnvironmentName" is null' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; DisableVhdEnvironmentName = $true; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName -EnvironmentName $null;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.vhdx";
        }

        It 'Does not add environment name to host "DifferencingVhdPath" when "DisableVhdEnvironmentName" is defined' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            $testEnvironmentName = 'TestEnvironment';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; DisableVhdEnvironmentName = $true; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName -EnvironmentName $testEnvironmentName;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.vhdx";
        }

        It 'Returns host "DifferencingVhdPath" when "Parent" is specified' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName -Parent;

            $vhdPath | Should Be "$testDifferencingVhdPath";
        }

        It 'Returns host "DifferencingVhdPath" when "EnvironmentName" is defined and "Parent" is specified' {
            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            $testEnvironmentName = 'TestEnvironment';
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; DisableVhdEnvironmentName = $false; } }

            $vhdPath = Resolve-LabVMDiskPath -Name $testVMName -EnvironmentName $testEnvironmentName -Parent;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testEnvironmentName";
        }

    } #end InModuleScope

} #end describe
