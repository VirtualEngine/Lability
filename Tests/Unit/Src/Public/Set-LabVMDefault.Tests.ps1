#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Set-LabVMDefault' {

    InModuleScope -ModuleName $moduleName {

        It 'Does not return "BootOrder" property' {
            Mock Set-ConfigurationData -MockWith { }

            $defaults = Set-LabVMDefault;

            $defaults.BootOrder | Should BeNullOrEmpty;
        }

        $testProperties = @(
            @{ StartupMemory = 2GB; }
            @{ MinimumMemory = 1GB; }
            @{ MaximumMemory = 2GB; }
            @{ ProcessorCount = 4; }
            @{ Media = '2012R2_x64_Standard_EN_Eval'; }
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
            @{ CustomBootstrapOrder = 'Disabled'; }
            @{ GuestIntegrationServices = $true; }
            @{ MaxEnvelopeSizeKb = 2048; }
        )
        foreach ($property in $testProperties) {

            It "Sets ""$($property.Keys[0])"" value" {
                Mock Set-ConfigurationData -MockWith { }

                $defaults = Set-LabVMDefault @property;

                $defaults.($property.Keys[0]) | Should Be $property.Values[0];
            }
        }

        $testFiles = @(
            @{ ClientCertificatePath = 'TestDrive:\TestClientCertificate.cer'; }
            @{ RootCertificatePath = 'TestDrive:\TestRootCertificate.cer'; }
        )
        foreach ($file in $testFiles) {

            It "Sets ""$($file.Keys[0])"" value" {
                Mock Set-ConfigurationData -MockWith { }
                New-Item -Path $file.Values[0] -Force -ErrorAction SilentlyContinue -ItemType File;

                $defaults = Set-LabVMDefault @file;

                $defaults.($file.Keys[0]) | Should Be $file.Values[0];
            }
        }

        It 'Throws if "Timezone" cannot be resolved' {
            { Set-LabVMDefault -Timezone 'Cloud cockoo land' } | Should Throw;
        }

        It 'Throws if "ClientCertificatePath" file cannot be found' {
            { Set-LabVMDefault -ClientCertificatePath 'TestDrive:\ClientCertificate.cer' } | Should Throw;
        }

        It 'Throws if "RootCertificatePath" file cannot be found' {
            { Set-LabVMDefault -RootCertificatePath 'TestDrive:\RootCertificate.cer' } | Should Throw;
        }

        It 'Throws if "StartupMemory" is less than "MinimumMemory"' {
            { Set-LabVMDefault -StartupMemory 1GB -MinimumMemory 2GB } | Should Throw;
        }

        It 'Throws if "StartupMemory" is greater than "MaximumMemory"' {
            { Set-LabVMDefault -StartupMemory 2GB -MaximumMemory 1GB } | Should Throw;
        }

        It 'Throws if "Media" cannot be resolved' {
            { Set-LabVMDefault -Media 'LabilityTestMedia' } | Should Throw;
        }

        It 'Calls "Set-ConfigurationData" to write data to disk' {
            Mock Set-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { }

            $null = Set-LabVMDefault;

            Assert-MockCalled Set-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' }
        }

    } #end InModuleScope

} #end describe
