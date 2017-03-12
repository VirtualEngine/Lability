#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabVirtualMachine' {

    InModuleScope $moduleName {

        $testVMName = 'TestVM';
        $testMediaId = 'TestMedia';
        $testVMSwitch = 'TestSwitch';
        $removeLabVirtualMachineParams = @{
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
        Mock InvokeDscResource -MockWith { }
        Mock ImportDscResource -MockWith { }

        It 'Imports Hyper-V DSC resource' {

            RemoveLabVirtualMachine @removeLabVirtualMachineParams;

            Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
        }

        It 'Invokes Hyper-V DSC resource' {

            RemoveLabVirtualMachine @removeLabVirtualMachineParams;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -Scope It;
        }

        It 'Calls "Get-LabVirtualMachineProperty" with "ConfigurationData" when specified (#97)' {

            RemoveLabVirtualMachine @removeLabVirtualMachineParams -ConfigurationData @{ Test = $true};

            Assert-MockCalled Get-LabVirtualMachineProperty -ParameterFilter { $ConfigurationData -ne $null } -Scope It;
        }

    } #end InModuleScope
} #end Describe
