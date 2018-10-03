#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileUnattendXml' {

    InModuleScope $moduleName {

        $testNode = 'TestNode';
        $testConfigurationData = @{
            AllNodes = @(
                @{
                    NodeName = $testNode;
                    CustomData = @{
                        ProductKey = 'ABCDE-12345-EDCBA-54321-ABCDE';
                    }
                }
            )
        }
        $testDriveLetter = $env:SystemDrive.Trim(':');
        $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

        It 'Calls "Set-UnattendXml" to create "\Windows\System32\Sysprep\Unattend.xml" file' {

            $testNode = 'TestNode';
            $testConfigurationData = @{
                AllNodes = @(
                    @{ NodeName = $testNode; }
                )
            }
            $testDriveLetter = $env:SystemDrive.Trim(':');
            $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

            Mock Set-UnattendXml -MockWith { }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
                Credential = $testCredential;
            }
            Set-LabVMDiskFileUnattendXml @testParams;

            $expectedPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $testDriveLetter;
            Assert-MockCalled Set-UnattendXml -ParameterFilter { $Path -eq $expectedPath } -Scope It;
        }

        It 'Passes node "ProductKey" when specified (#134)' {

            $testNode = 'TestNode';
            $testProductKey = 'ABCDE-12345-EDCBA-54321-ABCDE';
            $testConfigurationData = @{
                AllNodes = @(
                    @{
                        NodeName = $testNode;
                        CustomData = @{ ProductKey = $testProductKey; }
                    }
                )
            }
            $testDriveLetter = $env:SystemDrive.Trim(':');
            $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

            Mock Set-UnattendXml -MockWith { }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
                Credential = $testCredential;
            }
            Set-LabVMDiskFileUnattendXml @testParams;

            Assert-MockCalled Set-UnattendXml -ParameterFilter { $ProductKey -eq $testProductKey } -Scope It;
        }

        It 'Passes media "ProductKey" when specified (#134)' {

            $testNode = 'TestNode';
            $testProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO';
            $testConfigurationData = @{
                AllNodes = @(
                    @{
                        NodeName = $testNode;
                    }
                )
            }
            $testDriveLetter = $env:SystemDrive.Trim(':');
            $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

            Mock Set-UnattendXml -MockWith { }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
                Credential = $testCredential;
                ProductKey = $testProductKey;
            }
            Set-LabVMDiskFileUnattendXml @testParams;

            Assert-MockCalled Set-UnattendXml -ParameterFilter { $ProductKey -eq $testProductKey } -Scope It;
        }

        It 'Passes node "ProductKey" when node and media key specified (#134)' {

            $testNode = 'TestNode';
            $testNodeProductKey = 'ABCDE-12345-EDCBA-54321-ABCDE';
            $testProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO';
            $testConfigurationData = @{
                AllNodes = @(
                    @{
                        NodeName = $testNode;
                        CustomData = @{ ProductKey = $testNodeProductKey; }
                    }
                )
            }
            $testDriveLetter = $env:SystemDrive.Trim(':');
            $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

            Mock Set-UnattendXml -MockWith { }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
                Credential = $testCredential;
                ProductKey = $testProductKey;
            }
            Set-LabVMDiskFileUnattendXml @testParams;

            Assert-MockCalled Set-UnattendXml -ParameterFilter { $ProductKey -eq $testNodeProductKey } -Scope It;
        }

    } #end InModuleScope

} #end describe
