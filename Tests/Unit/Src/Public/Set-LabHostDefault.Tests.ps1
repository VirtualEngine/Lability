#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Set-LabHostDefault' {

    InModuleScope $moduleName {

        $fakeConfigurationDataObject = ConvertFrom-Json -InputObject '{
            "ConfigurationPath": "", "DifferencingVhdPath": "", "HotfixPath": "", "IsoPath": "",
            "ParentVhdPath": "", "ResourcePath": "", "ResourceShareName": "", "ModuleCachePath": ""
        }'

        Mock Get-ConfigurationData -MockWith { return $fakeConfigurationDataObject; }
        Mock Set-ConfigurationData -MockWith { }
        Mock ImportDismModule -MockWith { }

        It 'Resolves path containing an environment variable' {
            $testEnvironmentPath = '%SYSTEMROOT%';
            $testResolvedPath = "$env:SystemRoot".Trim('\');

            Set-LabHostDefault -IsoPath $testEnvironmentPath;

            Assert-MockCalled Set-ConfigurationData -ParameterFilter { $InputObject.IsoPath -eq $testResolvedPath } -Scope It;
        }

        foreach($parameter in ($fakeConfigurationDataObject.PSObject.Properties | Where Name -like '*Path').Name) {

            It "Calls 'Set-LabDefaults' with passed '$parameter' parameter" {
                $testPath = '{0}\{1}\' -f (Get-PSDrive -Name TestDrive).Root, $parameter; #- "TestDrive:\$parameter\";
                $testValidPath = $testPath.Trim('\');
                New-Item -Path $testValidPath -ItemType Directory -Force -ErrorAction SilentlyContinue;

                $setLabHostDefaultsParams = @{ $parameter = $testPath; }
                Set-LabHostDefault @setLabHostDefaultsParams;

                Assert-MockCalled Set-ConfigurationData -ParameterFilter { $InputObject.$parameter -eq $testValidPath } -Scope It;
            }
        }

        It 'Calls "Set-LabDefaults" with passed "ResourceShareName" parameter' {
                $testShareName = 'TestShare';

                Set-LabHostDefault -ResourceShareName $testShareName;

                Assert-MockCalled Set-ConfigurationData -ParameterFilter { $InputObject.ResourceShareName -eq $testShareName } -Scope It;
            }

        It 'Throws when passed an invalid path' {
            $testInvalidPath = 'Test Drive:\';

            { Set-LabHostDefault -IsoPath $testInvalidPath } | Should Throw;
        }

    } #end InModuleScope

} #end Describe
