#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Invoke-LabModuleCacheDownload' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        $testRequiredVersion = '0.1.2';
        $testParams = @{
            Name = $testModuleName;
            RequiredVersion = $testRequiredVersion;
        }
        Mock Invoke-LabModuleDownloadFromPSGallery;
        Mock Invoke-LabModuleDownloadFromGitHub;
        Mock Invoke-LabModuleDownloadFromAzDo;

        It 'Downloads module from PSGallery when no Provider is specified' {
            Mock Test-LabModuleCache -MockWith { return $false; }

            Invoke-LabModuleCacheDownload @testParams;

            Assert-MockCalled Invoke-LabModuleDownloadFromPSGallery -Scope It;
        }

        It 'Downloads module from GitHub by ModuleInfo' {
            Mock Test-LabModuleCache -MockWith { return $false; }

            $moduleInfo = @{
                Name = $testModuleName;
                Provider = 'GitHub';
                RequiredVersion = $testRequiredVersion;
                Owner = 'TestOwner';
                Branch = 'TestBranch';
                Path = 'TestPath';
            }
            Invoke-LabModuleCacheDownload -Module $moduleInfo;

            Assert-MockCalled Invoke-LabModuleDownloadFromGitHub -Scope It;
        }

        It 'Downloads module from PSGallery when "PSGallery" Provider is specified' {
            Mock Test-LabModuleCache -MockWith { return $false; }

            Invoke-LabModuleCacheDownload @testParams -Provider 'PSGallery';

            Assert-MockCalled Invoke-LabModuleDownloadFromPSGallery -Scope It;
        }

        It 'Downloads module from Azure DevOps when "AzDo" Provider is specified' {
            Mock Test-LabModuleCache -MockWith { return $false; }

            Invoke-LabModuleCacheDownload @testParams -Provider 'AzDo';

            Assert-MockCalled Invoke-LabModuleDownloadFromAzDo -Scope It;
        }

        It 'Downloads module from GitHub when "GitHub" Provider is specified' {
            Mock Test-LabModuleCache -MockWith { return $false; }

            Invoke-LabModuleCacheDownload @testParams -Provider 'GitHub';

            Assert-MockCalled Invoke-LabModuleDownloadFromGitHub -Scope It;
        }

        It 'Does not download module when "FileSystem" Provider is specified' {
            Mock Test-LabModuleCache -MockWith { return $false; }

            Invoke-LabModuleCacheDownload @testParams -Provider 'FileSystem';

            Assert-MockCalled Invoke-LabModuleDownloadFromPSGallery -Scope It -Exactly 0;
            Assert-MockCalled Invoke-LabModuleDownloadFromGitHub -Scope It -Exactly 0;
        }

        It 'Does not download module when resource is cached' {
            Mock Test-LabModuleCache -MockWith { return $true; }

            Invoke-LabModuleCacheDownload @testParams;

            Assert-MockCalled Invoke-LabModuleDownloadFromPSGallery -Scope It -Exactly 0;
            Assert-MockCalled Invoke-LabModuleDownloadFromGitHub -Scope It -Exactly 0;
        }

        It 'Forces module download when module is cached and "Latest" is specified via ModuleInfo (#367)' {
            Mock Test-LabModuleCache -MockWith { return $true; }
            $moduleInfo = @{
                Name = $testModuleName;
                Latest = $true;
            }

            Invoke-LabModuleCacheDownload -Module $moduleInfo;

            Assert-MockCalled Invoke-LabModuleDownloadFromPSGallery -Scope It -Exactly 1;
        }

    } #end InModuleScope
} #end Describe
