#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Validates "SetLabVMDiskFile" method' {

    InModuleScope $moduleName {

        $testNode = 'TestNode';
        $testConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; } ) }
        $testDiskNumber = 42;
        $testDriveLetter = $env:SystemDrive.Trim(':');

        $testCredential = [System.Management.Automation.PSCredential]::Empty;


        $testVhdPath = 'TestDrive:\{0}.vhdx' -f $testNode;

        Mock ResolveLabVMDiskPath -MockWith { return $testVhdPath; }
        Mock Stop-ShellHWDetectionService { }
        Mock Start-ShellHWDetectionService { }
        Mock Mount-Vhd -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
        Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
        Mock Start-Service -MockWith { }
        Mock SetLabVMDiskFileResource -MockWith { }
        Mock SetLabVMDiskFileBootstrap -MockWith { }
        Mock SetLabVMDiskFileUnattendXml -MockWith { }
        Mock SetLabVMDiskFileMof -MockWith { }
        Mock SetLabVMDiskFileCertificate -MockWith { }
        Mock SetLabVMDiskFileModule -MockWith { }
        Mock Dismount-Vhd -MockWith { }

        $testParams = @{
            NodeName = $testNode;
            ConfigurationData = $testConfigurationData;
            Credential = $testCredential;
            Path = '.\';
        }

        It 'Stops "ShellHWDetection" service' {

            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Stop-ShellHWDetectionService -Scope It;
        }

        It 'Mounts virtual machine VHDX file' {

            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
        }

        It 'Starts "ShellHWDetection" service' {

            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Start-ShellHWDetectionService -Scope It;
        }

        It 'Calls "SetLabVMDiskFileResource" to copy node resources' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled SetLabVMDiskFileResource -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "SetLabVMDiskFileBootstrap" to copy Lability bootstrap' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled SetLabVMDiskFileBootstrap -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "SetLabVMDiskFileUnattendXml" to copy unattended installation file' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled SetLabVMDiskFileUnattendXml -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "SetLabVMDiskFileMof" to copy node DSC configuaration files' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled SetLabVMDiskFileMof -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "SetLabVMDiskFileCertificate" to copy node certificate files' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled SetLabVMDiskFileCertificate -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "SetLabVMDiskFileModule" to copy PowerShell/DSC resource modules' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled SetLabVMDiskFileModule -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Dismounts virtual machine VHDX file' {

            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
        }

        It 'Dismounts virtual machine VHDX file when error is thrown' {

            Mock SetLabVMDiskFileResource -MockWith { throw 'Should still dismount'; }

            { Set-LabVMDiskFile @testParams } | Should Throw;
            Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
        }

    } #end InModuleScope

}  #end describe
