#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-ConfigurationData' {

    InModuleScope $moduleName {

        It 'Adds missing "CustomBootstrapOrder" property to VM configuration' {
            $testConfigurationFilename = 'TestVMConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            #Mock Get-Content -ParameterFilter { $Path -eq $testConfigurationPath } -MockWith { return $fakeConfiguration; }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $vmConfiguration = Get-ConfigurationData -Configuration VM;

            $vmConfiguration.CustomBootstrapOrder | Should Be 'MediaFirst';
        }

        It 'Adds missing "SecureBoot" property to VM configuration' {
            $testConfigurationFilename = 'TestVMConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $vmConfiguration = Get-ConfigurationData -Configuration VM;

            $vmConfiguration.SecureBoot -eq $true | Should Be $true;
        }

        It 'Adds missing "GuestIntegrationServices" property to VM configuration' {
            $testConfigurationFilename = 'TestVMConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $vmConfiguration = Get-ConfigurationData -Configuration VM;

            $vmConfiguration.GuestIntegrationServices -eq $false | Should Be $true;
        }

        It 'Adds missing "OperatingSystem" property to CustomMedia configuration' {
            $testConfigurationFilename = 'TestMediaConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '[{ "Id": "TestMedia" }]';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $customMediaConfiguration = Get-ConfigurationData -Configuration CustomMedia;

            $customMediaConfiguration.OperatingSystem | Should Be 'Windows';
        }

        It 'Adds missing "DisableLocalFileCaching" property to Host configuration' {
            $testConfigurationFilename = 'TestMediaConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $customMediaConfiguration = Get-ConfigurationData -Configuration Host;

            $customMediaConfiguration.DisableLocalFileCaching | Should Be $false;
        }

        It 'Adds missing "EnableCallStackLogging" property to Host configuration' {
            $testConfigurationFilename = 'TestMediaConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $customMediaConfiguration = Get-ConfigurationData -Configuration Host;

            $customMediaConfiguration.EnableCallStackLogging | Should Be $false;
        }

        It 'Removes deprecated "UpdatePath" property from Host configuration (Issue #77)' {
            $testConfigurationFilename = 'TestMediaConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations", "UpdatePath": "%SYSTEMDRIVE%\\TestLab\\Updates" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $hostConfiguration = Get-ConfigurationData -Configuration Host;

            $hostConfiguration.PSObject.Properties.Name.Contains('UpdatePath') | Should Be $false;
        }

        It 'Adds missing "DisableSwitchEnvironmentName" property to Host configuration' {
            $testConfigurationFilename = 'TestMediaConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $customMediaConfiguration = Get-ConfigurationData -Configuration Host;

            $customMediaConfiguration.DisableSwitchEnvironmentName | Should Be $true;
        }

        It 'Adds missing "MaxEnvelopeSizeKb" property to VM configuration' {
            $testConfigurationFilename = 'TestVMConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $vmConfiguration = Get-ConfigurationData -Configuration VM;

            $vmConfiguration.MaxEnvelopeSizeKb | Should Be 1024;
        }

        It 'Adds missing "UseNetBIOSName" property to VM configuration' {
            $testConfigurationFilename = 'TestVMConfiguration.json';
            $testConfigurationPath = "$env:SystemRoot\Temp\$testConfigurationFilename";
            $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
            [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
            Mock Resolve-ConfigurationDataPath -MockWith { return $testConfigurationPath }
            Mock Get-Content -MockWith { return $fakeConfiguration; }

            $vmConfiguration = Get-ConfigurationData -Configuration VM;

            $vmConfiguration.UseNetBIOSName -eq $false | Should Be $true;
        }

    } #end InModuleScope

} #end Describe
