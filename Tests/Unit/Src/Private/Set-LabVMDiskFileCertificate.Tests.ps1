#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileCertificate' {

    InModuleScope $moduleName {

        $testNode = 'TestNode';
        $testConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; } ) }
        $testDriveLetter = $env:SystemDrive.Trim(':');

        Mock Copy-Item -MockWith { }

        It 'Copies default client certificate' {
            $testParams = @{
                NodeName = $testNode;
                ConfigurationData = $testConfigurationData;
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileCertificate @testParams;

            Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith('\Lability\Certificates\LabClient.pfx') } -Scope It;
        }

        It 'Copies default root certificate' {
            $testParams = @{
                NodeName = $testNode;
                ConfigurationData = $testConfigurationData;
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileCertificate @testParams;

            Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith('\Lability\Certificates\LabRoot.cer') } -Scope It;
        }

        It 'Copies custom client certificate' {
            $testCertificate = '{0}:\TestClientCertificate.pfx' -f $testDriveLetter;
            $testParams = @{
                NodeName = $testNode;
                ConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; Lability_ClientCertificatePath = $testCertificate; } ) };
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileCertificate @testParams;

            Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith($testCertificate) } -Scope It;
        }

        It 'Copies custom root certificate' {
            $testCertificate = '{0}:\TestRootCertificate.cer' -f $testDriveLetter;
            $testParams = @{
                NodeName = $testNode;
                ConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; Lability_RootCertificatePath = $testCertificate; } ) };
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileCertificate @testParams;

            Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith($testCertificate) } -Scope It;
        }

    } #end InModuleScope

} #end describe
