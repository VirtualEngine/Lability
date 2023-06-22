#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-AzDoModuleUri' {

    InModuleScope $moduleName {

        Mock Invoke-RestMethod -MockWith { return @(
                [pscustomobject]@{properties=@{NormalizedVersion='1.0.0'}}
                [pscustomobject]@{properties=@{NormalizedVersion='1.2.3'}}
             ) }

        $testPackageName = 'TestPackage';
        $testUri = 'https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v2';

        It 'Returns specified Uri' {
            $expected = '{0}?id={1}&version=1.2.3' -f $testUri, $testPackagename;

            $result = Resolve-AzDoModuleUri -Name $testPackageName -Uri $testUri;
  
            $result | Should Be $expected;
        }


        It 'Returns Uri with specific version number when "RequiredVersion" is specified' {

            $testPackageVersion = '1.2.3' -as [System.Version];
            $expected = '{0}?id={1}&version={2}' -f $testUri, $testPackageName, $testPackageVersion;

            $result = Resolve-AzDoModuleUri -Name $testPackageName -RequiredVersion $testPackageVersion -Uri $testUri;

            $result | Should Be $expected;
        }

    } #end InModuleScope

} #end Describe
