#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabVMDefaults' {

    InModuleScope $moduleName {

        Context 'Validates "Get-LabVMDefaults" method' {

            It 'Returns a "System.Management.Automation.PSCustomObject" object type' {
                $defaults = Get-LabVMDefaults;
                
                $defaults -is [System.Management.Automation.PSCustomObject] | Should Be $true;
            }

            It 'Does not return "BootOrder" property' {
                $defaults = Get-LabVMDefaults;

                $defaults.BootOrder | Should BeNullOrEmpty;
            }

        } #end context Validates "Get-LabVMDefaults" method
        
        Context 'Validates "Set-LabVMDefaults" method' {

            It 'Does not return "BootOrder" property' {
                Mock SetConfigurationData -MockWith { }
                $defaults = Set-LabVMDefaults;

                $defaults.BootOrder | Should BeNullOrEmpty;
            }
            
            $testProperties = @(
                @{ StartupMemory = 2GB; }
                @{ MinimumMemory = 1GB; }
                @{ MaximumMemory = 2GB; }
                @{ ProcessorCount = 4; }
                @{ Media = 'Test-Media'; }
                @{ SwitchName = 'Test Switch'; }
                @{ Timezone = 'Eastern Standard Time'; }
                @{ InputLocale = 'DE-de'; }
                @{ InputLocale = '0809:00000809'; }
                @{ SystemLocale = 'FR-fr'; }
                @{ UILanguage = 'ES-es'; }
                @{ UserLocale = 'EN-gb'; }
                @{ RegisteredOwner = 'Virtual Engine Ltd'; }
                @{ RegisteredOrganization = 'Virtual Engine Ltd'; }
                @{ BootDelay = 42; }
            )
            foreach ($property in $testProperties) {
                It "Sets ""$($property.Keys[0])"" value" {
                    Mock SetConfigurationData -MockWith { }
                    $defaults = Set-LabVMDefaults @property;

                    $defaults.($property.Keys[0]) | Should Be $property.Values[0];
                }
            }

            $testFiles = @(
                @{ ClientCertificatePath = 'TestDrive:\TestClientCertificate.cer'; }
                @{ RootCertificatePath = 'TestDrive:\TestRootCertificate.cer'; }
            )
            foreach ($file in $testFiles) {
                It "Sets ""$($file.Keys[0])"" value" {
                    Mock SetConfigurationData -MockWith { }
                    New-Item -Path $file.Values[0] -Force -ErrorAction SilentlyContinue;
                    $defaults = Set-LabVMDefaults @file;
                    
                    $defaults.($file.Keys[0]) | Should Be $file.Values[0];
                }
            }

            It 'Throws if "Timezone" cannot be resolved' {
                { Set-LabVMDefaults -Timezone 'Cloud cockoo land' } | Should Throw;
            }

            It 'Throws if "ClientCertificatePath" file cannot be found' {
                { Set-LabVMDefaults -ClientCertificatePath 'TestDrive:\ClientCertificate.cer' } | Should Throw;
            }

            It 'Throws if "RootCertificatePath" file cannot be found' {
                { Set-LabVMDefaults -RootCertificatePath 'TestDrive:\RootCertificate.cer' } | Should Throw;
            }

            It 'Throws if "StartupMemory" is less than "MinimumMemory"' {
                { Set-LabVMDefaults -StartupMemory 1GB -MinimumMemory 2GB } | Should Throw;
            }

            It 'Throws if "StartupMemory" is greater than "MaximumMemory"' {
                { Set-LabVMDefaults -StartupMemory 2GB -MaximumMemory 1GB } | Should Throw;
            }

            It 'Calls "SetConfigurationData" to write data to disk' {
                Mock SetConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { }

                $defaults = Set-LabVMDefaults;

                Assert-MockCalled SetConfigurationData -ParameterFilter { $Configuration -eq 'VM' }
            }

        } #end context Validates "Set-LabVMDefaults" method
    } #end InModuleScope

} #end describe LabVMDefaults
