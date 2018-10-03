#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Rename-LabModuleCacheVersion' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        $testModuleDirectoryPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
        $testModulePath = '{0}\{1}.zip' -f $testModuleDirectoryPath, $testModuleName;
        $testModuleVersion = '1.2.3.4';
        $testModuleManifest = [PSCustomObject] @{
            ModuleVersion = $testModuleVersion;
        }
        Mock Get-LabModuleCacheManifest -MockWith { return $testModuleManifest; }

        It 'Returns a [System.IO.FileInfo] object type' {
            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testModuleDirectoryPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                Path = $testModulePath;
            }

            $result = Rename-LabModuleCacheVersion @testParams;

            $result -is [System.IO.FileInfo] | Should Be $true;
        }

        It 'Renames PSGallery module to "<ModuleName>-v<Version>.zip' {
            New-Item -Path $testModuleDirectoryPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                Path = $testModulePath;
            }

            $null = Rename-LabModuleCacheVersion @testParams -Verbose;

            $expectedPath = '{0}\{1}-v{2}.zip' -f $testModuleDirectoryPath, $testModuleName, $testModuleVersion;
            Test-Path -Path $expectedPath | Should Be $true;
        }

        It 'Renames GitHub module to "<ModuleName>-v<Version>_<Owner>_<Branch>.zip' {
            New-Item -Path $testModuleDirectoryPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testOwner = 'TestOwner';
            $testBranch = 'development';
            $testParams = @{
                Name = $testModuleName;
                Path = $testModulePath;
                Owner = $testOwner;
                Branch = $testBranch;
            }

            $null = Rename-LabModuleCacheVersion @testParams -Verbose;

            $expectedPath = '{0}\{1}-v{2}_{3}_{4}.zip' -f $testModuleDirectoryPath, $testModuleName, $testModuleVersion, $testOwner, $testBranch;
            Test-Path -Path $expectedPath | Should Be $true;
        }

        It 'Removes existing cached module file' {
            $expectedPath = '{0}\{1}-v{2}.zip' -f $testModuleDirectoryPath, $testModuleName, $testModuleVersion;
            New-Item -Path $expectedPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                Path = $testModulePath;
            }
            Mock Rename-Item -MockWith { }
            Mock Remove-Item -MockWith { }

            $null = Rename-LabModuleCacheVersion @testParams -Verbose;

            Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq $expectedPath } -Scope It;
        }

    } #end InModuleScope

} #end describe
