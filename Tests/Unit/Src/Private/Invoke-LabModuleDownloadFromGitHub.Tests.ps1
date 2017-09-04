#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Invoke-LabModuleDownloadFromGitHub' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        $testOwner = 'TestOwnder';
        $testBranch = 'TestBranch';
        $testDestinationPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
        $testModulePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;

        $testModuleManifest = [PSCustomObject] @{
            ModuleVersion = $testModuleVersion;
        }
        Mock Get-LabModuleCacheManifest -MockWith { return $testModuleManifest; }
        Mock Resolve-GitHubModuleUri -MockWith { return 'http://fake.uri' }
        Mock Set-ResourceDownload -MockWith { return $testModulePath }

        It 'Returns a [System.IO.FileInfo] object type' {
            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                Owner = $testOwner;
                Branch = $testBranch;
            }
            $result = Invoke-LabModuleDownloadFromGitHub @testParams;

            $result -is [System.IO.FileInfo] | Should Be $true;
        }

        It 'Calls "Resolve-GitHubModuleUri" with "Owner" and "Branch"' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                Owner = $testOwner;
                Branch = $testBranch;
            }
            Invoke-LabModuleDownloadFromGitHub @testParams;

            Assert-MockCalled Resolve-GitHubModuleUri -ParameterFilter { $Owner -eq $testOwner } -Scope It;
            Assert-MockCalled Resolve-GitHubModuleUri -ParameterFilter { $Branch -eq $testBranch } -Scope It;
        }

        It 'Calls "Resolve-GitHubModuleUri" with "OverrideRepositoryName" when specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testRepositoryOverrideName = 'Override';
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                Owner = $testOwner;
                Branch = $testBranch;
                OverrideRepositoryName = $testRepositoryOverrideName
            }
            Invoke-LabModuleDownloadFromGitHub @testParams;

            Assert-MockCalled Resolve-GitHubModuleUri -ParameterFilter { $OverrideRepositoryName -ne $testRepositoryOverrideName } -Scope It;
        }

        It 'Throws when "Owner" is not specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                Branch = $testBranch;
            }
            { Invoke-LabModuleDownloadFromGitHub @testParams } | Should Throw;
        }

        It 'Warns when no "Branch" is specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Name = $testModuleName;
                DestinationPath = $testDestinationPath;
                Owner = $testOwner;
            }

            { Invoke-LabModuleDownloadFromGitHub @testParams -WarningAction Stop 3>&1 } | Should Throw;
        }

    } #end InModuleScope
} #end Describe
