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

        <# DEPRECATED
            Context 'Validates "SetLabVMDiskResource" method' {

            It 'Mounts virtual machine VHDX file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ExpandLabResource -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskResource -ConfigurationData $configurationData -NodeName $testVMName -DisplayName $testVMName;

                Assert-MockCalled Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }

            It 'Calls "ExpandLabResource" to inject disk resource' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ExpandLabResource -ParameterFilter { $Name -eq $testVMName }  -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskResource -ConfigurationData $configurationData -NodeName $testVMName -DisplayName $testVMName;

                Assert-MockCalled ExpandLabResource -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Dismounts virtual machine VHDX file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ExpandLabResource -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskResource -ConfigurationData $configurationData -NodeName $testVMName -DisplayName $testVMName;

                Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }

        }  #end context Validates "SetLabVMDiskResource" method
        #>

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

            It 'Calls "ResolveLabModule" to query DSC resource modules' {
                Mock ResolveLabModule -MockWith { return $testModules; }
                Mock SetLabVMDiskModule -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileModule @testParams;

                Assert-MockCalled ResolveLabModule -ParameterFilter { $ModuleType -eq 'DscResource'; } -Scope It;
            }

            It 'Calls "ResolveLabModule" to query PowerShell modules' {
                Mock ResolveLabModule -MockWith { return $testModules; }
                Mock SetLabVMDiskModule -MockWith { }

                $testParams = @{
                    ConfigurationData = $testConfigurationData;
                    NodeName = $testNode;
                    VhdDriveLetter = $testDriveLetter;
                }
                SetLabVMDiskFileModule @testParams;

                Assert-MockCalled ResolveLabModule -ParameterFilter { $ModuleType -eq 'Module'; } -Scope It;
            }

            It 'Calls "SetLabVMDiskModule" to expand modules' {
                Mock ResolveLabModule -MockWith { return $testModules; }
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
                    }
                )
            }
            $testDriveLetter = $env:SystemDrive.Trim(':');
            $testCredential = $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);;

            It 'Calls "SetUnattendXml" to create "\Windows\System32\Sysprep\Unattend.xml" file' {
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

        Context 'Validates "SetLabVMDiskFile" method' {

            $testNode = 'TestNode';
            $testConfigurationData = @{ AllNodes = @( @{ NodeName = $testNode; } ) }
            $testDiskNumber = 42;
            $testDriveLetter = $env:SystemDrive.Trim(':');

            $testCredential = [System.Management.Automation.PSCredential]::Empty;


            $testVhdPath = 'TestDrive:\{0}.vhdx' -f $testNode;

            Mock ResolveLabVMDiskPath -MockWith { return $testVhdPath; }
            Mock Stop-Service -MockWith { }
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

                SetLabVMDiskFile @testParams;

                Assert-MockCalled Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -Scope It;
            }

            It 'Mounts virtual machine VHDX file' {

                SetLabVMDiskFile @testParams;

                Assert-MockCalled Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;

                #Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                #Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                #Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }v
                #Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }

                ##Mock SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -MockWith { }
                ##Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                ##Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                ##Mock ResolveProgramFilesFolder -MockWith { }
                ##Mock ResolveLabModule -MockWith { }
                ##Mock SetLabVMDiskModule -MockWith { }
            }

            It 'Starts "ShellHWDetection" service' {

                SetLabVMDiskFile @testParams;

                Assert-MockCalled Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -Scope It;
            }

            It 'Calls "SetLabVMDiskFileResource" to copy node resources' {
                SetLabVMDiskFile @testParams;

                Assert-MockCalled SetLabVMDiskFileResource -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
            }

            It 'Calls "SetLabVMDiskFileBootstrap" to copy Lability bootstrap' {
                SetLabVMDiskFile @testParams;

                Assert-MockCalled SetLabVMDiskFileBootstrap -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
            }

            It 'Calls "SetLabVMDiskFileUnattendXml" to copy unattended installation file' {
                SetLabVMDiskFile @testParams;

                Assert-MockCalled SetLabVMDiskFileUnattendXml -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
            }

            It 'Calls "SetLabVMDiskFileMof" to copy node DSC configuaration files' {
                SetLabVMDiskFile @testParams;

                Assert-MockCalled SetLabVMDiskFileMof -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
            }

            It 'Calls "SetLabVMDiskFileCertificate" to copy node certificate files' {
                SetLabVMDiskFile @testParams;

                Assert-MockCalled SetLabVMDiskFileCertificate -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
            }

            It 'Calls "SetLabVMDiskFileModule" to copy PowerShell/DSC resource modules' {
                SetLabVMDiskFile @testParams;

                Assert-MockCalled SetLabVMDiskFileModule -ParameterFilter { $VhdDriveLetter -eq $testDriveLetter } -Scope It;
            }

            It 'Dismounts virtual machine VHDX file' {

                SetLabVMDiskFile @testParams;

                Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }

        }  #end context Validates "SetLabVMDiskFile" method

    } #end InModuleScope

} #end describe LabVMDiskFile
