#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Lib\UnattendXml' {

    InModuleScope $moduleName {

        Context 'Validates "NewUnattendXml" method' {

            It 'Returns a "System.Xml.XmlDocument" type' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone;

                $unattendXml -is [System.Xml.XmlDocument] | Should Be $true;
            }

            It 'Creates equal number of "x86" and "amd64" components' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone;

                $x64Count = ($unattendXml.unattend.settings.component | Where processorArchitecture -eq 'amd64').Count;
                $x86Count = ($unattendXml.unattend.settings.component | Where processorArchitecture -eq 'x86').Count;

                $x64Count | Should Be $x86Count;
            }

            It 'Sets encoded Administrator password' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $concatenatedTestPassword = '{0}AdministratorPassword' -f $TestPassword.GetNetworkCredential().Password;
                $encodedTestPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($concatenatedTestPassword));
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.UserAccounts.AdministratorPassword.Value | Should Be $encodedTestPassword;
                    }
                }
            }

            It 'Sets timezone' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.TimeZone | Should Be $testTimeZone;
                    }
                }
            }

            It 'Sets Input locale' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testInputLocale = 'fr-FR';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -InputLocale $testInputLocale;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.InputLocale | Should Be $testInputLocale;
                    }
                }
            }

            It 'Sets System locale' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testSystemLocale = 'de-DE';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -SystemLocale $testSystemLocale;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.SystemLocale | Should Be $testSystemLocale;
                    }
                }
            }

            It 'Sets UI language' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testUILanguage = 'de-DE';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -UILanguage $testUILanguage;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.UILanguage | Should Be $testUILanguage;
                    }
                }
            }

            It 'Sets User locale' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testUserLocale = 'es-ES';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -UserLocale $testUserLocale;

                $unattendXml.unattend.settings | Where Pass -eq 'oobeSystem' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-International-Core' | %{
                        $_.UserLocale | Should Be $testUserLocale;
                    }
                }
            }

            It 'Sets computer name' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testComputerName = 'TESTCOMPUTER';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -ComputerName $testComputerName;

                $unattendXml.unattend.settings | Where Pass -eq 'specialize' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.ComputerName | Should Be $testComputerName;
                    }
                }
            }

            It 'Sets product key' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO';
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -ProductKey $testProductKey;

                $unattendXml.unattend.settings | Where Pass -eq 'specialize' | %{
                    $_.Component | Where Name -eq 'Microsoft-Windows-Shell-Setup' | %{
                        $_.ProductKey | Should Be $testProductKey;
                    }
                }
            }

            It 'Adds single synchronous command' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testCommand = @(
                    @{ Description = 'Test Command #1'; Order = 1; Path = 'Command1.exe'; }
                )
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -ExecuteCommand $testCommand;

            }

            It 'Adds multiple synchronous commands' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testCommands = @(
                    @{ Description = 'Test Command #1'; Order = 1; Path = 'Command1.exe'; }
                    @{ Description = 'Test Command #2'; Order = 2; Path = 'Command2.exe'; }
                )
                $unattendXml = NewUnattendXml -Credential $testPassword -Timezone $testTimezone -ExecuteCommand $testCommands;
            }

        } #end context Validates "NewUnattendXml" method

        Context 'Validates "SetUnattendXml" method' {

            It 'Saves Xml file to disk' {
                $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
                $testTimezone = 'GMT Standard Time';
                $testPath = "$((Get-PSDrive -Name TestDrive).Root)\test.xml";

                SetUnattendXml -Path $testPath -Credential $testPassword -Timezone $testTimezone;

                Test-Path -Path $testPath | Should Be $true;
            }

        } #end context 'Validates "SetUnattendXml" method

    } #end InModuleScope

} #end describe Lib\UnattendXml
