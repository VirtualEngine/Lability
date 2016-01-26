#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Resource' {
    
    InModuleScope $moduleName {

        Context 'Validates "NewDirectory" method' {

            ## Need to resolve actual filesystem path for System.IO.DirectoryInfo calls
            $testDirectoryPath = "$((Get-PSdrive -Name TestDrive).Root)\NewDirectory";

            BeforeEach {
                Remove-Item -Path 'TestDrive:\NewDirectory' -Force -ErrorAction SilentlyContinue;
            }
        
	        It 'Returns a "System.IO.DirectoryInfo" object if target "Path" already exists' {
                $testDirectoryPath = "$env:SystemRoot";
                Test-Path -Path $testDirectoryPath | Should Be $true;
		        (NewDirectory -Path $testDirectoryPath) -is [System.IO.DirectoryInfo] | Should Be $true;
	        }

            It 'Returns a "System.IO.DirectoryInfo" object if target "Path" does not exist' {
                (NewDirectory -Path $testDirectoryPath) -is [System.IO.DirectoryInfo] | Should Be $true;
            }

            It 'Creates target "Path" if it does not exist' {
                Test-Path -Path $testDirectoryPath | Should Be $false;
                NewDirectory -Path $testDirectoryPath;
                Test-Path -Path $testDirectoryPath | Should Be $true;
            }

            It 'Returns a "System.IO.DirectoryInfo" object if target "DirectoryInfo" already exists' {
                $testDirectoryPath = "$env:SystemRoot";
                Test-Path -Path $testDirectoryPath | Should Be $true;
                $directoryInfo = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $testDirectoryPath;
		        ($directoryInfo | NewDirectory ) -is [System.IO.DirectoryInfo] | Should Be $true;
	        }

            It 'Returns a "System.IO.DirectoryInfo" object if target "DirectoryInfo" does not exist' {
                Test-Path -Path $testDirectoryPath | Should Be $false;
                NewDirectory -Path $testDirectoryPath;
                Test-Path -Path $testDirectoryPath | Should Be $true;
                (NewDirectory -Path $testDirectoryPath) -is [System.IO.DirectoryInfo] | Should Be $true;
            }

            It 'Creates target "DirectoryInfo" if it does not exist' {
                Test-Path -Path $testDirectoryPath | Should Be $false;
                $directoryInfo = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $testDirectoryPath;
                $directoryInfo | NewDirectory;
                Test-Path -Path $testDirectoryPath | Should Be $true;
            }

        } #end context Validates "NewDirectory" method

        Context 'Validates "GetResourceDownload" method' {

            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceChecksumPath = '{0}.checksum' -f $testResourcePath;
            $testResourceContent = 'MyResourceFileContent';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';

            It 'Returns "System.Collections.Hashtable" type' {
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Set-Content -Path $testResourceChecksumPath -Value $testResourceChecksum -Force;
                $resource = GetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;
                $resource -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Returns empty checksum if resource does not exist' {
                Remove-Item -Path $testResourcePath -Force -ErrorAction SilentlyContinue;
                Remove-Item -Path $testResourceChecksumPath -Force -ErrorAction SilentlyContinue;
                $resource = GetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;
                $resource.Checksum | Should BeNullOrEmpty;
            }

            It 'Returns correct checksum if resource and checksum files exist' {
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Set-Content -Path $testResourceChecksumPath -Value $testResourceChecksum -Force;
                $resource = GetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;
                $resource.Checksum | Should Be $testResourceChecksum;
            }

            It 'Returns correct checksum if resource exists but checksum does not exist' {
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Remove-Item -Path $testResourceChecksumPath -Force -ErrorAction SilentlyContinue;
                $resource = GetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;
                $resource.Checksum | Should Be $testResourceChecksum;
            }

            It 'Returns incorrect checksum if incorrect resource and checksum files exist' {
                Set-Content -Path $testResourcePath -Value "$testResourceContent-?" -Force;
                $fileHash = Get-FileHash -Path $testResourcePath -Algorithm MD5 | Select-Object -ExpandProperty Hash;
                $fileHash | Set-Content -Path $testResourceChecksumPath -Force;
                $resource = GetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;
                $resource.Checksum | Should Be $fileHash;
            }
            
            It 'Returns incorrect checksum if incorrect resource exists but checksum does not exist' {
                Set-Content -Path $testResourcePath -Value "$testResourceContent-?" -Force;
                Remove-Item -Path $testResourceChecksumPath -Force -ErrorAction SilentlyContinue;
                $resource = GetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;
                $resource.Checksum | Should Not Be $testResourceChecksum;
            }
            
        } #end context Validates "GetResourceDownload" method

        Context 'Validates "TestResourceDownload" method' {

            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceChecksumPath = '{0}.checksum' -f $testResourcePath;
            $testResourceContent = 'MyResourceFileContent';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';

            It 'Returns true if resource exists but no checksum was specified' {
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock GetResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; } }
                TestResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' | Should Be $true;
            }

            It 'Returns true if resource exists and checksum is correct' {
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock GetResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = $testResourceChecksum; } }
                TestResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum | Should Be $true;
            }

            It 'Returns false if resource does not exist' {
                Remove-Item -Path $testResourcePath -Force -ErrorAction SilentlyContinue;
                Mock GetResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = $testResourceChecksum; } }
                TestResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' | Should Be $false;
            }

            It 'Returns false if resource exists but checksum is incorrect' {
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock GetResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = 'ThisIsAnIncorrectChecksum'; } }
                TestResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum | Should Be $false;
            }

        } #end context Validates "TestResourceDownload" method

        Context 'Validates "SetResourceDownload" method' {
            
            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceContent = 'MyResourceFileContent';

            It 'Calls "InvokeWebClientDownload" with specified Uri' {
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock InvokeWebClientDownload -ParameterFilter { $Uri -eq $testResourceUri } -MockWith { }

                SetResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

                Assert-MockCalled InvokeWebClientDownload -ParameterFilter { $Uri -eq $testResourceUri } -Scope It;
            }
            
            It 'Calls "InvokeWebClientDownload" with specified destination Path' {
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock InvokeWebClientDownload -ParameterFilter { $DestinationPath -eq $testResourcePath } -MockWith { }

                SetResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

                Assert-MockCalled InvokeWebClientDownload -ParameterFilter { $DestinationPath -eq $testResourcePath }  -Scope It;
            }
            
            It 'Calls "InvokeWebClientDownload" with default 64KB buffer size' {
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt'
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock InvokeWebClientDownload -ParameterFilter { $BufferSize -eq 64KB } -MockWith { }

                SetResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

                Assert-MockCalled InvokeWebClientDownload -ParameterFilter { $BufferSize -eq 64KB } -Scope It;
            }
            
            It 'Calls "InvokeWebClientDownload" with 1MB buffer size for file resource' {
                $testResourceUri = ("file:///$testResourcePath").Replace('\','/');
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock InvokeWebClientDownload -ParameterFilter { $BufferSize -eq 1MB } -MockWith { }

                SetResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

                Assert-MockCalled InvokeWebClientDownload -ParameterFilter { $BufferSize -eq 1MB } -Scope It;
            }

            It 'Creates checksum file after download' {
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                $testResourceContent = 'MyResourceFileContent';
                $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
                $testResourceChecksumPath = '{0}.checksum' -f $testResourcePath;
                Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
                Mock Start-BitsTransfer -ParameterFilter { $Source -eq $testResourceUri } -MockWith { }

                SetResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;
                
                (Get-Content -Path $testResourceChecksumPath) | Should Be $testResourceChecksum;
                Test-Path -Path $testResourceChecksumPath | Should Be $true;
            }

            It 'Creates target parent directory if it does not exist' {
                <# Must execute last in the Context block as once we mock Get-FileHash and Set-Content we're knackered! #>
                $testResourcePath = 'TestDrive:\TestDirectory\TestResource.txt';
                Mock Start-BitsTransfer -MockWith { }
                Mock Get-FileHash -MockWith { return [PSCustomObject] @{ Hash = 'FakeMD5Checksum' } }
                Mock Set-Content -MockWith { }

                SetResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank';

                Test-Path -Path 'TestDrive:\TestDirectory' -PathType Container | Should Be $true;
            }

        } #end context Validates "SetResourceDownload" method

        Context 'Validates "InvokeResourceDownload" method' {

            It 'Returns a "System.Management.Automation.PSCustomObject" type' {
                $testResourcePath = 'TestDrive:\TestResource.txt';
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
                Mock TestResourceDownload -MockWith { return $true; }

                $resource = InvokeResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum;
                
                $resource -is [System.Management.Automation.PSCustomObject] | Should Be $true;
            }

            It 'Calls "SetResourceDownload" if "TestResourceDownload" fails' {
                $testResourcePath = 'TestDrive:\TestResource.txt';
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
                Mock TestResourceDownload -MockWith { return $false; }
                Mock SetResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -MockWith { }

                InvokeResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum;

                Assert-MockCalled SetResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -Scope It;
            }

            It 'Calls "SetResourceDownload" if "TestResourceDownload" passes but -Force was specified' {
                $testResourcePath = 'TestDrive:\TestResource.txt';
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
                Mock TestResourceDownload -MockWith { return $false; }
                Mock SetResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -MockWith { }

                InvokeResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum -Force;

                Assert-MockCalled SetResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -Scope It;
            }
            
            It 'Does not call "SetResourceDownload" if "TestResourceDownload" passes' {
                $testResourcePath = 'TestDrive:\TestResource.txt';
                $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
                $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
                Mock TestResourceDownload -MockWith { return $true; }
                Mock SetResourceDownload -MockWith { }

                InvokeResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum;

                Assert-MockCalled SetResourceDownload -Scope It -Exactly 0;
            }

        } #end context Validates "InvokeResourceDownload" method

    } #end InModuleScope

} #end describe Resource
