#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'DscModule' {
    
    InModuleScope $moduleName {

        ## Cannot (easily) mock New-Object calls :(

        Context 'Validates "TestDscModule" method' {

            It 'Returns true if "GetDscModule" returns a path' {
                $testModuleName = 'TestLabModule';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                Mock GetDscModule -MockWith { return $testModulePath; }

                TestDscModule -ModuleName $testModuleName | Should Be $true;
            }

            It 'Returns false if "GetDscModule" fails' {
                $testModuleName = 'TestLabModule';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                Mock GetDscModule -MockWith { Write-Error "DSC module\resource '$testModuleName' not found."; }

                TestDscModule -ModuleName $testModuleName | Should Be $false;
            }

        } #end context Validates "TestDscModule" method

        Context 'Validates "GetDscModule" method' {

            It 'Throws if module does not exist' {
                $testModuleName = 'TestLabModule';
                $testModulePath = Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1";
                Mock Get-Module -MockWith { }

                { GetDscModule -ModuleName $testModuleName } | Should Throw;
            }

            It 'Returns DSC resource''s parent directory path' {
                $testModuleName = 'TestLabModule';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                
                GetDscModule -ModuleName $testModuleName | Should Be (Split-Path -Path $testModulePath -Parent);
            }

            It 'Returns DSC resource''s DSCResources subdirectory path if ResourceName is specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                Mock Test-Path -MockWith { return $true }
                
                GetDscModule -ModuleName $testModuleName -ResourceName $testResourceName | Should Match ([Regex]::Escape("$testModuleName\DSCResources\$ResourceName"));
            }

            It 'Errors if DSC resource''s subdirectory path does not exist and ResourceName is specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                Mock Test-Path -MockWith { return $false }
                
                { GetDscModule -ModuleName $testModuleName -ResourceName $testResourceName -ErrorAction Stop } | Should Throw;
            }

            It 'Returns $null if DSC resource''s subdirectory path does not exist and ResourceName is specified' {
                $testModuleName = 'TestLabModule';
                $testResourceName = 'TestLabResource';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                Mock Test-Path -MockWith { return $false }
                
                GetDscModule -ModuleName $testModuleName -ResourceName $testResourceName -ErrorAction SilentlyContinue | Should BeNullOrEmpty;
            }

            It 'Does not throw if DSC module version is equal to the MinimumVersion specified' {
                $testModuleName = 'TestLabModule';
                $testModuleVersion = '1.2.3.4';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = [System.Version] $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                Mock Test-Path -MockWith { return $true; }
                
                { GetDscModule -ModuleName $testModuleName -MinimumVersion $testModuleVersion -ErrorAction Stop } | Should Not Throw;
            }

            It 'Does not throw if DSC module version is greater than the MinimumVersion specified' {
                $testModuleName = 'TestLabModule';
                $testModuleVersion = '1.2.3.5';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = [System.Version] $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                Mock Test-Path -MockWith { return $true; }
                
                { GetDscModule -ModuleName $testModuleName -MinimumVersion '1.2.3.4' -ErrorAction Stop } | Should Not Throw;
            }

            It 'Errors if DSC module version is less than the MinimumVersion specified' {
                $testModuleName = 'TestLabModule';
                $testModuleVersion = '1.2.3.4';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = [System.Version] $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                
                { GetDscModule -ModuleName $testModuleName -MinimumVersion '1.2.3.5' -ErrorAction Stop } | Should Throw;
            }

            It 'Returns $null if DSC module version is less than the MinimumVersion specified' {
                $testModuleName = 'TestLabModule';
                $testModuleVersion = '1.2.3.4';
                $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
                $fakeModule = [PSCustomObject] @{ Name = $testModuleName; Path = $testModulePath; Version = [System.Version] $testModuleVersion; }
                Mock Get-Module -MockWith { return $fakeModule }
                
                GetDscModule -ModuleName $testModuleName -MinimumVersion '1.2.3.5' -ErrorAction SilentlyContinue | Should BeNullOrEmpty;
            }

        } #end context Validates "GetDscModule" method
 
    } #end InModuleScope

} #end describe DscModule
