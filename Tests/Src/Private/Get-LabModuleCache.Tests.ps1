#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-LabModuleCache' {

    InModuleScope $moduleName {

        $testModuleName = 'TestModule';
        $testOwner = 'TestOwner';
        $testBranch = 'master';
        $psGalleryModuleV03 = @{ Name = "$testModuleName`-v0.3.0.zip"; FullName = "TestDrive:\$testModuleName`-v0.3.0.zip"; Version = '0.3.0'; }
        $psGalleryModuleV1 =  @{ Name = "$testModuleName`-v1.0.0.zip"; FullName = "TestDrive:\$testModuleName`-v1.0.0.zip"; Version = '1.0.0'; }
        $psGalleryModuleV11 = @{ Name = "$testModuleName`-v1.1.0.zip"; FullName = "TestDrive:\$testModuleName`-v1.1.0.zip"; Version = '1.1.0'; }
        $psGalleryModuleV2 =  @{ Name = "$testModuleName`-v2.0.0.zip"; FullName = "TestDrive:\$testModuleName`-v2.0.0.zip"; Version = '2.0.0'; }
        $gitHubModuleV031 = @{ Name = "$testModuleName`_$testOwner`_$testBranch.zip"; FullName = "TestDrive:\$testModuleName`_$testOwner_$testBranch.zip"; }
        $gitHubModuleV101 =  @{ Name = "$testModuleName`-v1.0.1_$testOwner`_$testBranch.zip"; FullName = "TestDrive:\$testModuleName`-v1.0.0_$testOwner_$testBranch.zip"; Version = '1.0.1'; }
        $gitHubModuleV111 = @{ Name = "$testModuleName`-v1.1.1_$testOwner`_$testBranch.zip"; FullName = "TestDrive:\$testModuleName`-v1.1.0_$testOwner_$testBranch.zip"; Version = '1.1.1'; }
        $gitHubModuleV201 =  @{ Name = "$testModuleName`-v2.0.1_$testOwner`_$testBranch.zip"; FullName = "TestDrive:\$testModuleName`-v2.0.0_$testOwner_$testBranch.zip"; Version = '2.0.1'; }
        $testPSGalleryModules = @($psGalleryModuleV1, $psGalleryModuleV11, $psGalleryModuleV2, $psGalleryModuleV03);
        $testGitHubModules = @($gitHubModuleV101, $gitHubModuleV111, $gitHubModuleV201, $gitHubModuleV031);

        It 'Returns only a single module' {

            Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Name = $testModuleName;
            }
            $result = @(Get-LabModuleCache @testParams);

            $result.Count | Should Be 1;
        }

        It 'Returns only a single module by "Module"' {

            Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'GitHub';
                    MinimumVersion = $gitHubModuleV101.Version;
                    RequiredVersion = $gitHubModuleV101.Version;
                    Owner = $testOwner;
                    Branch = $testBranch;
                }
            }
            $result = @(Get-LabModuleCache @testParams);

            $result.Count | Should Be 1;
        }



        It 'Returns the latest PSGallery module version by default' {

            Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Name = $testModuleName;
            }
            $result = Get-LabModuleCache @testParams;

            $result.Version | Should Be $psGalleryModuleV2.Version;
        }

        It 'Returns the latest GitHub module version by default' {

            Mock Get-ChildItem -MockWith { return $testGitHubModules }

            $testParams = @{
                Name = $testModuleName;
                Provider = 'GitHub';
                Owner = $testOwner;
            }
            $result = Get-LabModuleCache @testParams;

            $result.Version | Should Be $gitHubModuleV201.Version;
        }

        It 'Returns the latest PSGallery module version when "MinimumVersion" is specified' {

            Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Name = $testModuleName;
                MinimumVersion = $psGalleryModuleV11.Version;
            }
            $result = Get-LabModuleCache @testParams;

            $result.Version | Should Be $psGalleryModuleV2.Version;
        }

        It 'Returns the latest GitHub module version when "MinimumVersion" is specified' {

            Mock Get-ChildItem -MockWith { return $testGitHubModules }

            $testParams = @{
                Name = $testModuleName;
                Provider = 'GitHub';
                Owner = $testOwner;
                MinimumVersion = $gitHubModuleV111.Version;
            }
            $result = Get-LabModuleCache @testParams;

            $result.Version | Should Be $gitHubModuleV201.Version;
        }

        It 'Returns the exact PSGallery module version when "RequiredVersion" is specified' {

            Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Name = $testModuleName;
                RequiredVersion = $psGalleryModuleV11.Version;
            }
            $result = Get-LabModuleCache @testParams;

            $result.Version | Should Be $psGalleryModuleV11.Version;
        }

        It 'Returns the exact GitHub module version when "RequiredVersion" is specified' {

            Mock Get-ChildItem -MockWith { return $testGitHubModules }

            $testParams = @{
                Name = $testModuleName;
                Provider = 'GitHub';
                Owner = $testOwner;
                RequiredVersion = $gitHubModuleV111.Version;
            }
            $result = Get-LabModuleCache @testParams;

            $result.Version | Should Be $gitHubModuleV111.Version;
        }

        foreach ($version in 'MinimumVersion','RequiredVersion') {
            It "Does not return PSGallery module when ""$version"" is not cached" {

                Mock Get-ChildItem -MockWith { return $gitHubGalleryModules }

                $testParams = @{
                    Name = $testModuleName;
                    $version = $psGalleryModuleV2.Version;
                }
                $result = Get-LabModuleCache @testParams;

                $result | Should BeNullOrEmpty;
            }
        }

        foreach ($version in 'MinimumVersion','RequiredVersion') {
            It "Does not return GitHub module when ""$version"" is not cached" {
                Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

                $testParams = @{
                    Name = $testModuleName;
                    $version = $gitHubModuleV201.Version;
                }
                $result = Get-LabModuleCache @testParams;

                $result | Should BeNullOrEmpty;
            }
        }

        It 'Returns a FileSystem provider [System.IO.DirectoryInfo] object type' {
            $testModulePath = 'TestDrive:\{0}Directory' -f $testModuleName;
            New-Item -Path $testModulePath -ItemType Directory -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                    Path = $testModulePath;
                }
            }
            $result = Get-LabModuleCache @testParams;

            $result -is [System.IO.DirectoryInfo] | Should Be $true;
        }

        It 'Returns a FileSystem provider [System.IO.FileInfo] object type' {
            $testModulePath = 'TestDrive:\{0}.zip' -f $testModuleName;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                    Path = $testModulePath;
                }
            }
            $result = Get-LabModuleCache @testParams;

            $result -is [System.IO.FileInfo] | Should Be $true;
        }

        It 'Throws if module "Name" is not specified' {
            Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Module = @{
                    RequiredVersion = $gitHubModuleV101.Version;
                }
            }
            { Get-LabModuleCache @testParams } | Should Throw "Required module parameter 'Name' is invalid or missing";
        }

        It 'Throws if GitHub module "Owner" is not specified' {
            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'GitHub';
                }
            }

            { Get-LabModuleCache @testParams } | Should Throw 'Required module parameter 'Owner' is invalid or missing.';
        }

        It 'Throws if FileSystem module "Path" is not specified' {
            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                }
            }

            { Get-LabModuleCache @testParams } | Should Throw "Required module parameter 'Path' is invalid or missing";
        }

        It 'Throws if FileSystem module "Path" does not exist' {
            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                    Path = 'TestDrive:\MissingModule';
                }
            }

            { Get-LabModuleCache @testParams } | Should Throw "Module path 'TestDrive:\MissingModule' is invalid";
        }

        It 'Throws if FileSystem module "Path" is not a ".zip" file' {
            $testModulePath = 'TestDrive:\{0}.msi' -f $testModuleName;
            New-Item -Path $testModulePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    Provider = 'FileSystem';
                    Path = $testModulePath;
                }
            }

            { Get-LabModuleCache @testParams } | Should Throw "Module path '$testModulePath' is not a valid .zip archive.";
        }

        It 'Throws if unsupported hashtable key is used (#170)' {
                Mock Get-ChildItem -MockWith { return $testPSGalleryModules }

            $testParams = @{
                Module = @{
                    Name = $testModuleName;
                    MaximumVersion = $gitHubModuleV101.Version;
                }
            }
            { Get-LabModuleCache @testParams } | Should Throw "Module parameter 'MaximumVersion' is invalid";

        }

    } #end InModuleScope

} #end describe
