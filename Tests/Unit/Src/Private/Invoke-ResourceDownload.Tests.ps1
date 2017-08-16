#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Invoke-ResourceDownload' {

    InModuleScope -ModuleName $moduleName {

        It 'Returns a "System.Management.Automation.PSCustomObject" type' {
            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
            Mock Test-ResourceDownload -MockWith { return $true; }

            $resource = Invoke-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum;

            $resource -is [System.Management.Automation.PSCustomObject] | Should Be $true;
        }

        It 'Calls "Set-ResourceDownload" if "Test-ResourceDownload" fails' {
            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
            Mock Test-ResourceDownload -MockWith { return $false; }
            Mock Set-ResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -MockWith { }

            Invoke-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum;

            Assert-MockCalled Set-ResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -Scope It;
        }

        It 'Calls "Set-ResourceDownload" if "Test-ResourceDownload" passes but -Force was specified' {
            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
            Mock Test-ResourceDownload -MockWith { return $false; }
            Mock Set-ResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -MockWith { }

            Invoke-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum -Force;

            Assert-MockCalled Set-ResourceDownload -ParameterFilter { $DestinationPath -eq $testResourcePath -and $Uri -eq $testResourceUri } -Scope It;
        }

        It 'Does not call "Set-ResourceDownload" if "Test-ResourceDownload" passes' {
            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
            Mock Test-ResourceDownload -MockWith { return $true; }
            Mock Set-ResourceDownload -MockWith { }

            Invoke-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum;

            Assert-MockCalled Set-ResourceDownload -Scope It -Exactly 0;
        }

        It 'Throws if "Set-ResourceDownload" downloaded resource checksum does not match' {
            $testResourcePath = 'TestDrive:\TestResource.txt';
            $testResourceUri = 'http://testresourcedomain.com/testresource.txt';
            $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';
            Mock Test-ResourceDownload -MockWith { return $false; }
            Mock Test-ResourceDownload -ParameterFilter { $ThrowOnError -eq $true } -MockWith { throw 'Oops' }
            Mock Set-ResourceDownload -MockWith { }

            { Invoke-ResourceDownload -DestinationPath $testResourcePath -Uri $testResourceUri -Checksum $testResourceChecksum } | Should Throw
        }

    } #end InModuleScope

} #end describe
