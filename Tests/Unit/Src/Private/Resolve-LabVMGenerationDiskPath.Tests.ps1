#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabVMGenerationDiskPath' {

    InModuleScope $moduleName {

        Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }
        Mock Get-LabImage { return @{ Id = $testMediaId; Generation = $testGeneration; } }

        $testMediaId = 'TestMedia';
        $testConfigurationData = @{ AllNodes = @() }

        It 'Resolves .VHDX media differencing path' {

            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            $testGeneration = 'VHDX';

            $resolveLabVMGenerationDiskPathParams = @{
                Name = $testVMName;
                Media = $testMediaId;
                ConfigurationData = $testConfigurationData;
            }
            $vhdPath = Resolve-LabVMGenerationDiskPath @resolveLabVMGenerationDiskPathParams;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.$testGeneration";
        }

        It 'Resolves .VHD media differencing path' {

            $testVMName = 'TestVM';
            $testDifferencingVhdPath = 'TestDrive:';
            $testGeneration = 'VHD';

            $resolveLabVMGenerationDiskPathParams = @{
                Name = $testVMName;
                Media = $testMediaId;
                ConfigurationData = $testConfigurationData;
            }
            $vhdPath = Resolve-LabVMGenerationDiskPath @resolveLabVMGenerationDiskPathParams;

            $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.$testGeneration";
        }

    } #end in module scope

} #end describe
