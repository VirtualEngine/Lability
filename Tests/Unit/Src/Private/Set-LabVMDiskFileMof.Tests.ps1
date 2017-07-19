#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileMof' {

    InModuleScope $moduleName {

        $testNode = 'TestNode';
        $testDriveLetter = $env:SystemDrive.Trim(':');
        $testPath = $env:SystemDrive;
        $testParams = @{
            NodeName = $testNode;
            VhdDriveLetter = $testDriveLetter;
            Path = $testPath;
        }

        It 'Warns if .mof file cannot be found' {
            Mock Copy-Item -MockWith { }
            Mock Test-Path -MockWith { return $false; }

            { Set-LabVMDiskFileMof @testParams -WarningAction Stop 3>&1 } | Should Throw;

        }

        It 'Copies .mof file if found' {
            $testMofPath = Join-Path -Path $testPath -ChildPath "$testNode.mof";
            Mock Copy-Item -MockWith { }
            Mock Test-Path -ParameterFilter { $Path -eq $testMofPath } -MockWith { return $true; }

            Set-LabVMDiskFileMof @testParams;

            Assert-MockCalled Copy-Item -ParameterFilter { $Path -eq $testMofPath } -Scope It;
        }

        It 'Copies .meta.mof file if found' {
            $testMofPath = Join-Path -Path $testPath -ChildPath "$testNode.meta.mof";
            Mock Copy-Item -MockWith { }
            Mock Test-Path -ParameterFilter { $Path -eq $testMofPath } -MockWith { return $true; }

            Set-LabVMDiskFileMof @testParams 3>&1;

            Assert-MockCalled Copy-Item -ParameterFilter { $Path -eq $testMofPath } -Scope It;
        }

    } #end InModuleScope

} #end describe
