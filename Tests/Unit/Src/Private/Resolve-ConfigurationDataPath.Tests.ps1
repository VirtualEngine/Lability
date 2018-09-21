#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-ConfigurationDataPath' {

    InModuleScope $moduleName {

        foreach ($config in @('Host','VM','Media','CustomMedia')) {

            It "Resolves '$config' to module path when custom configuration does not exist" {
                Mock Test-Path -MockWith { return $false }
                $configurationPath = Resolve-ConfigurationDataPath -Configuration $config -IncludeDefaultPath;
                $configurationPath -like "$repoRoot*" | Should Be $true;
            }

            It "Resolves '$config' to %ALLUSERSPROFILE% path when custom configuration does exist" {
                Mock Test-Path -MockWith { return $true }
                $configurationPath = Resolve-ConfigurationDataPath -Configuration $config;
                $allUsersProfile = ("$env:AllUsersProfile\$moduleName").Replace('\','\\');
                $configurationPath | Should Match $allUsersProfile;
            }

        } #end foreach $config

        It 'Resolves environment variables in resulting path' {
            Mock Test-Path -MockWith { return $true }
            Mock Resolve-PathEx -MockWith { }

            Resolve-ConfigurationDataPath -Configuration Media;

            Assert-MockCalled Resolve-PathEx -Scope It;
        }

    } #end InModuleScope

} #end Describe
