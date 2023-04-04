#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Invoke-LabModuleDownloadFromAzDo' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        $testModuleVersion = '1.2.3.4'
        $testDestinationPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
        $testModulePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;

        $testModuleManifest = [PSCustomObject] @{
            ModuleVersion = $testModuleVersion;
        }
        Mock Get-LabModuleCacheManifest -MockWith { return $testModuleManifest; }
        Mock Resolve-AzDoModuleUri -MockWith { return 'http://fake.uri' }
        Mock Set-ResourceDownload -MockWith { return $testModulePath }

        It 'Returns a [System.IO.FileInfo] object type' {
            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                RequiredVersion = $testModuleVersion;
            }
            $result = Invoke-LabModuleDownloadFromAzDo @testParams;

            $result -is [System.IO.FileInfo] | Should Be $true;
        }

        It 'Calls "Resolve-AzDoModuleUri" with "RequiredVersion" when specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                RequiredVersion = $testModuleVersion;
            }
            Invoke-LabModuleDownloadFromAzDo @testParams;

            Assert-MockCalled Resolve-AzDoModuleUri -ParameterFilter { $null -ne $RequiredVersion } -Scope It;
        }

        It 'Calls "Resolve-AzDoModuleUri" with "MinimumVersion" when specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                MinimumVersion = $testModuleVersion;
            }
            Invoke-LabModuleDownloadFromAzDo @testParams;

            Assert-MockCalled Resolve-AzDoModuleUri -ParameterFilter { $null -ne $MinimumVersion } -Scope It;
        }

        It 'Throws when downloaded module version does not match expected minimum version (#375)' {
            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;

            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                MinimumVersion = '1.2.3.5';
            }
            { Invoke-LabModuleDownloadFromAzDo @testParams } | Should Throw
        }

        It 'Throws when downloaded module version does not match required version (#375)' {
            Mock Get-LabModuleCacheManifest -MockWith { return @{  ModuleVersion = '1.2.3.5' } }

            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;

            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                RequiredVersion = $testModuleVersion;
            }
            { Invoke-LabModuleDownloadFromAzDo @testParams } | Should Throw
        }

    } #end InModuleScope
} #end Describe
