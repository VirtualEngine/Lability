#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFile' {

    InModuleScope $moduleName {

        $testNode = 'TestNode';
        $testConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; } ) }
        $testDiskNumber = 42;
        $testDriveLetter = $env:SystemDrive.Trim(':');
        $testCredential = [System.Management.Automation.PSCredential]::Empty;
        $testVhdPath = 'TestDrive:\{0}.vhdx' -f $testNode;

        ## Giard mocks
        Mock Resolve-LabVMGenerationDiskPath -MockWith { return $testVhdPath; }
        Mock Stop-ShellHWDetectionService { }
        Mock Start-ShellHWDetectionService { }
        Mock Mount-Vhd -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
        Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
        Mock Start-Service -MockWith { }
        Mock Set-LabVMDiskFileResource -MockWith { }
        Mock Set-LabVMDiskFileBootstrap -MockWith { }
        Mock Set-LabVMDiskFileUnattendXml -MockWith { }
        Mock Set-LabVMDiskFileMof -MockWith { }
        Mock Set-LabVMDiskFileCertificate -MockWith { }
        Mock Set-LabVMDiskFileModule -MockWith { }
        Mock Dismount-Vhd -MockWith { }
        Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

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

        It 'Calls "Set-LabVMDiskFileResource" to copy node resources' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Set-LabVMDiskFileResource -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "Set-LabVMDiskFileBootstrap" to copy Lability bootstrap' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Set-LabVMDiskFileBootstrap -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "Set-LabVMDiskFileUnattendXml" to copy unattended installation file' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Set-LabVMDiskFileUnattendXml -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "Set-LabVMDiskFileMof" to copy node DSC configuaration files' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Set-LabVMDiskFileMof -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "Set-LabVMDiskFileCertificate" to copy node certificate files' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Set-LabVMDiskFileCertificate -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Calls "Set-LabVMDiskFileModule" to copy PowerShell/DSC resource modules' {
            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Set-LabVMDiskFileModule -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
        }

        It 'Dismounts virtual machine VHDX file' {

            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
        }

        It 'Disables/enables BitLocker fixed drive write protection (if required)' {

            Mock Disable-BitLockerFDV -MockWith { }
            Mock Assert-BitLockerFDV -MockWith { }

            Set-LabVMDiskFile @testParams;

            Assert-MockCalled Disable-BitLockerFDV -Exactly 1 -Scope It
            Assert-MockCalled Assert-BitLockerFDV -Exactly 1 -Scope It
        }

        It 'Dismounts virtual machine VHDX file when error is thrown' {

            Mock Set-LabVMDiskFileResource -MockWith { throw 'Should still dismount'; }

            { Set-LabVMDiskFile @testParams } | Should Throw;
            Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
        }

    } #end InModuleScope

}  #end describe
