#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVirtualMachine' {

    InModuleScope $moduleName {

        $testVMName = 'TestVM';
        $testMediaId = 'TestMedia';
        $testVMSwitch = 'TestSwitch';
        $setLabVirtualMachineParams = @{
            Name = $testVMName;
            SwitchName = $testVMSwitch;
            Media = $testMediaId;
            StartupMemory = 2GB;
            MinimumMemory = 2GB;
            MaximumMemory = 2GB;
            ProcessorCount = 1;
        }

        ## Guard mocks
        Mock Get-LabVirtualMachineProperty -MockWith { return @{}; }
        Mock Invoke-LabDscResource -MockWith { }
        Mock Import-LabDscResource -MockWith { }

        It 'Imports Hyper-V DSC resource' {

            Set-LabVirtualMachine @setLabVirtualMachineParams;

            Assert-MockCalled Import-LabDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
        }

        It 'Invokes Hyper-V DSC resource' {

            Set-LabVirtualMachine @setLabVirtualMachineParams;

            Assert-MockCalled Invoke-LabDscResource -ParameterFilter { $ResourceName -eq 'VM' } -Scope It;
        }

        It 'Calls "Get-LabVirtualMachineProperty" with "ConfigurationData" when specified (#97)' {
            Mock Get-LabVirtualMachineProperty -ParameterFilter { $ConfigurationData -ne $null } -MockWith { return @{}; }

            Set-LabVirtualMachine @setLabVirtualMachineParams -ConfigurationData @{};

            Assert-MockCalled Get-LabVirtualMachineProperty -ParameterFilter { $ConfigurationData -ne $null } -Scope It;
        }

    } #end InModuleScope
} #end Describe
