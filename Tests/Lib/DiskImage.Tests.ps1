#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'DiskImage' {
    
    InModuleScope $moduleName {

        Context 'Validates "GetDiskImageDriveLetter" method' {

            It 'Throws when no disk letter is found' {
                Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = $null; Type = 'Basic'; DiskNumber = 1; } }
                $diskImage = [PSCustomObject] @{ DiskNumber = 1 };
                
                { GetDiskImageDriveLetter -DiskImage $diskImage -PartitionType Basic } | Should Throw;
            }

            It 'Throws when no disk letter is found for specified partition type' {
                Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z'; Type = 'IFS'; DiskNumber = 1; } }
                $diskImage = [PSCustomObject] @{ DiskNumber = 1 };
                
                { GetDiskImageDriveLetter -DiskImage $diskImage -PartitionType Basic } | Should Throw;
            }

            It 'Returns a single character' {
                Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z'; Type = 'IFS'; DiskNumber = 1; } }
                $diskImage = [PSCustomObject] @{ DiskNumber = 1 };

                (GetDiskImageDriveLetter -DiskImage $diskImage -PartitionType IFS).Length | Should Be 1;
            }

        } #end context Validates "GetDiskImageDriveLetter" method

        Context 'Validates "NewDiskImage" method' {
            
            It 'Throws if VHD image already exists' {
                $testVhdPath = "TestDrive:\TestImage.vhdx";
                $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'MBR'; }
                
                { NewDiskImage @newDiskImageParams } | Should Throw;    
            }

            It 'Removes existing VHD image if it already exists and -Force is specified' {
                $testVhdPath = "TestDrive:\TestImage.vhdx";
                $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'MBR'; Force = $true; }
                Mock Dismount-VHD -MockWith { }
                Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = 10; } }
                Mock New-Vhd -MockWith { }
                Mock Initialize-Disk -MockWith { }
                Mock NewDiskImageMbr -MockWith { }
                Mock Remove-Item -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { };
                
                NewDiskImage @newDiskImageParams;
                
                Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq $newDiskImageParams.Path } -Scope It;
            }

            It 'Creates new VHD file and initializes disk' {
                $testVhdPath = "TestDrive:\TestImage.vhdx";
                $testDiskNumber = 10;
                $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'GPT'; Force = $true; }
                Mock Dismount-VHD -MockWith { }
                Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock NewDiskImageGpt -MockWith { }
                Mock Remove-Item -MockWith { };
                Mock Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -MockWith { }
                Mock New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { }
                
                NewDiskImage @newDiskImageParams;
                
                Assert-MockCalled New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -Scope It;
                Assert-MockCalled Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -Scope It;
            }

            It 'Does dismount VHD file if -PassThru is not specified' {
                $testVhdPath = "TestDrive:\TestImage2.vhdx";
                $testDiskNumber = 10;
                $newDiskImageParams = @{ Path = $testVhdPath; PartitionStyle = 'GPT'; PassThru = $false; }
                Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock NewDiskImageGpt -MockWith { }
                Mock Initialize-Disk -MockWith { }
                Mock NewDiskImageMbr -MockWith { }
                Mock Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                NewDiskImage @newDiskImageParams;
                
                Assert-MockCalled Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }

            It 'Does not dismount VHD file if -PassThru is specified' {
                $testVhdPath = "TestDrive:\TestImage3.vhdx";
                $testDiskNumber = 10;
                $newDiskImageParams = @{ Path = $testVhdPath; PartitionStyle = 'GPT'; PassThru = $true; }
                Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock NewDiskImageGpt -MockWith { }
                Mock Initialize-Disk -MockWith { }
                Mock NewDiskImageMbr -MockWith { }
                Mock Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                NewDiskImage @newDiskImageParams;
                
                Assert-MockCalled Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -Scope It -Exactly 0;
            }

        } #end context Validates "NewDiskImage" method

        Context 'Validates "SetDiskImageBootVolumeMbr" method' {

            It 'Calls "BCDBOOT.EXE" with "/f BIOS"' {
                $testVhdPath = (New-Item -Path 'TestDrive:\TestImage.vhdx' -Force -ItemType File).FullName;
                $testVhdImage = @{ Path = $testVhdPath };
                Mock GetDiskImageDriveLetter -MockWith { return 'Z'; }
                Mock InvokeExecutable -MockWith { }
                Mock InvokeExecutable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f BIOS' } -MockWith { }

                SetDiskImageBootVolumeMbr -Vhd $testVhdImage;

                Assert-MockCalled InvokeExecutable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f BIOS' } -Scope It -Exactly 1;
            }

            It 'Calls "BCDEDIT.EXE" thrice' {
                $testVhdPath = (New-Item -Path 'TestDrive:\TestImage.vhdx' -Force -ItemType File).FullName;
                $testVhdImage = @{ Path = $testVhdPath };
                Mock GetDiskImageDriveLetter -MockWith { return 'Z'; }
                Mock InvokeExecutable -MockWith { }
                Mock InvokeExecutable -ParameterFilter { $Path -eq 'BCDEDIT.EXE' } -MockWith { }

                SetDiskImageBootVolumeMbr -Vhd $testVhdImage;

                Assert-MockCalled InvokeExecutable -ParameterFilter { $Path -eq 'BCDEDIT.EXE' } -Scope It -Exactly 3;
            }

        } #end context validates "SetDiskImageBootVolumeMbr" method

        Context 'Validates "SetDiskImageBootVolumeGpt" method' {

            It 'Calls "BCDBOOT.EXE" with "/f UEFI"' {
                $testVhdPath = (New-Item -Path 'TestDrive:\TestImage.vhdx' -Force -ItemType File).FullName;
                $testVhdImage = @{ Path = $testVhdPath };
                Mock GetDiskImageDriveLetter -MockWith { return 'Z'; }
                Mock InvokeExecutable -MockWith { }
                Mock InvokeExecutable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f UEFI' } -MockWith { }

                SetDiskImageBootVolumeGpt -Vhd $testVhdImage;

                Assert-MockCalled InvokeExecutable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f UEFI' } -Scope It -Exactly 1;
            }

        } #end context validates "SetDiskImageBootVolumeMbr" method

        Context 'Validates "NewDiskImageMbr" method' {

            ## We're going to Mock Get-Partition so best grab a copy now!
            $stubPartition = Get-Partition | Select -Last 1;
        
            It 'Stops Shell Hardware Detection service' {
                $parameterFilter = { $Name -eq 'ShellHWDetection' }
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                Mock New-Partition -MockWith { return $stubPartition }
                Mock Add-PartitionAccessPath -MockWith { return $stubPartition }
                Mock Get-Partition -MockWith { return $stubPartition }
                Mock Format-Volume -MockWith { }
                Mock Start-Service -ParameterFilter $parameterFilter -MockWith { }
                Mock Stop-Service -ParameterFilter $parameterFilter -MockWith { }
        
                NewDiskImageMbr -Vhd $vhdImage;
                
                Assert-MockCalled Stop-Service -ParameterFilter $parameterFilter -Scope It;
                Assert-MockCalled Start-Service -ParameterFilter $parameterFilter -Scope It;
            }

            It 'Creates a full size active IFS partition' {
                $parameterFilter = { $MbrType -eq 'IFS' };
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                Mock Add-PartitionAccessPath -MockWith { return $stubPartition }
                Mock Get-Partition -MockWith { return $stubPartition }
                Mock Format-Volume -MockWith { }
                Mock Start-Service -MockWith { }
                Mock Stop-Service -MockWith { }
                Mock New-Partition -MockWith { }
                Mock New-Partition -ParameterFilter $parameterFilter -MockWith { return $stubPartition }

                NewDiskImageMbr -Vhd $vhdImage;

                Assert-MockCalled New-Partition -ParameterFilter $parameterFilter -Scope It;
            }

            It 'Formats volume as NTFS' {
                $parameterFilter = { $FileSystem -eq 'NTFS' }
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                Mock New-Partition -MockWith { return $stubPartition }
                Mock Add-PartitionAccessPath -MockWith { return $stubPartition }
                Mock Get-Partition -MockWith { return $stubPartition }
                Mock Start-Service -MockWith { }
                Mock Stop-Service -MockWith { }
                Mock Format-Volume -MockWith { }
                Mock Format-Volume -ParameterFilter $parameterFilter -MockWith { }
                
                NewDiskImageMbr -Vhd $vhdImage;

                Assert-MockCalled Format-Volume -ParameterFilter $parameterFilter -Scope It;
            }
        
        } #end context Validates "NewDiskImageMbr" method

        Context 'Validates "NewDiskImageGpt" method' {

            It 'Stops and starts Shell Hardware Detection service' {
                $stubPartition = Get-Partition | Select -Last 1;
                $parameterFilter = { $Name -eq 'ShellHWDetection' }
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };

                Mock New-Partition -MockWith { return $stubPartition }
                Mock NewDiskPartFat32Partition -MockWith { }
                Mock Format-Volume -MockWith { }
                Mock Start-Service -ParameterFilter $parameterFilter -MockWith { }
                Mock Stop-Service -ParameterFilter $parameterFilter -MockWith { }
                
                NewDiskImageGpt -Vhd $vhdImage;

                Assert-MockCalled Stop-Service -ParameterFilter $parameterFilter -Scope It;
                Assert-MockCalled Start-Service -ParameterFilter $parameterFilter -Scope It;
            }

            It 'Creates 250MB system partition' {
                $stubPartition = Get-Partition | Select -Last 1;
                $parameterFilter = { $Size -eq 250MB -and $GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' }
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };

                Mock Stop-Service -MockWith { }
                Mock Start-Service -MockWith { }
                Mock Format-Volume -MockWith { }
                Mock New-Partition -MockWith { return $stubPartition }
                Mock New-Partition -ParameterFilter $parameterFilter -MockWith { return $stubPartition }

                NewDiskImageGpt -Vhd $vhdImage;

                Assert-MockCalled New-Partition -ParameterFilter $parameterFilter -Scope It -Exactly 1;
            }

            It 'Creates OS partition' {
                $stubPartition = Get-Partition | Select -Last 1;
                $parameterFilter = { $GptType -eq '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' }
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };

                Mock Stop-Service -MockWith { }
                Mock Start-Service -MockWith { }
                Mock Format-Volume -MockWith { }
                Mock New-Partition -MockWith { return $stubPartition }
                Mock New-Partition -ParameterFilter $parameterFilter -MockWith { return $stubPartition }

                NewDiskImageGpt -Vhd $vhdImage;

                Assert-MockCalled New-Partition -ParameterFilter $parameterFilter -Scope It -Exactly 1;
            }

            It 'Formats volume as NTFS' {
                $stubPartition = Get-Partition | Select -Last 1;
                $parameterFilter = { $FileSystem -eq 'NTFS' };
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                Mock New-Partition -MockWith { return $stubPartition }
                Mock Start-Service -MockWith { }
                Mock Stop-Service -MockWith { }
                Mock Format-Volume -MockWith { }
                Mock Format-Volume -ParameterFilter $parameterFilter -MockWith { }
                
                NewDiskImageGpt -Vhd $vhdImage;

                Assert-MockCalled Format-Volume -ParameterFilter $parameterFilter -Scope It;
            }

        } #end context Validates "NewDiskImageGpt" method

        Context 'Validates "SetDiskImageBootVolume" method' {

            It 'Calls "SetDiskImageBootVolumeGpt" when partition style is GPT' {
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                Mock SetDiskImageBootVolumeGpt -MockWith { };

                SetDiskImageBootVolume -Vhd $vhdImage -PartitionStyle GPT;

                Assert-MockCalled SetDiskImageBootVolumeGpt -Scope It;
            }
        
            It 'Calls "SetDiskImageBootVolumeMbr" when partition style is GPT' {
                $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                Mock SetDiskImageBootVolumeMbr -MockWith { };

                SetDiskImageBootVolume -Vhd $vhdImage -PartitionStyle MBR;

                Assert-MockCalled SetDiskImageBootVolumeMbr -Scope It;
            }
        
        } #end context Validates "SetDiskImageBootVolume" method

        Context 'Validates "AddDiskImageHotfix" method' {

            $fakeMediaSuite = @(
                @{  Id = 'NoHotfixes';
                    TestName = 'Does not call "Add-WindowsPackage" for no hotfixes';
                    Hotfixes = @();
                }
                @{  Id = 'OneHotfix';
                    TestName = 'Calls "Add-WindowsPackage" for a single hotfix';
                    Hotfixes = @(
                        @{ Id = 'Window0.0-KB1234567.msu'; Uri = 'NonNullValue'; }
                    );
                }
                @{  Id = 'MultipleHotfixes';
                    TestName = 'Calls "Add-WindowsPackage" for each hotfix with multiple hotfixes';
                    Hotfixes = @(
                        @{ Id = 'Window0.0-KB1234567.msu'; Uri = 'NonNullValue'; }
                        @{ Id = 'Window0.0-KB1234568.msu'; Uri = 'NonNullValue'; }
                        @{ Id = 'Window0.0-KB1234569.msu'; Uri = 'NonNullValue'; }
                    );
                }
            )
                  
            foreach ($fakeMedia in $fakeMediaSuite) {
                foreach ($partitionStyle in @('MBR','GPT')) {
                
                    It $fakeMedia.TestName {
                        $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                        Mock GetDiskImageDriveLetter -MockWith { return 'Z'; }
                        Mock Get-LabMedia -MockWith { return [PSCustomObject] $fakeMedia; }
                        Mock InvokeLabMediaHotfixDownload -MockWith { return New-Item -Path "TestDrive:\$Id" -Force -ItemType File }
                        Mock NewDirectory -MockWith { }
                        Mock Add-WindowsPackage -MockWith { }

                        AddDiskImageHotfix $fakeMedia.Id -Vhd $vhdImage -PartitionStyle $partitionStyle;

                        Assert-MockCalled Add-WindowsPackage -Scope It -Exactly $fakeMedia.Hotfixes.Count;
                    }

                } #end foreach partition style
            } #end foreach fake media suite

        } #end context Validates "AddDiskImageHotfix" method

    } #end InModuleScope

} #end describe DiskImage
