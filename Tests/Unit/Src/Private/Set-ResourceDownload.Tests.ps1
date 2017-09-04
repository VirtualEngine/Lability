#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-ResourceDownload' {

    InModuleScope -ModuleName $moduleName {

        $testResourcePath = 'TestDrive:\TestResource.txt';
        $testResourceContent = 'MyResourceFileContent';

        It 'Calls "Invoke-WebClientDownload" with specified Uri' {
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Invoke-WebClientDownload -ParameterFilter { $Uri -eq $testResourceUri } -MockWith { }

            Set-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

            Assert-MockCalled Invoke-WebClientDownload -ParameterFilter { $Uri -eq $testResourceUri } -Scope It;
        }

        It 'Calls "Invoke-WebClientDownload" with specified destination Path' {
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Invoke-WebClientDownload -ParameterFilter { $DestinationPath -eq $testResourcePath } -MockWith { }

            Set-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

            Assert-MockCalled Invoke-WebClientDownload -ParameterFilter { $DestinationPath -eq $testResourcePath }  -Scope It;
        }

        It 'Calls "Invoke-WebClientDownload" with default 64KB buffer size' {
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt'
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Invoke-WebClientDownload -ParameterFilter { $BufferSize -eq 64KB } -MockWith { }

            Set-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

            Assert-MockCalled Invoke-WebClientDownload -ParameterFilter { $BufferSize -eq 64KB } -Scope It;
        }

        It 'Calls "Invoke-WebClientDownload" with 1MB buffer size for file resource' {
            $testResourceUri = ("file:///$testResourcePath").Replace('\','/');
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Invoke-WebClientDownload -ParameterFilter { $BufferSize -eq 1MB } -MockWith { }

            Set-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

            Assert-MockCalled Invoke-WebClientDownload -ParameterFilter { $BufferSize -eq 1MB } -Scope It;
        }

        It 'Creates checksum file after download' {
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            $testResourceContent = 'MyResourceFileContent';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
            $testResourceChecksumPath = '{0}.checksum' -f $testResourcePath;
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Start-BitsTransfer -ParameterFilter { $Source -eq $testResourceUri } -MockWith { }

            Set-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri;

            (Get-Content -Path $testResourceChecksumPath) | Should Be $testResourceChecksum;
            Test-Path -Path $testResourceChecksumPath | Should Be $true;
        }

        It 'Creates target parent directory if it does not exist' {
            <# Must execute last in the Context block as once we mock Get-FileHash and Set-Content we're knackered! #>
            $testResourcePath = 'TestDrive:\TestDirectory\TestResource.txt';
            Mock Start-BitsTransfer -MockWith { }
            Mock Get-FileHash -MockWith { return [PSCustomObject] @{ Hash = 'FakeMD5Checksum' } }
            Mock Set-Content -MockWith { }

            Set-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank';

            Test-Path -Path 'TestDrive:\TestDirectory' -PathType Container | Should Be $true;
        }

    } #end InModuleScope

} #end describe
