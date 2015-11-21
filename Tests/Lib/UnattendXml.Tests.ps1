#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'UnattendXml' {
    
    InModuleScope $moduleName {

        Context 'Validates "NewUnattendXml" method' {

            It 'Returns a "System.Xml.XmlDocument" type' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone;
                
                $unattendXml -is [System.Xml.XmlDocument] | Should Be $true;
            }

            It 'Creates equal number of "x86" and "amd64" components' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone;

                $x64Count = ($unattendXml.unattend.settings.component | Where processorArchitecture -eq 'amd64').Count;
                $x86Count = ($unattendXml.unattend.settings.component | Where processorArchitecture -eq 'x86').Count;
                
                $x64Count | Should Be $x86Count;
            }

            It 'Sets encoded Administrator password' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $concatenatedTestPassword = '{0}AdministratorPassword' -f $TestPassword;
                $encodedTestPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($concatenatedTestPassword));
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.UserAccounts.AdministratorPassword.Value | Should Be $encodedTestPassword;
                    }
                }
            }

            It 'Sets timezone' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.TimeZone | Should Be $testTimeZone;
                    }
                }
            }

            It 'Sets Input locale' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testInputLocale = 'fr-FR';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -InputLocale $testInputLocale;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.InputLocale | Should Be $testInputLocale;
                    }
                }
            }

            It 'Sets System locale' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testSystemLocale = 'de-DE';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -SystemLocale $testSystemLocale;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.SystemLocale | Should Be $testSystemLocale;
                    }
                }
            }

            It 'Sets UI language' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testUILanguage = 'de-DE';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -UILanguage $testUILanguage;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.UILanguage | Should Be $testUILanguage;
                    }
                }
            }

            It 'Sets User locale' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testUserLocale = 'es-ES';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -UserLocale $testUserLocale;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.UserLocale | Should Be $testUserLocale;
                    }
                }
            }

            It 'Sets computer name' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testComputerName = 'TESTCOMPUTER';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -ComputerName $testComputerName;

                $unattendXml.unattend.settings | Where Pass -eq 'specialize' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.ComputerName | Should Be $testComputerName;
                    }
                }
            }

            It 'Sets product key' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO';
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -ProductKey $testProductKey;

                $unattendXml.unattend.settings | Where Pass -eq 'specialize' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.ProductKey | Should Be $testProductKey;
                    }
                }
            }

            It 'Adds single synchronous command' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testCommand = @(
                    @{ Description = 'Test Command #1'; Order = 1; Path = 'Command1.exe'; }
                )
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -ExecuteCommand $testCommand;

            }

            It 'Adds multiple synchronous commands' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testCommands = @(
                    @{ Description = 'Test Command #1'; Order = 1; Path = 'Command1.exe'; }
                    @{ Description = 'Test Command #2'; Order = 2; Path = 'Command2.exe'; }
                )
                $unattendXml = NewUnattendXml -Password $testPassword -Timezone $testTimezone -ExecuteCommand $testCommands;
            }

        } #end context Validates "NewUnattendXml" method

        Context 'Validates "SetUnattendXml" method' {

            It 'Saves Xml file to disk' {
                $testPassword = 'P@ssw0rd';
                $testTimezone = 'GMT Standard Time';
                $testPath = "$((Get-PSDrive -Name TestDrive).Root)\test.xml";
                
                SetUnattendXml -Path $testPath -Password $testPassword -Timezone $testTimezone;

                Test-Path -Path $testPath | Should Be $true;
            }

        } #end context 'Validates "SetUnattendXml" method

    } #end InModuleScope

} #end describe UnattendXml
