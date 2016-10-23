#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force;

Describe 'Lib\VirtualMachine' {

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
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 1;
            }

            It 'Returns generation 2 VM for x64 media architecture' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 2;
            }

            It 'Returns generation 1 VM when custom "MBR" partition style is defined' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                    return [PSCustomObject] @{ Architecture = 'x64'; CustomData = @{ PartitionStyle = 'MBR'; } } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 1;
            }

            It 'Returns generation 2 VM when custom "GPT" partition style is defined' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                    return [PSCustomObject] @{ Architecture = 'x86'; CustomData = @{ PartitionStyle = 'GPT'; } } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 2;
            }

            It 'Returns generation 1 VM when image generation is "VHD", but media "x64" and partition style is "GPT"' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                    return [PSCustomObject] @{ Architecture = 'x64'; CustomData = @{ PartitionStyle = 'GPT'; } } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHD';}; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.Generation | Should Be 1;
            }

            It 'Returns additional "VhdPath" property' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.VhdPath | Should Not BeNullOrEmpty;
            }

            It 'Returns additional "RestartIfNeeded" property' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.RestartIfNeeded | Should Be $true;
            }

            It 'Does not return "Media" property' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.ContainsKey('Media') | Should Be $false;
            }

            It 'Does not return "EnableGuestService" property by default' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.ContainsKey('EnableGuestService') | Should Be $false;
            }

            It 'Returns "EnableGuestService" property when "GuestIntegrationServices" is specified' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams -GuestIntegrationServices $true;

                $vmProperties.ContainsKey('EnableGuestService') | Should Be $true;
                $vmProperties.EnableGuestService | Should Be $true;
            }

            It 'Calls "ResolveLabMedia" with "ConfigurationData" when specified (#97)' {
                Mock ResolveLabMedia -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams -ConfigurationData @{};;

                Assert-MockCalled ResolveLabMedia -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

            It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams -ConfigurationData @{};;

                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

            It 'Does not return "ConfigurationData" property by default (#97)' {
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

                $vmProperties = GetVirtualMachineProperties @getVirtualMachinePropertiesParams;

                $vmProperties.ContainsKey('ConfigurationData') | Should Be $false;
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
                Mock ResolveLabMedia -ParameterFilter { $null -eq $ConfigurationData } -MockWith { }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -MockWith { }
                Mock TestDscResource -MockWith { return $true; }

                TestLabVirtualMachine @testLabVirtualMachineParams;

                Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
            }

            It 'Returns true when VM matches specified configuration' {
                Mock ResolveLabMedia -ParameterFilter { $null -eq $ConfigurationData } -MockWith { }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $true; }

                TestLabVirtualMachine @testLabVirtualMachineParams | Should Be $true;
            }

            It 'Returns false when VM does not match specified configuration' {
                Mock ResolveLabMedia -ParameterFilter { $null -eq $ConfigurationData } -MockWith { }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $false; }

                TestLabVirtualMachine @testLabVirtualMachineParams | Should Be $false;
            }

            It 'Returns false when error is thrown' {
                Mock ResolveLabMedia -ParameterFilter { $null -eq $ConfigurationData } -MockWith { }
                Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { throw 'Vhd not found' }

                TestLabVirtualMachine @testLabVirtualMachineParams | Should Be $false;
            }

            It 'Calls "GetVirtualMachineProperties" with "ConfigurationData" when specified (#97)' {
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $false; }
                Mock GetVirtualMachineProperties -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

                TestLabVirtualMachine @testLabVirtualMachineParams -ConfigurationData @{};

                Assert-MockCalled GetVirtualMachineProperties -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
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
                Mock GetVirtualMachineProperties -MockWith { return @{}; }
                Mock InvokeDscResource -MockWith { }
                Mock ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -MockWith { }

                SetLabVirtualMachine @setLabVirtualMachineParams;

                Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
            }

            It 'Invokes Hyper-V DSC resource' {
                Mock GetVirtualMachineProperties -MockWith { return @{}; }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -MockWith { }

                SetLabVirtualMachine @setLabVirtualMachineParams;

                Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -Scope It;
            }

            It 'Calls "GetVirtualMachineProperties" with "ConfigurationData" when specified (#97)' {
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }
                Mock GetVirtualMachineProperties -ParameterFilter { $ConfigurationData -ne $null } -MockWith { return @{}; }

                SetLabVirtualMachine @setLabVirtualMachineParams -ConfigurationData @{};

                Assert-MockCalled GetVirtualMachineProperties -ParameterFilter { $ConfigurationData -ne $null } -Scope It;
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
                Mock GetVirtualMachineProperties -MockWith { return @{}; }
                Mock InvokeDscResource -MockWith { }
                Mock ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -MockWith { }

                RemoveLabVirtualMachine @removeLabVirtualMachineParams;

                Assert-MockCalled ImportDscResource -ParameterFilter { $ModuleName -eq 'xHyper-V' -and $ResourceName -eq 'MSFT_xVMHyperV' } -Scope It;
            }

            It 'Invokes Hyper-V DSC resource' {
                Mock GetVirtualMachineProperties -MockWith { return @{}; }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -MockWith { }

                RemoveLabVirtualMachine @removeLabVirtualMachineParams;

                Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VM' } -Scope It;
            }

            It 'Calls "GetVirtualMachineProperties" with "ConfigurationData" when specified (#97)' {
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }
                Mock GetVirtualMachineProperties -ParameterFilter { $ConfigurationData -ne $null } -MockWith { return @{}; }

                RemoveLabVirtualMachine @removeLabVirtualMachineParams -ConfigurationData @{ Test = $true};

                Assert-MockCalled GetVirtualMachineProperties -ParameterFilter { $ConfigurationData -ne $null } -Scope It;
            }

        } #end context Validates "SetLabVirtualMachine" method

    } #end InModuleScope

} #end describe Lib\VirtualMachine
