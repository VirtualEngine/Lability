#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-LabConfigurationMof' {

    InModuleScope -ModuleName $moduleName {

        It 'Throws if path is invalid' {
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }

            { Test-LabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path 'TestDrive:\InvalidPath' } | Should Throw;
        }

        It 'Does not throw if ".mof" and ".meta.mof" files exist' {
            $testPath = 'TestDrive:';
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            New-Item -Path "$testPath\$testVM.mof" -ItemType File -Force;
            New-Item -Path "$testPath\$testVM.meta.mof" -ItemType File -Force;

            { Test-LabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath } | Should Not Throw;
        }

        It 'Throws if ".mof" file is missing' {
            $testPath = 'TestDrive:';
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Remove-Item -Path "$testPath\$testVM.mof" -Force -ErrorAction SilentlyContinue;
            Remove-Item -Path "$testPath\$testVM.meta.mof" -Force -ErrorAction SilentlyContinue;

            { Test-LabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath } | Should Throw;
        }

        It 'Warns if ".meta.mof" file is missing' {
            $testPath = 'TestDrive:';
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            New-Item -Path "$testPath\$testVM.mof" -ItemType File -Force;
            Remove-Item -Path "$testPath\$testVM.meta.mof" -Force -ErrorAction SilentlyContinue;

            { Test-LabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath -WarningAction Stop 3>&1 } | Should Throw;
        }

        It 'Warns if ".mof" file is missing but -SkipMofCheck is specified' {
            $testPath = 'TestDrive:';
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Remove-Item -Path "$testPath\$testVM.mof" -Force -ErrorAction SilentlyContinue;
            Remove-Item -Path "$testPath\$testVM.meta.mof" -Force -ErrorAction SilentlyContinue;

            { Test-LabConfigurationMof -ConfigurationData $configurationData -Name $testVM -Path $testPath -SkipMofCheck -WarningAction Stop 3>&1 } | Should Throw;
        }

    } #end InModuleScope

} #end describe
