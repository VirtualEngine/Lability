#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-AzDevOpsModuleUri' {

    InModuleScope $moduleName {

        $testPackageName = 'TestPackage';
        $testUri = 'http://testrepo.local/api/v2/packages';

        It 'Returns default AzDeOps Feed Uri' {
            $expected = '{0}?id={1}' -f $labDefaults.RepositoryUri, $testPackageName;

            $result = Resolve-AzDevOpsModuleUri -Name $testPackageName;

            $result | Should Be $expected;
        }

        It 'Returns specified Uri' {
            $expected = '{0}?id={1}' -f $testUri, $testPackagename;

            $result = Resolve-AzDevOpsModuleUri -Name $testPackageName -Uri $testUri;

            $result | Should Be $expected;
        }


        It 'Returns Uri with specific version number when "RequiredVersion" is specified' {

            $testPackageVersion = '1.2.3' -as [System.Version];
            $expected = '{0}?id={1}&version={2}' -f $labDefaults.RepositoryUri, $testPackageName, $testPackageVersion;

            $result = Resolve-AzDevOpsModuleUri -Name $testPackageName -RequiredVersion $testPackageVersion;

            $result | Should Be $expected;
        }

    } #end InModuleScope

} #end Describe
