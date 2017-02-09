#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Test-Resolve-ConfigurationPath' {

    InModuleScope -ModuleName $moduleName {



        Mock GetLabHostDSCConfigurationPath -Mock { return "TestDrive:\Configurations"; }

        It 'returns mof in the specified path root' {

            $testVMName = 'VM01';
            $testConfigurationName = 'Config';
            $testConfiguration = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentName = $testConfigurationName;
            } } }
            $paths = @(
                "TestDrive:\Path",
                "TestDrive:\Path\$testConfigurationName",
                "TestDrive:\Configurations",
                "TestDrive:\Configurations\$testConfigurationName",
                "TestDrive:\PWD",
                "TestDrive:\PWD\$testConfigurationName"
            )
            $expected = Join-Path -Path (Get-PSDrive -Name TestDrive).Root -ChildPath ($paths[0].TrimStart('TestDrive:\'));
            $paths | ForEach-Object {

                New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path (Join-Path -Path $_ -ChildPath "$testVMName.mof") -ItemType File -Force;
            }

            Push-Location -Path 'TestDrive:\PWD';
            $result = Resolve-ConfigurationPath -ConfigurationData $testConfiguration -Path 'TestDrive:\Path' -Name $testVMName;
            Pop-Location;

            $result | Should Be $expected;
        }

        It 'returns mof in the specified path configuration folder' {

            $testVMName = 'VM02';
            $testConfigurationName = 'Config';
            $testConfiguration = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentName = $testConfigurationName;
            } } }
            $paths = @(
                "TestDrive:\Path\$testConfigurationName",
                "TestDrive:\Configurations",
                "TestDrive:\Configurations\$testConfigurationName",
                "TestDrive:\PWD",
                "TestDrive:\PWD\$testConfigurationName"
            )
            $expected = Join-Path -Path (Get-PSDrive -Name TestDrive).Root -ChildPath ($paths[0].TrimStart('TestDrive:\'));
            $paths | ForEach-Object {

                New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path (Join-Path -Path $_ -ChildPath "$testVMName.mof") -ItemType File -Force;
            }

            Push-Location -Path 'TestDrive:\PWD';
            $result = Resolve-ConfigurationPath -ConfigurationData $testConfiguration -Path 'TestDrive:\Path' -Name $testVMName;
            Pop-Location;

            $result | Should Be $expected;
        }

        It 'returns mof in the Configurations folder' {

            $testVMName = 'VM03';
            $testConfigurationName = 'Config';
            $testConfiguration = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentName = $testConfigurationName;
            } } }
            $paths = @(
                "TestDrive:\Configurations",
                "TestDrive:\Configurations\$testConfigurationName",
                "TestDrive:\PWD",
                "TestDrive:\PWD\$testConfigurationName"
            )
            $expected = Join-Path -Path (Get-PSDrive -Name TestDrive).Root -ChildPath ($paths[0].TrimStart('TestDrive:\'));
            $paths | ForEach-Object {

                New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path (Join-Path -Path $_ -ChildPath "$testVMName.mof") -ItemType File -Force;
            }

            Push-Location -Path 'TestDrive:\PWD';
            $result = Resolve-ConfigurationPath -ConfigurationData $testConfiguration -Path 'TestDrive:\Path' -Name $testVMName;
            Pop-Location;

            $result | Should Be $expected;
        }

        It 'returns mof in the default Configurations configuration folder' {

            $testVMName = 'VM04';
            $testConfigurationName = 'Config';
            $testConfiguration = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentName = $testConfigurationName;
            } } }
            $paths = @(
                "TestDrive:\Configurations\$testConfigurationName",
                "TestDrive:\PWD",
                "TestDrive:\PWD\$testConfigurationName"
            )
            $expected = Join-Path -Path (Get-PSDrive -Name TestDrive).Root -ChildPath ($paths[0].TrimStart('TestDrive:\'));
            $paths | ForEach-Object {

                New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path (Join-Path -Path $_ -ChildPath "$testVMName.mof") -ItemType File -Force;
            }

            Push-Location -Path 'TestDrive:\PWD';
            $result = Resolve-ConfigurationPath -ConfigurationData $testConfiguration -Path 'TestDrive:\Path' -Name $testVMName;
            Pop-Location;

            $result | Should Be $expected;
        }

        It 'returns mof in the $PWD' {

            $testVMName = 'VM05';
            $testConfigurationName = 'Config';
            $testConfiguration = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentName = $testConfigurationName;
            } } }
            $paths = @(
                "TestDrive:\PWD",
                "TestDrive:\PWD\$testConfigurationName"
            )
            $expected = Join-Path -Path (Get-PSDrive -Name TestDrive).Root -ChildPath ($paths[0].TrimStart('TestDrive:\'));
            $paths | ForEach-Object {

                New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path (Join-Path -Path $_ -ChildPath "$testVMName.mof") -ItemType File -Force;
            }

            Push-Location -Path 'TestDrive:\PWD';
            $result = Resolve-ConfigurationPath -ConfigurationData $testConfiguration -Path 'TestDrive:\Path' -Name $testVMName;
            Pop-Location;

            $result | Should Be $expected;
        }

        It 'returns mof in the $PWD configuration folder' {

            $testVMName = 'VM06';
            $testConfigurationName = 'Config';
            $testConfiguration = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentName = $testConfigurationName;
            } } }
            $paths = @(
                "TestDrive:\PWD\$testConfigurationName"
            )
            $expected = Join-Path -Path (Get-PSDrive -Name TestDrive).Root -ChildPath ($paths[0].TrimStart('TestDrive:\'));
            $paths | ForEach-Object {

                New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path (Join-Path -Path $_ -ChildPath "$testVMName.mof") -ItemType File -Force;
            }

            Push-Location -Path 'TestDrive:\PWD';
            $result = Resolve-ConfigurationPath -ConfigurationData $testConfiguration -Path 'TestDrive:\Path' -Name $testVMName;
            Pop-Location;

            $result | Should Be $expected;
        }


    } #end InModuleScope
} #end describe
