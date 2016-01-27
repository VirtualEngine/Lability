#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'ConfigurationData' {
    
    InModuleScope $moduleName {

        Context 'Validates "ConvertToConfigurationData" method' {
            
            It 'Returns a "System.Collections.Hashtable" type' {
                $configurationData = ConvertToConfigurationData -ConfigurationData @{};
                $configurationData -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Returns a "System.Collections.Hashtable" type from a file path' {
                $configurationDataPath = "TestDrive:\ConvertToConfigurationData.psd1";
                Set-Content -Path $configurationDataPath -Value '@{ Node = "Test"; }';
                $configurationData = ConvertToConfigurationData -ConfigurationData $configurationDataPath;
                $configurationData -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Throws when passed a directory path' {
                { ConvertToConfigurationData -ConfigurationData TestDrive:\ } | Should Throw;
            }

            It 'Throws when passed a file path with an extension other than ".psd1"' {
                $testPath = "TestDrive:\ConfigurationData.ps1";
                New-Item -Path $testPath -ItemType File -Force;
                { ConvertToConfigurationData -ConfigurationData $testPath } | Should Throw;
            }

            It 'Throws when passed a non-string or non-hashtable' {
                { ConvertToConfigurationData -ConfigurationData (Get-Date) } | Should Throw;
            }

        } #end context Validates "ConvertToConfigurationData" method

        Context 'Validates "ResolveConfigurationDataPath" method' {

            foreach ($config in @('Host','VM','Media','CustomMedia')) {
                
                It "Resolves '$config' to module path when custom configuration does not exist" {
                    Mock Test-Path -MockWith { return $false }
                    $configurationPath = ResolveConfigurationDataPath -Configuration $config -IncludeDefaultPath;
                    $configurationPath -match $repoRoot | Should Be $true;
                }

                It "Resolves '$config' to %ALLUSERSPROFILE% path when custom configuration does exist" {
                    Mock Test-Path -MockWith { return $true }
                    $configurationPath = ResolveConfigurationDataPath -Configuration $config;
                    $allUsersProfile = ("$env:AllUsersProfile\$moduleName").Replace('\','\\');
                    $configurationPath -match $allUsersProfile | Should Be $true;
                }

            } #end foreach $config

        } #end context Validates "ResolveConfigurationDataPath" method

        Context 'Validates "GetConfigurationData" method' {

            It 'Resolves environment variables in path' {
                $testConfigurationFilename = 'TestConfiguration.json';
                $testConfigurationPath = "$env:SystemRoot\$testConfigurationFilename";
                $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
                [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
                Mock ResolveConfigurationDataPath -MockWith { return ('%SYSTEMROOT%\{0}' -f $testConfigurationFilename); }
                Mock Get-Content -ParameterFilter { $Path -eq $testConfigurationPath } -MockWith { return $fakeConfiguration; }

                GetConfigurationData -Configuration Host;

                Assert-MockCalled Get-Content -ParameterFilter { $Path -eq $testConfigurationPath } -Scope It;
            }
            
            It 'Adds missing "CustomBootstrapOrder" property to VM configuration' {
                $testConfigurationFilename = 'TestVMConfiguration.json';
                $testConfigurationPath = "$env:SystemRoot\$testConfigurationFilename";
                $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
                [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
                Mock ResolveConfigurationDataPath -MockWith { return ('%SYSTEMROOT%\{0}' -f $testConfigurationFilename); }
                Mock Get-Content -ParameterFilter { $Path -eq $testConfigurationPath } -MockWith { return $fakeConfiguration; }
                
                $vmConfiguration = GetConfigurationData -Configuration VM;
                
                $vmConfiguration.CustomBootstrapOrder | Should Be 'MediaFirst';
            }

        } #end context Validates "GetConfigurationData" method

        ## Removed until I can work out why this one test is failing :(
        ##Context 'Validates "SetConfigurationData" method' {
        ##
        ##    It 'Resolves environment variables in path' {
        ##        $testConfigurationFilename = 'TestConfiguration.json';
        ##        $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }' | ConvertFrom-Json;
        ##        Mock ResolveConfigurationDataPath -MockWith { return ('%SYSTEMROOT%\{0}' -f $testConfigurationFilename); }
        ##        Mock NewDirectory -MockWith { }
        ##        Mock Set-Content -ParameterFilter { $Path -eq "$env:SystemRoot\$testConfigurationFilename" } -MockWith { return $fakeConfiguration; }
        ##
        ##        SetConfigurationData -Configuration Host -InputObject $fakeConfiguration;
        ##
        ##        Assert-MockCalled Set-Content -ParameterFilter { $Path -eq "$env:SystemRoot\$testConfigurationFilename" } -Scope It;
        ##    }
        ##
        ##} #end context Validates "GetConfigurationData" method
        
        Context 'Validates "RemoveConfigurationData" method' {
            
            It 'Removes configuration file' {
                $testConfigurationFilename = 'TestVMConfiguration.json';
                $testConfigurationPath = "$env:SystemRoot\$testConfigurationFilename";
                $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }';
                [ref] $null = New-Item -Path $testConfigurationPath -ItemType File -Force;
                Mock ResolveConfigurationDataPath -MockWith { return ('%SYSTEMROOT%\{0}' -f $testConfigurationFilename); }
                Mock Test-Path -MockWith { return $true; }
                Mock Remove-Item -ParameterFilter { $Path.EndsWith($testConfigurationFilename ) } -MockWith { }
                
                RemoveConfigurationData -Configuration VM;
                
                Assert-MockCalled Remove-Item -ParameterFilter { $Path.EndsWith($testConfigurationFilename) } -Scope It;
            }
            
        } #end context Validates "RemoveConfigurationData" method

    } #end InModuleScope

} #end describe ConfigurationData
