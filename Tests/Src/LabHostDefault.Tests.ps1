#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force;

Describe 'Src\LabHostDefaults' {

    InModuleScope $moduleName {

        Mock ImportDismModule { }

        Context 'Validates "Get-LabHostDefault" method' {

            It 'Calls "GetConfigurationData"' {
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { }

                Get-LabHostDefault;

                Assert-MockCalled GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' }
            }

        } #end context Validates "Get-LabHostDefault" method

        Context 'Validates "GetLabHostDSCConfigurationPath" method' {

            It 'Returns host configuration path' {
                $testConfigurationPath = 'TestDrive:\';
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ ConfigurationPath = $testConfigurationPath; } }

                GetLabHostDSCConfigurationPath | Should Be $testConfigurationPath;
            }

        } #end context Validates "GetLabHostDSCConfigurationPath" method

        Context 'Validates "Set-LabHostDefault" method' {

            $fakeConfigurationDataObject = ConvertFrom-Json -InputObject '{
                "ConfigurationPath": "", "DifferencingVhdPath": "", "HotfixPath": "", "IsoPath": "",
	            "ParentVhdPath": "", "ResourcePath": "", "ResourceShareName": "", "ModuleCachePath": ""
            }'

            It 'Resolves path containing an environment variable' {
                $testEnvironmentPath = '%SYSTEMROOT%';
                $testResolvedPath = "$env:SystemRoot".Trim('\');
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeConfigurationDataObject; }
                Mock SetConfigurationData -ParameterFilter { $InputObject.IsoPath -eq $testResolvedPath } -MockWith { }

                Set-LabHostDefault -IsoPath $testEnvironmentPath;

                Assert-MockCalled SetConfigurationData -ParameterFilter { $InputObject.IsoPath -eq $testResolvedPath } -Scope It;
            }

            foreach($parameter in ($fakeConfigurationDataObject.PSObject.Properties | Where Name -like '*Path').Name) {

                It "Calls 'Set-LabDefaults' with passed '$parameter' parameter" {
                    $testPath = '{0}\{1}\' -f (Get-PSDrive -Name TestDrive).Root, $parameter; #- "TestDrive:\$parameter\";
                    $testValidPath = $testPath.Trim('\');
                    New-Item -Path $testValidPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
                    Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeConfigurationDataObject; }
                    Mock SetConfigurationData -MockWith {  }
                    Mock SetConfigurationData -ParameterFilter { $InputObject.$parameter -eq $testValidPath } -MockWith { }

                    $setLabHostDefaultsParams = @{ $parameter = $testPath; }
                    Set-LabHostDefault @setLabHostDefaultsParams;

                    Assert-MockCalled SetConfigurationData -ParameterFilter { $InputObject.$parameter -eq $testValidPath } -Scope It;
                }
            }

            It 'Calls "Set-LabDefaults" with passed "ResourceShareName" parameter' {
                    $testShareName = 'TestShare';
                    Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeConfigurationDataObject; }
                    Mock SetConfigurationData -MockWith {  }
                    Mock SetConfigurationData -ParameterFilter { $InputObject.ResourceShareName -eq $testShareName } -MockWith { }

                    Set-LabHostDefault -ResourceShareName $testShareName;

                    Assert-MockCalled SetConfigurationData -ParameterFilter { $InputObject.ResourceShareName -eq $testShareName } -Scope It;
                }

            It 'Throws when passed an invalid path' {
                $testInvalidPath = 'Test Drive:\';
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeConfigurationDataObject; }
                Mock SetConfigurationData -MockWith { }

                { Set-LabHostDefault -IsoPath $testInvalidPath } | Should Throw;
            }

        } #end context Validates "Set-LabHostDefault" method

    } #end InModuleScope

} #end describe Src\LabHostDefaults
