#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-LabVirtualMachine' {

    InModuleScope $moduleName {

        $testVMName = 'TestVM';
        $testMediaId = 'TestMedia';
        $testVMSwitch = 'TestSwitch';
        $testLabVirtualMachineParams = @{
            Name = $testVMName;
            SwitchName = $testVMSwitch;
            Media = $testMediaId;
            StartupMemory = 2GB;
            MinimumMemory = 2GB;
            MaximumMemory = 2GB;
            ProcessorCount = 1;
        }

        ## Guard mocks
        Mock Resolve-LabMedia -MockWith { }
        Mock Import-LabDscResource -MockWith { }
        Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }

        It 'Imports Hyper-V DSC resource' {
            Mock Test-LabDscResource -MockWith { return $true; }

            Test-LabVirtualMachine @testLabVirtualMachineParams;

            Assert-MockCalled Import-LabDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
        }

        It 'Returns true when VM matches specified configuration' {
            Mock Test-LabDscResource -MockWith { return $true; }

            Test-LabVirtualMachine @testLabVirtualMachineParams | Should Be $true;
        }

        It 'Returns false when VM does not match specified configuration' {
            Mock Test-LabDscResource -MockWith { return $false; }

            Test-LabVirtualMachine @testLabVirtualMachineParams | Should Be $false;
        }

        It 'Returns false when error is thrown' {
            Mock Test-LabDscResource -MockWith { throw 'Vhd not found' }

            Test-LabVirtualMachine @testLabVirtualMachineParams | Should Be $false;
        }

        It 'Calls "Get-LabVirtualMachineProperty" with "ConfigurationData" when specified (#97)' {
            Mock Test-LabDscResource -MockWith { return $false; }
            Mock Get-LabVirtualMachineProperty -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

            Test-LabVirtualMachine @testLabVirtualMachineParams -ConfigurationData @{};

            Assert-MockCalled Get-LabVirtualMachineProperty -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope
} #end Describe
