#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-ResourceDownload' {

    InModuleScope -ModuleName $moduleName {

        $testResourcePath = 'TestDrive:\TestResource.txt';
        $testResourceChecksumPath = '{0}.checksum' -f $testResourcePath;
        $testResourceContent = 'MyResourceFileContent';
        $testResourceChecksum = '0BA549AA1F04E4E788AF574AF0FF7668';

        It 'Returns "System.Collections.Hashtable" type' {
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Set-Content -Path $testResourceChecksumPath -Value $testResourceChecksum -Force;

            $resource = Get-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;

            $resource -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Returns empty checksum if resource does not exist' {
            Remove-Item -Path $testResourcePath -Force -ErrorAction SilentlyContinue;
            Remove-Item -Path $testResourceChecksumPath -Force -ErrorAction SilentlyContinue;

            $resource = Get-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;

            $resource.Checksum | Should BeNullOrEmpty;
        }

        It 'Returns correct checksum if resource and checksum files exist' {
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Set-Content -Path $testResourceChecksumPath -Value $testResourceChecksum -Force;

            $resource = Get-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;

            $resource.Checksum | Should Be $testResourceChecksum;
        }

        It 'Returns correct checksum if resource exists but checksum does not exist' {
            Set-Content -Path $testResourcePath -Value $testResourceContent -Force;
            Remove-Item -Path $testResourceChecksumPath -Force -ErrorAction SilentlyContinue;

            $resource = Get-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;

            $resource.Checksum | Should Be $testResourceChecksum;
        }

        It 'Returns incorrect checksum if incorrect resource and checksum files exist' {
            Set-Content -Path $testResourcePath -Value "$testResourceContent-?" -Force;
            $fileHash = Get-FileHash -Path $testResourcePath -Algorithm MD5 | Select-Object -ExpandProperty Hash;
            $fileHash | Set-Content -Path $testResourceChecksumPath -Force;

            $resource = Get-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;

            $resource.Checksum | Should Be $fileHash;
        }

        It 'Returns incorrect checksum if incorrect resource exists but checksum does not exist' {
            Set-Content -Path $testResourcePath -Value "$testResourceContent-?" -Force;
            Remove-Item -Path $testResourceChecksumPath -Force -ErrorAction SilentlyContinue;

            $resource = Get-ResourceDownload -DestinationPath $testResourcePath -Uri 'about:blank' -Checksum $testResourceChecksum;

            $resource.Checksum | Should Not Be $testResourceChecksum;
        }

    } #end InModuleScope

} #end describe
