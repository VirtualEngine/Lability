#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-ResourceDownload' {

    InModuleScope -ModuleName $moduleName {

        $testResourcePath = 'TestDrive:\TestResource.txt';
        $testResourceChecksumPath = '{0}.checksum' -f $testResourcePath;
        $testResourceContent = 'MyResourceFileContent';
        $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';

        It 'Returns true if resource exists but no checksum was specified' {
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Get-ResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; } }

            Test-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' | Should Be $true;
        }

        It 'Returns true if resource exists and checksum is correct' {
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Get-ResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = $testResourceChecksum; } }

            Test-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum | Should Be $true;
        }

        It 'Returns false if resource does not exist' {
            Remove-Item -Path $testResourcePath -Force -ErrorAction SilentlyContinue;
            Mock Get-ResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = $testResourceChecksum; } }

            Test-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' | Should Be $false;
        }

        It 'Returns false if resource exists but checksum is incorrect' {
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Get-ResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = 'ThisIsAnIncorrectChecksum'; } }

            Test-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum | Should Be $false;
        }

        It 'Returns false if the checksum is correct but the resource does not exist' {
            Remove-Item -Path $testResourcePath -Force -ErrorAction SilentlyContinue;
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Mock Get-ResourceDownload -MockWith { return @{ DestinationPath = $testResourcePath; Uri = 'about:blank'; Checksum = 'ThisIsAnIncorrectChecksum'; } }

            Test-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum | Should Be $false;
        }

    } #end InModuleScope

} #end describe
