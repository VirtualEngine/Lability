#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\LabVMDiskFile' {

    InModuleScope $moduleName {

        Context 'Validates "SetLabVMDiskModule" method' {

            $testModules = @(
                @{ Name = 'PowerShellModule'; }
                @{ Name = 'DscResourceModule'; }
            )

            It 'Calls "InvokeModuleCacheDownload" with "Force" when specified' {
                Mock InvokeModuleCacheDownload -MockWith { }
                Mock ExpandModuleCache -MockWith { }

                SetLabVMDiskModule -Module $testModules -DestinationPath ".\" -Force

                Assert-MockCalled InvokeModuleCacheDownload -ParameterFilter { $Force -eq $true } -Scope It;

            }

            It 'Calls "ExpandModuleCache" with "Clean" when specified' {
                Mock InvokeModuleCacheDownload -MockWith { }
                Mock ExpandModuleCache -MockWith { }

                SetLabVMDiskModule -Module $testModules -DestinationPath ".\" -Clean

                Assert-MockCalled ExpandModuleCache -ParameterFilter { $Clean -eq $true } -Scope It;

            }

        } #end context Validates "SetLabVMDiskModule" method

        Context 'Validates "SetLabVMDiskFileResource" method' {

            It 'Calls "ExpandLabResource" using "ResourceShare" path' {

                $testNode = 'TestNode';
                $testConfigurationData = @{}
                $testDriveLetter = 'Z';
                $testResourceShare = 'TestResourceShare';
                $testHostConfiguration = [PSCustomObject] @{
                    ResourceShareName = $testResourceShare;
                }
                Mock GetConfigurationData -MockWith { return $testHostConfiguration; }
                Mock ExpandLabResource -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileResource @testParams;

                $expectedDestinationPath = '{0}:\{1}' -f $testDriveLetter, $testResourceShare;
                Assert-MockCalled ExpandLabResource -ParameterFilter { $DestinationPath -eq $expectedDestinationPath } -Scope It
            }

        } #end context Validates "SetLabVMDiskFileResource" method

        Context 'Validates "SetLabVMDiskFileModule" method' {

            $testNode = 'TestNode';
            $testConfigurationData = @{}
            $testDriveLetter = $env:SystemDrive.Trim(':');

            $testModules = @(
                @{ Name = 'PowerShellModule'; }
                @{ Name = 'DscResourceModule'; }
            )

            It 'Calls "Resolve-LabModule" to query DSC resource modules' {
                Mock Resolve-LabModule -MockWith { return $testModules; }
                Mock SetLabVMDiskModule -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileModule @testParams;

                Assert-MockCalled Resolve-LabModule -ParameterFilter { $ModuleType -eq 'DscResource'; } -Scope It;
            }

            It 'Calls "Resolve-LabModule" to query PowerShell modules' {
                Mock Resolve-LabModule -MockWith { return $testModules; }
                Mock SetLabVMDiskModule -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileModule @testParams;

                Assert-MockCalled Resolve-LabModule -ParameterFilter { $ModuleType -eq 'Module'; } -Scope It;
            }

            It 'Calls "SetLabVMDiskModule" to expand modules' {
                Mock Resolve-LabModule -MockWith { return $testModules; }
                Mock SetLabVMDiskModule -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileModule @testParams;

                Assert-MockCalled SetLabVMDiskModule -Scope It -Exactly 2;
            }

        } #end context Validates "SetLabVMDiskFileModule" method

        Context 'Validates "SetLabVMDiskFileUnattendXml" method' {

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

            It 'Calls "SetUnattendXml" to create "\Windows\System32\Sysprep\Unattend.xml" file' {

                $testNode = 'TestNode';
                $testConfigurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testNode; }
                    )
                }
                $testDriveLetter = $env:SystemDrive.Trim(':');
                $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

                Mock SetUnattendXml -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                    Credential = $testCredential;
                }
                SetLabVMDiskFileUnattendXml @testParams;

                $expectedPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $testDriveLetter;
                Assert-MockCalled SetUnattendXml -ParameterFilter { $Path -eq $expectedPath } -Scope It;
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

                Mock SetUnattendXml -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                    Credential = $testCredential;
                }
                SetLabVMDiskFileUnattendXml @testParams;

                Assert-MockCalled SetUnattendXml -ParameterFilter { $ProductKey -eq $testProductKey } -Scope It;

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

                Mock SetUnattendXml -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                    Credential = $testCredential;
                    ProductKey = $testProductKey;
                }
                SetLabVMDiskFileUnattendXml @testParams;

                Assert-MockCalled SetUnattendXml -ParameterFilter { $ProductKey -eq $testProductKey } -Scope It;

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

                Mock SetUnattendXml -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                    Credential = $testCredential;
                    ProductKey = $testProductKey;
                }
                SetLabVMDiskFileUnattendXml @testParams;

                Assert-MockCalled SetUnattendXml -ParameterFilter { $ProductKey -eq $testNodeProductKey } -Scope It;

            }

        } #end context Validates "SetLabVMDiskFileUnattendXml" method

        Context 'Validates "SetLabVMDiskFileBootstrap" method' {

            $testDriveLetter = $env:SystemDrive.Trim(':');

            It 'Calls "SetBootStrap" to inject default bootstrap' {
                Mock SetBootStrap -MockWith { }
                Mock SetSetupCompleteCmd -MockWith { }

                $testParams = @{
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileBootstrap @testParams;

                Assert-MockCalled SetBootStrap -ParameterFilter { $null -eq $CustomBootstrap } -Scope It;
            }

            It 'Calls "SetBootStrap" to inject custom bootstrap when specified' {
                Mock SetBootStrap -MockWith { }
                Mock SetSetupCompleteCmd -MockWith { }

                $testParams = @{
                    VhdDriveLetter = $testDriveLetter;
                    CustomBootStrap = 'Test Bootstrap';
                }
                SetLabVMDiskFileBootstrap @testParams;

                Assert-MockCalled SetBootStrap -ParameterFilter { $null -ne $CustomBootstrap } -Scope It;
            }

            It 'Calls "SetBootStrap" with "CoreCLR" to inject CoreCLR bootstrap when specified' {
                Mock SetBootStrap -MockWith { }
                Mock SetSetupCompleteCmd -MockWith { }

                $testParams = @{
                    VhdDriveLetter = $testDriveLetter;
                    CoreCLR = $true;
                }
                SetLabVMDiskFileBootstrap @testParams;

                Assert-MockCalled SetBootStrap -ParameterFilter { $CoreCLR -eq $true } -Scope It;
            }

            It 'Calls "SetSetupCompleteCmd" with "\Windows\Setup\Scripts" path' {
                Mock SetBootStrap -MockWith { }
                Mock SetSetupCompleteCmd -MockWith { }

                $testParams = @{
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileBootstrap @testParams;

                $expectedPath = '{0}:\Windows\Setup\Scripts' -f $testDriveLetter;
                Assert-MockCalled SetSetupCompleteCmd -ParameterFilter { $Path -eq $expectedPath } -Scope It;
            }

        } #end context Validates "SetLabVMDiskFileBootstrap" method

        Context 'Validates "SetLabVMDiskFileMof" method' {

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

                { SetLabVMDiskFileMof @testParams -WarningAction Stop 3>&1 } | Should Throw;

            }

            It 'Copies .mof file if found' {
                $testMofPath = Join-Path -Path $testPath -ChildPath "$testNode.mof";
                Mock Copy-Item -MockWith { }
                Mock Test-Path -ParameterFilter { $Path -eq $testMofPath } -MockWith { return $true; }

                SetLabVMDiskFileMof @testParams;

                Assert-MockCalled Copy-Item -ParameterFilter { $Path -eq $testMofPath } -Scope It;
            }

            It 'Copies .meta.mof file if found' {
                $testMofPath = Join-Path -Path $testPath -ChildPath "$testNode.meta.mof";
                Mock Copy-Item -MockWith { }
                Mock Test-Path -ParameterFilter { $Path -eq $testMofPath } -MockWith { return $true; }

                SetLabVMDiskFileMof @testParams 3>&1;

                Assert-MockCalled Copy-Item -ParameterFilter { $Path -eq $testMofPath } -Scope It;
            }

        } #end context Validates "SetLabVMDiskFileMof" method

        Context 'Validates "SetLabVMDiskFileCertificate" method' {

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
                SetLabVMDiskFileCertificate @testParams;

                Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith('\Lability\Certificates\LabClient.pfx') } -Scope It;
            }

            It 'Copies default root certificate' {
                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = $testConfigurationData;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileCertificate @testParams;

                Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith('\Lability\Certificates\LabRoot.cer') } -Scope It;
            }

            It 'Copies custom client certificate' {
                $testCertificate = '{0}:\TestClientCertificate.pfx' -f $testDriveLetter;
                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; Lability_ClientCertificatePath = $testCertificate; } ) };
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileCertificate @testParams;

                Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith($testCertificate) } -Scope It;
            }

            It 'Copies custom root certificate' {
                $testCertificate = '{0}:\TestRootCertificate.cer' -f $testDriveLetter;
                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; Lability_RootCertificatePath = $testCertificate; } ) };
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileCertificate @testParams;

                Assert-MockCalled Copy-Item -ParameterFilter { $Path.EndsWith($testCertificate) } -Scope It;
            }

        } #end context Validates "SetLabVMDiskFileCertificate" method



    } #end InModuleScope

} #end describe Src\LabVMDiskFile
