#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Lib\Module' {

    InModuleScope $moduleName {

        Context 'Validates "ResolveModule" method' {

            $testConfigurationData = @{
                NonNodeData = @{
                    Lability = @{
                        DscResource = @(
                            @{ Name = 'TestDscResource1'; }
                            @{ Name = 'TestDscResource2'; }
                        )
                        Module = @(
                            @{ Name = 'TestModule1'; }
                            @{ Name = 'TestModule2'; }
                            @{ Name = 'TestModule3'; }
                        )
                    }
                }
            }

            It 'Returns all PowerShell modules if no "Name" is specified' {
                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    ModuleType = 'Module';
                }

                $result = ResolveModule @testParams;

                $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.Module.Count;
            }

            It 'Returns all PowerShell modules if "*" is specified' {
                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    ModuleType = 'Module';
                    Name  = '*';
                }

                $result = ResolveModule @testParams;

                $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.Module.Count;
            }

            It 'Returns all DSC resources if no "Name" is specified' {
                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    ModuleType = 'DscResource';
                }

                $result = ResolveModule @testParams;

                $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.DscResource.Count;
            }

            It 'Returns all DSC resources if "*" is specified' {
                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    ModuleType = 'DscResource';
                    Name  = '*';
                }

                $result = ResolveModule @testParams;

                $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.DscResource.Count;
            }

            It 'Returns matching PowerShell modules when "Name" is specified' {
                $testModules = 'TestModule2','TestModule1';
                $testParams = @{
                    Name  = $testModules;
                    ModuleType = 'Module';
                    ConfigurationData = @{
                        NonNodeData = @{
                            Lability = @{
                                Module = @(
                                    @{ Name = 'TestModule1'; }
                                    @{ Name = 'TestModule2'; }
                                    @{ Name = 'TestModule3'; }
                                )
                            }
                        }
                    }
                }

                $result = ResolveModule @testParams;

                $result.Count | Should Be $testModules.Count;
            }

            It 'Returns matching DSC resources when "Name" is specified' {
                $testDscResources = 'TestDscResource3';
                $testParams = @{
                    Name  = $testDscResources;
                    ModuleType = 'DscResource';
                    ConfigurationData = @{
                        NonNodeData = @{
                            Lability = @{
                                DscResource = @(
                                    @{ Name = 'TestDscResource1'; }
                                    @{ Name = 'TestDscResource2'; }
                                    @{ Name = 'TestDscResource3'; }
                                )
                            }
                        }
                    }
                }

                $result = ResolveModule @testParams;

                $result.Count | Should Be $testDscResources.Count;
            }

            It 'Warns if a PowerShell module cannot be resolved' {
                $testParams = @{
                    Name  = 'TestModule4';
                    ModuleType = 'Module';
                    ConfigurationData = @{
                        NonNodeData = @{
                            Lability = @{
                                DscResource = @(
                                    @{ Name = 'TestModule1'; }
                                    @{ Name = 'TestModule2'; }
                                    @{ Name = 'TestModule3'; }
                                )
                            }
                        }
                    }
                }

                { ResolveModule @testParams -WarningAction Stop 3>&1 } | Should Throw;
            }

            It 'Warns if a DSC resource cannot be resolved' {
                $testParams = @{
                    Name  = 'TestDscResource4';
                    ModuleType = 'DscResource';
                    ConfigurationData = @{
                        NonNodeData = @{
                            Lability = @{
                                DscResource = @(
                                    @{ Name = 'TestDscResource1'; }
                                    @{ Name = 'TestDscResource2'; }
                                    @{ Name = 'TestDscResource3'; }
                                )
                            }
                        }
                    }
                }

                { ResolveModule @testParams -WarningAction Stop 3>&1 } | Should Throw;
            }

            It 'Throws if a PowerShell module cannot be resolved and "ThrowIfNotFound" is specified' {
                $testParams = @{
                    Name  = 'TestModule4';
                    ModuleType = 'Module';
                    ThrowIfNotFound = $true;
                    ConfigurationData = @{
                        NonNodeData = @{
                            Lability = @{ }
                        }
                    }
                }

                { ResolveModule @testParams } | Should Throw;
            }

            It 'Throws if a DSC resource cannot be resolved and "ThrowIfNotFound" is specified' {
                $testParams = @{
                    Name  = 'TestDscResource';
                    ModuleType = 'DscResource';
                    ThrowIfNotFound = $true;
                    ConfigurationData = @{
                        NonNodeData = @{
                            Lability = @{ }
                        }
                    }
                }

                { ResolveModule @testParams } | Should Throw;
            }

        } #end context Validates "ResolveModule" method

        Context 'Validates "TestModuleCache" method' {

            $testModuleName = 'TestModule';
            $testPSGalleryModule = @{
                Name = $testModuleName; Version = '1.2.3.4';
            }

            It 'Passes when module is found' {
                Mock Get-LabModuleCache -MockWith { return $testPSGalleryModule; }
                $testParams = @{
                    Name = $testModuleName;
                }

                $result = TestModuleCache @testParams;

                $result | Should Be $true;
            }

            It 'Fails when module is not found' {
                Mock Get-LabModuleCache -MockWith { }
                $testParams = @{
                    Name = $testModuleName;
                }

                $result = TestModuleCache @testParams;

                $result | Should Be $false;
            }

        } #end context Validates "TestModuleCache" method

        Context 'Validates "RenameModuleCacheVersion" method' {

            $testModuleName = 'TestModule';
            $testModuleDirectoryPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
            $testModulePath = '{0}\{1}.zip' -f $testModuleDirectoryPath, $testModuleName;
            $testModuleVersion = '1.2.3.4';
            $testModuleManifest = [PSCustomObject] @{
                ModuleVersion = $testModuleVersion;
            }
            Mock GetModuleCacheManifest -MockWith { return $testModuleManifest; }

            BeforeEach {
                New-Item -Path $testModuleDirectoryPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            }

            It 'Returns a [System.IO.FileInfo] object type' {
                $testParams = @{
                    Name = $testModuleName;
                    Path = $testModulePath;
                }

                $result = RenameModuleCacheVersion @testParams;

                $result -is [System.IO.FileInfo] | Should Be $true;
            }

            It 'Renames PSGallery module to "<ModuleName>-v<Version>.zip' {
                $testParams = @{
                    Name = $testModuleName;
                    Path = $testModulePath;
                }

                $result = RenameModuleCacheVersion @testParams -Verbose;

                $expectedPath = '{0}\{1}-v{2}.zip' -f $testModuleDirectoryPath, $testModuleName, $testModuleVersion;
                Test-Path -Path $expectedPath | Should Be $true;
            }

            It 'Renames GitHub module to "<ModuleName>-v<Version>_<Owner>_<Branch>.zip' {
                $testOwner = 'TestOwner';
                $testBranch = 'development';
                $testParams = @{
                    Name = $testModuleName;
                    Path = $testModulePath;
                    Owner = $testOwner;
                    Branch = $testBranch;
                }

                $result = RenameModuleCacheVersion @testParams -Verbose;

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

                $result = RenameModuleCacheVersion @testParams -Verbose;

                Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq $expectedPath } -Scope It;
            }

        } #end context Validates "RenameModuleCacheVersion" method

        Context 'Validates "InvokeModuleDownloadFromPSGallery" method' {

            $testModuleName = 'TestModule';
            $testDestinationPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
            $testModulePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;

            $testModuleManifest = [PSCustomObject] @{
                ModuleVersion = $testModuleVersion;
            }
            Mock GetModuleCacheManifest -MockWith { return $testModuleManifest; }
            Mock ResolvePSGalleryModuleUri -MockWith { return 'http://fake.uri' }
            Mock SetResourceDownload -MockWith { return $testModulePath }

            BeforeEach {
                New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            }

            It 'Returns a [System.IO.FileInfo] object type' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    RequiredVersion = '1.2.3.4';
                }
                $result = InvokeModuleDownloadFromPSGallery @testParams;

                $result -is [System.IO.FileInfo] | Should Be $true;
            }

            It 'Calls "ResolvePSGalleryModuleUri" with "RequiredVersion" when specified' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    RequiredVersion = '1.2.3.4';
                }
                InvokeModuleDownloadFromPSGallery @testParams;

                Assert-MockCalled ResolvePSGalleryModuleUri -ParameterFilter { $null -ne $RequiredVersion } -Scope It;
            }

            It 'Calls "ResolvePSGalleryModuleUri" with "MinimumVersion" when specified' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    MinimumVersion = '1.2.3.4';
                }
                InvokeModuleDownloadFromPSGallery @testParams;

                Assert-MockCalled ResolvePSGalleryModuleUri -ParameterFilter { $null -ne $MinimumVersion } -Scope It;
            }

        } #end context Validates "InvokeModuleDownloadFromPSGallery" method

        Context 'Validates "InvokeModuleDownloadFromGitHub" method' {

            $testModuleName = 'TestModule';
            $testOwner = 'TestOwnder';
            $testBranch = 'TestBranch';
            $testDestinationPath = '{0}\Modules' -f (Get-PSDrive -Name TestDrive).Root;
            $testModulePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;

            $testModuleManifest = [PSCustomObject] @{
                ModuleVersion = $testModuleVersion;
            }
            Mock GetModuleCacheManifest -MockWith { return $testModuleManifest; }
            Mock ResolveGitHubModuleUri -MockWith { return 'http://fake.uri' }
            Mock SetResourceDownload -MockWith { return $testModulePath }

            BeforeEach {
                New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            }

            It 'Returns a [System.IO.FileInfo] object type' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    Owner = $testOwner;
                    Branch = $testBranch;
                }
                $result = InvokeModuleDownloadFromGitHub @testParams;

                $result -is [System.IO.FileInfo] | Should Be $true;
            }

            It 'Calls "ResolveGitHubModuleUri" with "Owner" and "Branch"' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    Owner = $testOwner;
                    Branch = $testBranch;
                }
                InvokeModuleDownloadFromGitHub @testParams;

                Assert-MockCalled ResolveGitHubModuleUri -ParameterFilter { $Owner -eq $testOwner } -Scope It;
                Assert-MockCalled ResolveGitHubModuleUri -ParameterFilter { $Branch -eq $testBranch } -Scope It;
            }

            It 'Calls "ResolveGitHubModuleUri" with "OverrideRepositoryName" when specified' {
                $testRepositoryOverrideName = 'Override';
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    Owner = $testOwner;
                    Branch = $testBranch;
                    OverrideRepositoryName = $testRepositoryOverrideName
                }
                InvokeModuleDownloadFromGitHub @testParams;

                Assert-MockCalled ResolveGitHubModuleUri -ParameterFilter { $OverrideRepositoryName -ne $testRepositoryOverrideName } -Scope It;
            }

            It 'Throws when "Owner" is not specified' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    Branch = $testBranch;
                }
                { InvokeModuleDownloadFromGitHub @testParams } | Should Throw;
            }

            It 'Warns when no "Branch" is specified' {
                $testParams = @{
                    Name = $testModuleName;
                    DestinationPath = $testDestinationPath;
                    Owner = $testOwner;
                }
                { InvokeModuleDownloadFromGitHub @testParams -WarningAction Stop 3>&1 } | Should Throw;
            }

        } #end context Validates "InvokeModuleDownloadFromGitHub" method

        Context 'Validates "InvokeModuleCacheDownload" method' {

            $testModuleName = 'TestModule';
            $testRequiredVersion = '0.1.2';
            $testParams = @{
                Name = $testModuleName;
                RequiredVersion = $testRequiredVersion;
            }
            Mock InvokeModuleDownloadFromPSGallery;
            Mock InvokeModuleDownloadFromGitHub;

            It 'Downloads module from PSGallery when no Provider is specified' {
                Mock TestModuleCache -MockWith { return $false; }

                InvokeModuleCacheDownload @testParams;

                Assert-MockCalled InvokeModuleDownloadFromPSGallery -Scope It;
            }

            It 'Downloads module from GitHub by ModuleInfo' {
                Mock TestModuleCache -MockWith { return $false; }

                $moduleInfo = @{
                    Name = $testModuleName;
                    Provider = 'GitHub';
                    RequiredVersion = $testRequiredVersion;
                    Owner = 'TestOwner';
                    Branch = 'TestBranch';
                    Path = 'TestPath';
                }
                InvokeModuleCacheDownload -Module $moduleInfo;

                Assert-MockCalled InvokeModuleDownloadFromGitHub -Scope It;
            }

            It 'Downloads module from PSGallery when "PSGallery" Provider is specified' {
                Mock TestModuleCache -MockWith { return $false; }

                InvokeModuleCacheDownload @testParams -Provider 'PSGallery';

                Assert-MockCalled InvokeModuleDownloadFromPSGallery -Scope It;
            }

            It 'Downloads module from GitHub when "GitHub" Provider is specified' {
                Mock TestModuleCache -MockWith { return $false; }

                InvokeModuleCacheDownload @testParams -Provider 'GitHub';

                Assert-MockCalled InvokeModuleDownloadFromGitHub -Scope It;
            }

            It 'Does not download module when "FileSystem" Provider is specified' {
                Mock TestModuleCache -MockWith { return $false; }

                InvokeModuleCacheDownload @testParams -Provider 'FileSystem';

                Assert-MockCalled InvokeModuleDownloadFromPSGallery -Scope It -Exactly 0;
                Assert-MockCalled InvokeModuleDownloadFromGitHub -Scope It -Exactly 0;
            }

            It 'Does not download module when resource is cached' {
                Mock TestModuleCache -MockWith { return $true; }

                InvokeModuleCacheDownload @testParams;

                Assert-MockCalled InvokeModuleDownloadFromPSGallery -Scope It -Exactly 0;
                Assert-MockCalled InvokeModuleDownloadFromGitHub -Scope It -Exactly 0;
            }

        } #end context Validates "InvokeModuleCacheDownload" method

        Context 'Validates "ExpandModuleCache" method' {

            $testModuleName = 'TestModule';
            $testRequiredVersion = '0.1.2';
            $testDestinationPath = (Get-PSDrive -Name TestDrive).Root
            $testModuleSourceFilePath = '{0}\{1}.zip' -f $testDestinationPath, $testModuleName;
            $testModuleSourceFolderPath = '{0}\Source{1}' -f $testDestinationPath, $testModuleName;
            $testModuleDestinationPath = '{0}\{1}' -f $testDestinationPath, $testModuleName;

            $testModuleInfo = @{ Name = $testModuleName; }

            BeforeEach {
                New-Item -Path $testDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
                New-Item -Path $testModuleSourceFilePath -ItemType File -Force -ErrorAction SilentlyContinue;
            }
            Mock ExpandZipArchive -MockWith { New-Item -Path $testModuleDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue; }
            Mock ExpandGitHubZipArchive -MockWith { New-Item -Path $testModuleDestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue; }
            Mock Get-LabModuleCache -MockWith { return (Get-Item -Path $testModuleSourceFilePath) }

            It 'Returns a [System.IO.DirectoryInfo] object type' {

                $testParams = @{
                    Module = $testModuleInfo;
                    DestinationPath = $testDestinationPath;
                }
                $result = ExpandModuleCache @testParams;

                $result -is [System.IO.DirectoryInfo] | Should Be $true;
            }

            It 'Cleans existing module directory when "Clean" is specified' {
                Mock Remove-Item;

                $testParams = @{
                    Module = @{ Name = $testModuleName; }
                    DestinationPath = $testDestinationPath;
                    Clean = $true;
                }
                $result = ExpandModuleCache @testParams;

                Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq $testModuleDestinationPath } -Scope It;
            }

            It 'Calls "ExpandZipArchive" when "PSGallery" Provider is specified' {
                $testParams = @{
                    Module = @{ Name = $testModuleName; Provider = 'PSGallery'; }
                    DestinationPath = $testDestinationPath;
                }
                $result = ExpandModuleCache @testParams;

                Assert-MockCalled ExpandZipArchive -Scope It;
            }

            It 'Calls "ExpandGitHubZipArchive" when "GitHub" Provider is specified' {
                $testParams = @{
                    Module = @{ Name = $testModuleName; Provider = 'GitHub'; }
                    DestinationPath = $testDestinationPath;
                }
                $result = ExpandModuleCache @testParams;

                Assert-MockCalled ExpandGitHubZipArchive -Scope It;
            }

            It 'Calls "ExpandGitHubZipArchive" when "GitHub" Provider and "OverrideRepository" are specified' {
                $testOverrideRepository = 'Override';
                $testParams = @{
                    Module = @{
                        Name = $testModuleName;
                        Provider = 'GitHub';
                        OverrideRepository = $testOverrideRepository;
                    }
                    DestinationPath = $testDestinationPath;
                }
                $result = ExpandModuleCache @testParams;

                Assert-MockCalled ExpandGitHubZipArchive -ParameterFilter { $OverrideRepository -eq $testOverrideRepository } -Scope It;
            }

            It 'Calls "ExpandZipArchive" when "FileSystem" Provider is specified and "Path" is a .zip file' {
                $testParams = @{
                    Module = @{
                        Name = $testModuleName;
                        Provider = 'FileSystem';
                        Path = $testModuleSourceFilePath;
                    }
                    DestinationPath = $testDestinationPath;
                }
                $result = ExpandModuleCache @testParams;

                Assert-MockCalled ExpandZipArchive -Scope It;
            }

            It 'Calls "Copy-Item" when "FileSystem" Provider is specified and "Path" is a directory' {

                ## Create the source module folder
                New-Item -Path $testModuleSourceFolderPath -ItemType Directory -Force -ErrorAction SilentlyContinue;
                Mock Get-LabModuleCache -MockWith { return (Get-Item -Path $testModuleSourceFolderPath) }
                Mock Copy-Item {  };

                $testParams = @{
                    Module = @{
                        Name = $testModuleName;
                        Provider = 'FileSystem';
                        Path = $testModuleSourceFolderPath;
                    }
                    DestinationPath = $testDestinationPath;
                }
                $result = ExpandModuleCache @testParams;

                Assert-MockCalled Copy-Item -ParameterFilter { $Destination -eq $testModuleDestinationPath } -Scope It;
            }

        } #end context Validates "ExpandModuleCache" method

    } #end in module scope

} #end describe Lib\Module
