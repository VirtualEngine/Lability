#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Expand-LabModuleCache' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        #$testRequiredVersion = '0.1.2';
        $testDestinationPath = (Get-PSDrive -Name TestDrive).Root
        $testModuleSourceFilePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;
        $testModuleSourceFolderPath = '{0}\Source{1}' -f $testDestinationPath, $testModuleName;
        $testModuleDestinationPath = '{0}\{1}' -f $testDestinationPath, $testModuleName;

        $testModuleInfo = @{ Name = $testModuleName; }

        Mock Expand-ZipArchive -MockWith { New-Item -Path $testModuleDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue; }
        Mock Expand-GitHubZipArchive -MockWith { New-Item -Path $testModuleDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue; }
        Mock Get-LabModuleCache -MockWith { return (Get-Item -Path $testModuleSourceFilePath) }

        It 'Returns a [System.IO.DirectoryInfo] object type' {
            ## BeforeEach does not (currently) work inside InModuleScope scriptblocks https://github.com/pester/Pester/issues/236
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $expandLabModuleCacheParams = @{
                Module = $testModuleInfo;
                DestinationPath = $testDestinationPath;
            }
            $result = Expand-LabModuleCache @expandLabModuleCacheParams;

            $result -is [System.IO.DirectoryInfo] | Should Be $true;
        }

        It 'Cleans existing module directory when "Clean" is specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock Remove-Item;

            $expandLabModuleCacheParams = @{
                Module = @{ Name = $testModuleName; }
                DestinationPath = $testDestinationPath;
                Clean = $true;
            }
            $null = Expand-LabModuleCache @expandLabModuleCacheParams;

            Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq $testModuleDestinationPath } -Scope It;
        }

        It 'Calls "Expand-ZipArchive" when "PSGallery" Provider is specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $expandLabModuleCacheParams = @{
                Module = @{ Name = $testModuleName; Provider = 'PSGallery'; }
                DestinationPath = $testDestinationPath;
            }
            $null = Expand-LabModuleCache @expandLabModuleCacheParams;

            Assert-MockCalled Expand-ZipArchive -Scope It;
        }

        It 'Calls "Expand-GitHubZipArchive" when "GitHub" Provider is specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $expandLabModuleCacheParams = @{
                Module = @{ Name = $testModuleName; Provider = 'GitHub'; }
                DestinationPath = $testDestinationPath;
            }
            $null = Expand-LabModuleCache @expandLabModuleCacheParams;

            Assert-MockCalled Expand-GitHubZipArchive -Scope It;
        }

        It 'Calls "Expand-GitHubZipArchive" when "GitHub" Provider and "OverrideRepository" are specified' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testOverrideRepository = 'Override';
            $expandLabModuleCacheParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'GitHub';
                    OverrideRepository = $testOverrideRepository;
                }
                DestinationPath = $testDestinationPath;
            }
            $null = Expand-LabModuleCache @expandLabModuleCacheParams;

            Assert-MockCalled Expand-GitHubZipArchive -ParameterFilter { $OverrideRepository -eq $testOverrideRepository } -Scope It;
        }

        It 'Calls "Expand-ZipArchive" when "FileSystem" Provider is specified and "Path" is a .zip file' {
            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $expandLabModuleCacheParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                    Path = $testModuleSourceFilePath;
                }
                DestinationPath = $testDestinationPath;
            }
            $null = Expand-LabModuleCache @expandLabModuleCacheParams;

            Assert-MockCalled Expand-ZipArchive -Scope It;
        }

        It 'Calls "Copy-Item" when "FileSystem" Provider is specified and "Path" is a directory' {

            New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            New-Item -Path $testModuleSourceFolderPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            Mock Get-LabModuleCache -MockWith { return (Get-Item -Path $testModuleSourceFolderPath) }
            Mock Copy-Item {  };

            $expandLabModuleCacheParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                    Path = $testModuleSourceFolderPath;
                }
                DestinationPath = $testDestinationPath;
            }
            $null = Expand-LabModuleCache @expandLabModuleCacheParams;

            Assert-MockCalled Copy-Item -ParameterFilter { $Destination -eq $testModuleDestinationPath } -Scope It;
        }

    } #end InModuleScope

} #end Describe
