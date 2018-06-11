#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-WindowsBuildNumber' {

    InModuleScope $moduleName {

        It 'Returns true when build number matches the required minimum' {

            $PSVersionTable = @{ BuildVersion = @{ Build = 16299 } }
            $result = Test-WindowsBuildNumber -MinimumVersion 16299;

            $result | Should Be $true;
        }

        It 'Returns true when build number mais greater than the required minimum' {

            $PSVersionTable = @{ BuildVersion = @{ Build = 17134 } }
            $result = Test-WindowsBuildNumber -MinimumVersion 16299;

            $result | Should Be $true;
        }

        It 'Returns false when build number is less than the required minimum (#294)' {

            $PSVersionTable = @{ BuildVersion = @{ Build = 15063 } }
            $result = Test-WindowsBuildNumber -MinimumVersion 16299;

            $result | Should Be $false;
        }

    } #end InModuleScope
} #end Describe
