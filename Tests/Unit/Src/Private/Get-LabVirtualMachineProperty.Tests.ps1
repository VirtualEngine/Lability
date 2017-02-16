#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-LabVirtualMachineProperty' {

    InModuleScope $moduleName {

        $testVMName = 'TestVM';
        $testMediaId = 'TestMedia';
        $testVMSwitch = 'TestSwitch';
        $getLabVirtualMachinePropertyParams = @{
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

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 1;
        }

        It 'Returns generation 2 VM for x64 media architecture' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 2;
        }

        It 'Returns generation 1 VM when custom "MBR" partition style is defined' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                return [PSCustomObject] @{ Architecture = 'x64'; CustomData = @{ PartitionStyle = 'MBR'; } } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 1;
        }

        It 'Returns generation 2 VM when custom "GPT" partition style is defined' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                return [PSCustomObject] @{ Architecture = 'x86'; CustomData = @{ PartitionStyle = 'GPT'; } } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 2;
        }

        It 'Returns generation 1 VM when image generation is "VHD", but media "x64" and partition style is "GPT"' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                return [PSCustomObject] @{ Architecture = 'x64'; CustomData = @{ PartitionStyle = 'GPT'; } } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHD';}; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 1;
        }

        It 'Returns generation 1 VM when image generation is "VHDX", but custom data "VmGeneration" is "1"' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                return [PSCustomObject] @{ Architecture = 'x86'; CustomData = @{ VmGeneration = 1; } } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 1;
        }

        It 'Returns generation 2 VM when image generation is "VHD", but custom data "VmGeneration" is "2"' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith {
                return [PSCustomObject] @{ Architecture = 'x86'; CustomData = @{ VmGeneration = 2; } } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHD';}; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.Generation | Should Be 2;
        }

        It 'Returns additional "VhdPath" property' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.VhdPath | Should Not BeNullOrEmpty;
        }

        It 'Returns additional "RestartIfNeeded" property' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.RestartIfNeeded | Should Be $true;
        }

        It 'Does not return "Media" property' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.ContainsKey('Media') | Should Be $false;
        }

        It 'Does not return "EnableGuestService" property by default' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.ContainsKey('EnableGuestService') | Should Be $false;
        }

        It 'Returns "EnableGuestService" property when "GuestIntegrationServices" is specified' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams -GuestIntegrationServices $true;

            $vmProperties.ContainsKey('EnableGuestService') | Should Be $true;
            $vmProperties.EnableGuestService | Should Be $true;
        }

        It 'Calls "ResolveLabMedia" with "ConfigurationData" when specified (#97)' {
            Mock ResolveLabMedia -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams -ConfigurationData @{};;

            Assert-MockCalled ResolveLabMedia -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

        It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
            Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams -ConfigurationData @{};;

            Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

        It 'Does not return "ConfigurationData" property by default (#97)' {
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] @{ Architecture = 'x64'; } }
            Mock Get-LabImage -MockWith { return @{ Generation = 'VHDX';}; }
            Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return "TestDrive:\$testVMName.vhdx"; }

            $vmProperties = Get-LabVirtualMachineProperty @getLabVirtualMachinePropertyParams;

            $vmProperties.ContainsKey('ConfigurationData') | Should Be $false;
        }

    } #end InModuleScope
} #end Describe
