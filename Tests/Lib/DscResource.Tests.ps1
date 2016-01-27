#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'DscResource' {
    
    InModuleScope $moduleName {

        Context 'Validates "ImportDscResource" method' {

            It 'Does not import module if command is already imported' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                $testPrefixedCommandName = "Test-$($testResourceName)TargetResource";
                Mock Get-Command -ParameterFilter { $Name -eq $testPrefixedCommandName } -MockWith { return $true; }

                ImportDscResource -ModuleName $testModuleName -ResourceName $testResourceName;

                Assert-MockCalled Get-Command -ParameterFilter { $Name -eq $testPrefixedCommandName } -Scope It;
            }

            It 'Does not call "GetDscModule" if "UseDefault" is not specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                Mock Import-Module -MockWith { };
                Mock Get-Command -MockWith { };
                Mock GetDscModule -MockWith { }

                ImportDscResource -ModuleName $testModuleName -ResourceName $testResourceName;

                Assert-MockCalled GetDscModule -Scope It -Exactly 0;
            }

            It 'Calls "GetDscModule" if "UseDefault" is specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                Mock Import-Module -MockWith { };
                Mock Get-Command -MockWith { };
                Mock GetDscModule -ParameterFilter { $ModuleName -eq $testModuleName -and $ResourceName -eq $testResourceName } -MockWith { return $env:TEMP; }

                ImportDscResource -ModuleName $testModuleName -ResourceName $testResourceName -UseDefault;

                Assert-MockCalled GetDscModule -ParameterFilter { $ModuleName -eq $testModuleName -and $ResourceName -eq $testResourceName } -Scope It;
            }
            
        } #end context Validates "ImportDscResource" method

        Context 'Validates "GetDscResource" method' {
            
            It 'Calls "Get-<ResourceName>TargetResource" method' {
                $testResourceName = 'TestLabResource';
                ## Cannot dynamically generate function names :|
                $getPrefixedCommandName = "Get-TestLabResourceTargetResource";
                function Get-TestLabResourceTargetResource { }
                Mock $getPrefixedCommandName -MockWith { }

                GetDscResource -ResourceName $testResourceName -Parameters @{};

                Assert-MockCalled $getPrefixedCommandName -Scope It;
            }

        } #end context Validates "GetDscResource" method

        Context 'Validates "TestDscResource" method' {
            
            It 'Calls "Test-<ResourceName>TargetResource" method' {
                $testResourceName = 'TestLabResource';
                ## Cannot dynamically generate function names :|
                $testPrefixedCommandName = 'Test-TestLabResourceTargetResource';
                function Test-TestLabResourceTargetResource { }
                Mock $testPrefixedCommandName -MockWith { }

                TestDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 };

                Assert-MockCalled $testPrefixedCommandName -Scope It;
            }

        } #end context Validates "TestDscResource" method

        Context 'Validates "SetDscResource" method' {
            
            It 'Calls "Set-<ResourceName>TargetResource" method' {
                $testResourceName = 'TestLabResource';
                ## Cannot dynamically generate function names :|
                $setPrefixedCommandName = 'Set-TestLabResourceTargetResource';
                function Set-TestLabResourceTargetResource { }
                Mock $setPrefixedCommandName -MockWith { }

                SetDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 };

                Assert-MockCalled $setPrefixedCommandName -Scope It;
            }

        } #end context Validates "SetDscResource" method

        Context 'Validates "InvokeDscResource" method' {

            It 'Does not call "Set-<ResourceName>TargetResource" if "TestDscResource" passes' {
                $testResourceName = 'TestLabResource';

                Mock TestDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $true; }
                Mock SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { }

                InvokeDscResource -ResourceName $testResourceName -Parameters @{};

                Assert-MockCalled SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -Scope It -Exactly 0;
            }

            It 'Does call "Set-<ResourceName>TargetResource" if "TestDscResource" fails' {
                $testResourceName = 'TestLabResource';

                Mock TestDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $false; }
                Mock SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { }

                InvokeDscResource -ResourceName $testResourceName -Parameters @{};

                Assert-MockCalled SetDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -Scope It;
            }

            It 'Throws when "TestDscResource" fails and "ResourceName" matches "PendingReboot"' {
                $testResourceName = 'TestLabResourcePendingReboot';
                Mock TestDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $false; }

                { InvokeDscResource -ResourceName $testResourceName -Parameters @{} } | Should Throw;
            }

        } #end context Validates "InvokeDscResource" method
        
        Context 'Validates "GetDscResourcePSGalleryUri" method' {
            
            $testDscResourceName = 'TestPackage';
            $testMinimumVersion = '1.2.3';
            $testRequiredVersion = '3.2.1';
            $testExplicitUri = 'http://testuri.com';
            
            It 'Returns Uri when specified' {
                $result = GetDscResourcePSGalleryUri -Name $testDscResourceName -MinimumVersion $testMinimumVersion -Uri $testExplicitUri;
                
                $result | Should Be $testExplicitUri;
            }
            
            It 'Returns latest package Uri when "RequiredVersion" is not specified' {
                $result = GetDscResourcePSGalleryUri -Name $testDscResourceName;
                
                $result.EndsWith($testRequiredVersion) | Should Be $false;
                $result.EndsWith($testMinimumVersion) | Should Be $false;
            }
            
            It 'Returns "RequiredVersion" when "MinimumVersion" and "RequiredVersion" are specified' {
                $result = GetDscResourcePSGalleryUri -Name $testDscResourceName -MinimumVersion $testMinimumVersion -RequiredVersion $testRequiredVersion;
                
                $result.EndsWith($testRequiredVersion) | Should Be $true;
            }
            
        } #end context Validates "GetDscResourcePSGalleryUri" method
        
        Context 'Validates "InvokeDscResourceDownload" method' {
            
            $testModuleName = 'ExistingModule';
            $testModuleManifest = New-Item -Path "TestDrive:\$testModuleName.psd1" -ItemType File -Force;
            $testPSGalleryResource = @{ Name = $testModuleName; }
            $testGitHubResource = @{ Name = $testModuleName; Provider = 'GitHub'; Owner = 'TestOwner'; }
            
            Mock InvokeDscResourceDownloadFromGitHub { }
            Mock InvokeDscResourceDownloadFromPSGallery { }
            Mock GetModule -ParameterFilter { $Name -eq $testModuleName } -MockWith { return @{ Path = $testModuleManifest.FullName; }; }
            
            It 'Returns "System.IO.DirectoryInfo" object type' {
                Mock TestModule { return $true; }
                
                $result = InvokeDscResourceDownload -DSCResource $testPSGalleryResource;
                
                $result -is [System.IO.DirectoryInfo] | Should Be $true;
            }
            
            It 'Does not call "InvokeDscResourceDownloadFromPSGallery" when PSGallery module exists' {
                Mock TestModule { return $true; }
                
                $result = InvokeDscResourceDownload -DSCResource $testPSGalleryResource;
                
                Assert-MockCalled InvokeDscResourceDownloadFromPSGallery -Exactly 0 -Scope It;
            }
            
            It 'Calls "InvokeDscResourceDownloadFromPSGallery" when PSGallery module exists and "Force" is specified' {
                Mock TestModule { return $true; }
                
                $result = InvokeDscResourceDownload -DSCResource $testPSGalleryResource -Force;
                
                Assert-MockCalled InvokeDscResourceDownloadFromPSGallery -Scope It;
            }
            
            It 'Calls "InvokeDscResourceDownloadFromPSGallery" when PSGallery module does not exist' {
                Mock TestModule { return $false; }
                
                $result = InvokeDscResourceDownload -DSCResource $testPSGalleryResource;
                
                Assert-MockCalled InvokeDscResourceDownloadFromPSGallery -Scope It;
            }
            
            It 'Does not call "InvokeDscResourceDownloadFromGitHub" when GitHub module exists' {
                Mock TestModule { return $true; }
                
                $result = InvokeDscResourceDownload -DSCResource $testGitHubResource;
                
                Assert-MockCalled InvokeDscResourceDownloadFromGitHub -Exactly 0 -Scope It;
            }
            
            It 'Calls "InvokeDscResourceDownloadFromGitHub" when GitHub module exists and "Force" is specified' {
                Mock TestModule { return $true; }
                
                $result = InvokeDscResourceDownload -DSCResource $testGitHubResource -Force;
                
                Assert-MockCalled InvokeDscResourceDownloadFromGitHub -Scope It;
            }
            
            It 'Calls "InvokeDscResourceDownloadFromGitHub" when GitHub module does not exist' {
                Mock TestModule { return $false; }
                
                $result = InvokeDscResourceDownload -DSCResource $testGitHubResource;
                
                Assert-MockCalled InvokeDscResourceDownloadFromGitHub -Scope It;
            }
            
        } #end context Validates "InvokeDscResourceDownload" method
        
        Context 'Validates "InvokeDscResourceDownloadFromPSGallery" method' {
            
            $testModuleName = 'TestModule';
            $testTemporaryFile = New-Item -Path "TestDrive:\$testModuleName.zip" -ItemType File -Force;
            $windowsPowerShellModules = Join-Path -Path $env:ProgramFiles -ChildPath '\WindowsPowerShell\Modules';
            
            Mock SetResourceDownload { return $testTemporaryFile; }
            Mock ExpandZipArchive -ParameterFilter { $Path -eq $testTemporaryFile } -MockWith { }
            Mock Join-Path -ParameterFilter { $Path -eq $windowsPowerShellModules } { return 'TestDrive:\'}
            
            It 'Returns "System.IO.DirectoryInfo" object type' {
                $result = InvokeDscResourceDownloadFromPSGallery -Name $testModuleName;
                
                $result -is [System.IO.DirectoryInfo] | Should Be $true;
            }
            
            It 'Calls "SetResourceDownload" to download module' {
                $result = InvokeDscResourceDownloadFromPSGallery -Name $testModuleName;
                
                Assert-MockCalled SetResourceDownload -Scope It;
            }
            
            It 'Calls "ExpandZipArchive" to extract module' {
                $result = InvokeDscResourceDownloadFromPSGallery -Name $testModuleName;
                
                Assert-MockCalled ExpandZipArchive -ParameterFilter { $Path -eq $testTemporaryFile } -Scope It;
            }
            
            It 'Calls "ExpandZipArchive" with "Force" when specified' {
                Mock ExpandZipArchive -ParameterFilter { $Force -eq $true } -MockWith { }
                $result = InvokeDscResourceDownloadFromPSGallery -Name $testModuleName -Force;
                
                Assert-MockCalled ExpandZipArchive -ParameterFilter { $Force -eq $true } -Scope It;
            }
        
        } #end context Validates "InvokeDscResourceDownloadFromPSGallery" method
        
        Context 'Validates "InvokeDscResourceDownloadFromGitHub" method' {
            $gitHubRepositoryModuleName = 'GitHubRepository';
            $testModuleName = 'TestModule';
            $testModuleOwner = 'TestOwner';
            
            function Install-GitHubRepository { param ( $Force )}
            
            Mock Import-Module -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } -MockWith { }
            Mock InvokeDscResourceDownloadFromPSGallery -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } -MockWith { }
            Mock Install-GitHubRepository { return Get-Item -Path 'TestDrive:\'; }
            
            It 'Calls "InvokeDscResourceDownloadFromPSGallery" when GitHubRepository module is not found' {
                Mock TestModule -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } { return $false; }
                
                $result = InvokeDscResourceDownloadFromGitHub -Name $testModuleName -Owner $testModuleOwner;
                
                Assert-MockCalled InvokeDscResourceDownloadFromPSGallery -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } -Scope It;
            }
            
            It 'Imports "GitHubRepository" module ' {
                Mock TestModule -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } { return $true; }
                
                $result = InvokeDscResourceDownloadFromGitHub -Name $testModuleName -Owner $testModuleOwner;
                
                Assert-MockCalled Import-Module -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } -Scope It;
            }
            
            It 'Calls "Install-GitHubRepository"' {
                Mock TestModule -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } { return $true; }
                
                $result = InvokeDscResourceDownloadFromGitHub -Name $testModuleName -Owner $testModuleOwner;
                
                Assert-MockCalled Install-GitHubRepository -Scope It;
            }
            
            It 'Calls "Install-GitHubRepository" with "Force" when specified' {
                Mock TestModule -ParameterFilter { $Name -eq $gitHubRepositoryModuleName } { return $true; }
                Mock Install-GitHubRepository -ParameterFilter { $Force -eq $true } { return Get-Item -Path 'TestDrive:\'; }
                
                $result = InvokeDscResourceDownloadFromGitHub -Name $testModuleName -Owner $testModuleOwner -Force;
                
                Assert-MockCalled Install-GitHubRepository -ParameterFilter { $Force -eq $true } -Scope It;
            }
            
        } #end context Validates "InvokeDscResourceDownloadFromGitHub" method

    } #end InModuleScope

} #end describe DscResource
