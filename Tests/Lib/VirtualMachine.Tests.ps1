#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'VirtualMachine' {

    InModuleScope $moduleName {

        Context 'Validates "GetVirtualMachineProperties" method' {

            $testVMName = 'TestVM';
            $testMediaId = 'TestMedia';
            $testVMSwitch = 'TestSwitch';
            $getVirtualMachinePropertiesParams = @{
                Name = $testVMName;
                SwitchName = $testVMSwitch;
                Media = $testMediaId;
                StartupMemory = 2GB;
                MinimumMemory = 2GB;
                MaximumMemory = 2GB;
                ProcessorCount = 1;
            }

            It 'Returns generation 1 VM for x86 media architecture' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x86'; } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 1;
            }

            It 'Returns generation 2 VM for x64 media architecture' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }
                
                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 2;
            }
            
            It 'Returns generation 1 VM when custom "MBR" partition style is defined' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                    return [PSCustomObject] @{ Architecture = 'x64'; CustomData = @{ PartitionStyle = 'MBR'; } } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }
                
                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 1;
            }
            
            It 'Returns generation 2 VM when custom "GPT" partition style is defined' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                    return [PSCustomObject] @{ Architecture = 'x86'; CustomData = @{ PartitionStyle = 'GPT'; } } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }
                
                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 2;
            }

            It 'Returns additional "VhdPath" property' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.VhdPath | Should Not BeNullOrEmpty;
            }

            It 'Returns additional "RestartIfNeeded" property' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.RestartIfNeeded | Should Be $true;
            }

            It 'Does not return "Media" property' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;
                
                $vmProperties.ContainsKey('Media') | Should Be $false;
            }

        } #end context Validates "GetVirtualMachineProperties" method

        Context 'Validates "TestLabVirtualMachine" method' {
            
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

            It 'Imports Hyper-V DSC resource' {
                Mock ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -MockWith { }
                Mock TestDscResource -MockWith { return $true; }

                TestLabVirtualMachine @testLabVirtualMachineParams;
                
                Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
            }

            It 'Returns true when VM matches specified configuration' {
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $true; }

                TestLabVirtualMachine @testLabVirtualMachineParams | Should Be $true;
            }

            It 'Returns false when VM does not match specified configuration' {
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $false; }

                TestLabVirtualMachine @testLabVirtualMachineParams | Should Be $false;
            }

            It 'Returns false when error is thrown' {
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { Write-Error 'Something went wrong' }

                TestLabVirtualMachine @testLabVirtualMachineParams | Should Be $false;
            }
            

        } #end context Validates "TestLabVirtualMachine" method

        Context 'Validates "SetLabVirtualMachine" method' {

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
            
            It 'Imports Hyper-V DSC resource' {
                Mock InvokeDscResource -MockWith { }
                Mock ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -MockWith { }

                SetLabVirtualMachine @setLabVirtualMachineParams;
                
                Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
            }

            It 'Invokes Hyper-V DSC resource' {
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -MockWith { }

                SetLabVirtualMachine @setLabVirtualMachineParams;
                
                Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -Scope It;
            }

        } #end context Validates "SetLabVirtualMachine" method

        Context 'Validates "RemoveLabVirtualMachine" method' {

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
            
            It 'Imports Hyper-V DSC resource' {
                Mock InvokeDscResource -MockWith { }
                Mock ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -MockWith { }

                RemoveLabVirtualMachine @removeLabVirtualMachineParams;
                
                Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
            }

            It 'Invokes Hyper-V DSC resource' {
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -MockWith { }
                
                RemoveLabVirtualMachine @removeLabVirtualMachineParams;
                
                Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -Scope It;
            }

        } #end context Validates "SetLabVirtualMachine" method

    } #end InModuleScope

} #end describe VirtualMachine
