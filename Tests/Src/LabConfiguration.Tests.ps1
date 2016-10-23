#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force;

Describe 'Src\LabConfiguration' {

    InModuleScope $moduleName {

        Context 'Validates "Test-LabConfiguration" method' {

            It 'Calls "Test-LabVM" for each node' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                Mock Test-LabVM -MockWith { }

                Test-LabConfiguration -ConfigurationData $configurationData;

                Assert-MockCalled Test-LabVM -Exactly $configurationData.AllNodes.Count -Scope It;
            }

        } #end context Validates "Test-LabConfiguration" method

        Context 'Validates "TestLabConfigurationMof" method' {

            It 'Throws if path is invalid' {
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }

                { TestLabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path 'TestDrive:\InvalidPath' } | Should Throw;
            }

            It 'Does not throw if ".mof" and ".meta.mof" files exist' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                New-Item -Path "$testPath\$testVM.mof" -ItemType File -Force;
                New-Item -Path "$testPath\$testVM.meta.mof" -ItemType File -Force;

                { TestLabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath } | Should Not Throw;
            }

            It 'Throws if ".mof" file is missing' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Remove-Item -Path "$testPath\$testVM.mof" -Force -ErrorAction SilentlyContinue;
                Remove-Item -Path "$testPath\$testVM.meta.mof" -Force -ErrorAction SilentlyContinue;

                { TestLabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath } | Should Throw;
            }

            It 'Warns if ".meta.mof" file is missing' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                New-Item -Path "$testPath\$testVM.mof" -ItemType File -Force;
                Remove-Item -Path "$testPath\$testVM.meta.mof" -Force -ErrorAction SilentlyContinue;

                { TestLabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath -WarningAction Stop 3>&1 } | Should Throw;
            }

            It 'Warns if ".mof" file is missing but -SkipMofCheck is specified' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Remove-Item -Path "$testPath\$testVM.mof" -Force -ErrorAction SilentlyContinue;
                Remove-Item -Path "$testPath\$testVM.meta.mof" -Force -ErrorAction SilentlyContinue;

                { TestLabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath -SkipMofCheck -WarningAction Stop 3>&1 } | Should Throw;
            }

        } #end context Validates "TestLabConfigurationMof" method'

        Context 'Validates "Start-LabConfiguration" method' {

            $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

            It 'Throws is "Test-LabHostConfiguration" fails' {
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Mock Test-LabHostConfiguration -MockWith { return $false; }

                { Start-LabConfiguration -ConfigurationData $configurationData -Credential $testPassword } | Should Throw;
            }

            It 'Throws if path is invalid' {
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Mock Test-LabHostConfiguration -MockWith { return $true; }

                { Start-LabConfiguration -ConfigurationData $configurationData -Path 'TestDrive:\InvalidPath'  -Credential $testPassword } | Should Throw;
            }

            It 'Calls "NewLabVM" if node is not configured' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Mock Test-LabHostConfiguration -MockWith { return $true; }
                Mock TestLabConfigurationMof -MockWith { }
                Mock NewLabVM -ParameterFilter { $Name -eq $testVM } -MockWith { }
                Mock Test-LabConfiguration -MockWith { return @{ Name = $testVM; IsConfigured = $false; } }

                Start-LabConfiguration -ConfigurationData $configurationData -Credential $testPassword;

                Assert-MockCalled NewLabVM -ParameterFilter { $Name -eq $testVM } -Scope It;
            }

            It 'Does not call "NewLabVM" if node is configured' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Mock Test-LabHostConfiguration -MockWith { return $true; }
                Mock TestLabConfigurationMof -MockWith { }
                Mock NewLabVM -ParameterFilter { $Name -eq $testVM } -MockWith { }
                Mock Test-LabConfiguration -MockWith { return @{ Name = $testVM; IsConfigured = $true; } }

                Start-LabConfiguration -ConfigurationData $configurationData -Credential $testPassword;

                Assert-MockCalled NewLabVM -ParameterFilter { $Name -eq $testVM } -Exactly 0 -Scope It;
            }

            It 'Calls "NewLabVM" if node is configured but -Force is specified' {
                $testPath = 'TestDrive:';
                $testVM = 'VM1';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
                Mock Test-LabHostConfiguration -MockWith { return $true; }
                Mock TestLabConfigurationMof -MockWith { }
                Mock NewLabVM -ParameterFilter { $Name -eq $testVM } -MockWith { }
                Mock Test-LabConfiguration -MockWith { return @{ Name = $testVM; IsConfigured = $true; } }

                Start-LabConfiguration -ConfigurationData $configurationData -Credential $testPassword -Force;

                Assert-MockCalled NewLabVM -ParameterFilter { $Name -eq $testVM } -Scope It;
            }

        } #end context Validates "Start-LabConfiguration" method

        Context 'Validates "Remove-LabConfiguration" method' {

            It 'Calls "RemoveLabVM" for each node' {
                $configurationData = @{ AllNodes = @( @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; } ) }
                Mock RemoveLabVM -MockWith { }

                Remove-LabConfiguration -ConfigurationData $configurationData;

                Assert-MockCalled RemoveLabVM -Exactly $configurationData.AllNodes.Count -Scope It;
            }
        } #end context Validates "Remove-LabConfiguration" method

    } #end InModuleScope

} #end describe Src\LabConfiguration
