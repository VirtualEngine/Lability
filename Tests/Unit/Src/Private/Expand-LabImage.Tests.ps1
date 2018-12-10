#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Expand-LabImage' {

    InModuleScope $moduleName {

        <#
        Serialized MSFT_DiskImage CimInstance object with {0} placeholder for ImagePath.
        Needed for mocking to suppress error:
        Cannot process argument transformation on parameter 'DiskImage'. Cannot convert the
        "@{DriveLetter=Z}" value of type "System.Management.Automation.PSCustomObject" to type
        "Microsoft.Management.Infrastructure.CimInstance"
        #>
        $getDiskImageXml = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_DiskImage</T>
      <T>Microsoft.Management.Infrastructure.CimInstance#MSFT_DiskImage</T>
      <T>Microsoft.Management.Infrastructure.CimInstance</T>
      <T>System.Object</T>
    </TN>
    <Props>
      <B N="Attached">false</B>
      <U64 N="BlockSize">0</U64>
      <Nil N="DevicePath" />
      <U64 N="FileSize">0</U64>
      <S N="ImagePath">{0}</S>
      <U64 N="LogicalSectorSize">0</U64>
      <Nil N="Number" />
      <U64 N="Size">0</U64>
      <U32 N="StorageType">1</U32>
      <Nil N="PSComputerName" />
    </Props>
    <MS>
      <Obj N="__ClassMetadata" RefId="1">
        <TN RefId="1">
          <T>System.Collections.ArrayList</T>
          <T>System.Object</T>
        </TN>
        <LST>
          <Obj RefId="2">
            <MS>
              <S N="ClassName">MSFT_DiskImage</S>
              <S N="Namespace">ROOT/Microsoft/Windows/Storage</S>
              <S N="ServerName"></S>
              <I32 N="Hash">0</I32>
              <S N="MiXml">&lt;CLASS NAME="MSFT_DiskImage"&gt;&lt;QUALIFIER NAME="dynamic" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="locale" TYPE="sint32" TOSUBCLASS="false"&gt;&lt;VALUE&gt;1033&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="provider" TYPE="string"&gt;&lt;VALUE&gt;StorageWMI&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;PROPERTY NAME="Attached" TYPE="boolean"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="BlockSize" TYPE="uint64"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="DevicePath" TYPE="string"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="FileSize" TYPE="uint64"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="ImagePath" TYPE="string"&gt;&lt;QUALIFIER NAME="key" TYPE="boolean" OVERRIDABLE="false"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="LogicalSectorSize" TYPE="uint64"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="Number" TYPE="uint32"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="Size" TYPE="uint64"&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;PROPERTY NAME="StorageType" TYPE="uint32"&gt;&lt;QUALIFIER NAME="key" TYPE="boolean" OVERRIDABLE="false"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="read" TYPE="boolean"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="ValueMap" TYPE="string"&gt;&lt;VALUE.ARRAY&gt;&lt;VALUE&gt;0&lt;/VALUE&gt;&lt;VALUE&gt;1&lt;/VALUE&gt;&lt;VALUE&gt;2&lt;/VALUE&gt;&lt;VALUE&gt;3&lt;/VALUE&gt;&lt;VALUE&gt;4&lt;/VALUE&gt;&lt;/VALUE.ARRAY&gt;&lt;/QUALIFIER&gt;&lt;/PROPERTY&gt;&lt;METHOD NAME="Mount" TYPE="uint32"&gt;&lt;QUALIFIER NAME="implemented" TYPE="boolean" TOSUBCLASS="false"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;PARAMETER NAME="Access" TYPE="uint16"&gt;&lt;QUALIFIER NAME="ID" TYPE="sint32" OVERRIDABLE="false"&gt;&lt;VALUE&gt;0&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="In" TYPE="boolean" OVERRIDABLE="false"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="ValueMap" TYPE="string"&gt;&lt;VALUE.ARRAY&gt;&lt;VALUE&gt;0&lt;/VALUE&gt;&lt;VALUE&gt;2&lt;/VALUE&gt;&lt;VALUE&gt;3&lt;/VALUE&gt;&lt;/VALUE.ARRAY&gt;&lt;/QUALIFIER&gt;&lt;/PARAMETER&gt;&lt;PARAMETER NAME="NoDriveLetter" TYPE="boolean"&gt;&lt;QUALIFIER NAME="ID" TYPE="sint32" OVERRIDABLE="false"&gt;&lt;VALUE&gt;1&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;QUALIFIER NAME="In" TYPE="boolean" OVERRIDABLE="false"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/PARAMETER&gt;&lt;/METHOD&gt;&lt;METHOD NAME="Dismount" TYPE="uint32"&gt;&lt;QUALIFIER NAME="implemented" TYPE="boolean" TOSUBCLASS="false"&gt;&lt;VALUE&gt;true&lt;/VALUE&gt;&lt;/QUALIFIER&gt;&lt;/METHOD&gt;&lt;/CLASS&gt;</S>
            </MS>
          </Obj>
        </LST>
      </Obj>
    </MS>
  </Obj>
</Objs>
'@

        It 'Mounts ISO image' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Dismount-DiskImage -MockWith { }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
        }

        It 'Does not Mount WIM image' {
            $testWimPath = 'TestDrive:\TestWimImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Mount-DiskImage -MockWith { }

            Expand-LabImage -MediaPath $testWimPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Mount-DiskImage -Scope It -Exactly 0;
        }

        It 'Calls "Get-WindowsImageByName" method when passing "WimImageName"' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageName = 'TestWimImage';
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
            Mock Dismount-DiskImage -MockWith { }
            Mock Get-WindowsImageByName -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageName $testWimImageName -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Get-WindowsImageByName -ParameterFilter { $ImageName -eq $testWimImageName } -Scope It;
        }

        It 'Calls "Expand-WindowsImage" with specified "WimImageIndex"' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
            Mock Dismount-DiskImage -MockWith { }
            Mock Expand-WindowsImage -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR;

            Assert-MockCalled Expand-WindowsImage -ParameterFilter { $Index -eq $testWimImageIndex} -Scope It;
        }

        It 'Calls "Expand-WindowsImage" with custom "WimPath"' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            $testWimPath = '\custom.wim';
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
            Mock Dismount-DiskImage -MockWith { }
            Mock Expand-WindowsImage -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR -WimPath $testWimPath;

            Assert-MockCalled Expand-WindowsImage -ParameterFilter { $ImagePath.EndsWith($testWimPath) } -Scope It;
        }

        It 'Dismounts ISO image' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
            Mock Dismount-DiskImage -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
        }

        It 'Does not dismount WIM image' {
            $testWimPath = 'TestDrive:\TestWimImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Dismount-DiskImage { }

            Expand-LabImage -MediaPath $testWimPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Dismount-DiskImage -Scope It -Exactly 0;
        }

        It 'Calls "Add-LabImageWindowsOptionalFeature" when "WindowsOptionalFeature" is defined' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageName = 'TestWimImage';
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
            Mock Dismount-DiskImage -MockWith { }
            Mock Get-WindowsImageByIndex -MockWith { return 42; }
            Mock Add-LabImageWindowsOptionalFeature -MockWith { }

            $expandLabImageParams = @{
                MediaPath = $testIsoPath;
                WimImageName = $testWimImageName;
                Vhd = $testVhdImage;
                PartitionStyle = 'GPT';
                WindowsOptionalFeature = 'NetFx3';
            }
            Expand-LabImage @expandLabImageParams;

            Assert-MockCalled Add-LabImageWindowsOptionalFeature -Scope It;
        }

        It 'Calls "Add-LabImageWindowsOptionalFeature" with custom "SourcePath"' {
            $testWimPath = 'TestDrive:\TestWimImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageName = 'TestWimImage';
            $testSourcePath = '\CustomSourcePath';
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Get-WindowsImageByIndex { return 42; }
            Mock Add-LabImageWindowsOptionalFeature -MockWith { }

            $expandLabImageParams = @{
                MediaPath = $testWimPath;
                WimImageName = $testWimImageName;
                Vhd = $testVhdImage;
                PartitionStyle = 'GPT';
                WindowsOptionalFeature = 'NetFx3';
                SourcePath = $testSourcePath;
            }
            Expand-LabImage @expandLabImageParams -WarningAction SilentlyContinue;

            Assert-MockCalled Add-LabImageWindowsOptionalFeature -ParameterFilter { $ImagePath.EndsWith($testSourcePath) }-Scope It;

        }

        It 'Dismounts ISO image when error is thrown (#166)' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageIndex = 42;
            Mock Get-DiskImage -MockWith { return [System.Management.Automation.PSSerializer]::Deserialize($getDiskImageXml -f $testIsoPath) }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z' }
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
            Mock Dismount-DiskImage -MockWith { }
            Mock Expand-WindowsImage -MockWith { Write-Error 'Should Dismount ISO' }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT -ErrorAction SilentlyContinue;

            Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
        }

    } #end InModuleScope

} #end Describe
