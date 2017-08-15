#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Invoke-LabModuleDownloadFromPSGallery' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        $testDestinationPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
        $testModulePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;

        $testModuleManifest = [PSCustomObject] @{
            ModuleVersion = $testModuleVersion;
        }
        Mock Get-LabModuleCacheManifest -MockWith { return $testModuleManifest; }
        Mock Resolve-PSGalleryModuleUri -MockWith { return 'http://fake.uri' }
        Mock SetResourceDownload -MockWith { return $testModulePath }

        It 'Returns a [System.IO.FileInfo] object type' {
            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                RequiredVersion = '1.2.3.4';
            }
            $result = Invoke-LabModuleDownloadFromPSGallery @testParams;

            $result -is [System.IO.FileInfo] | Should Be $true;
        }

        It 'Calls "Resolve-PSGalleryModuleUri" with "RequiredVersion" when specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                RequiredVersion = '1.2.3.4';
            }
            Invoke-LabModuleDownloadFromPSGallery @testParams;

            Assert-MockCalled Resolve-PSGalleryModuleUri -ParameterFilter { $null -ne $RequiredVersion } -Scope It;
        }

        It 'Calls "Resolve-PSGalleryModuleUri" with "MinimumVersion" when specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                MinimumVersion = '1.2.3.4';
            }
            Invoke-LabModuleDownloadFromPSGallery @testParams;

            Assert-MockCalled Resolve-PSGalleryModuleUri -ParameterFilter { $null -ne $MinimumVersion } -Scope It;
        }

    } #end InModuleScope
} #end Describe
