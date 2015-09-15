# sample values used for testing.
$vhdPath = "C:\test_vhds\RenameComputer.Vhd"

# sample text file that you want to copy in the VHD.
$sampletxt  = "C:\sample.txt"

# This path is the relative path to mounted drive letter.
$sampleVhdDestinationPath = "xvhdFileExample\CopiedFile"

# A local folder that you want to copy in to the VHD.
$samplefolder = "c:\SampleFolder"

Configuration xVhdD_CopyFileOrFolder
{

     Param(
     [Parameter(Mandatory=$true, Position=0)]
     [validatescript({Test-Path $_})]
     $vhdPath,
     [Parameter(Mandatory=$true)]
     [validatescript({Test-Path $_})]
     $itemToCopy,
     [Parameter(Mandatory=$true)]
     $relativeDestinationPath
    )

        Import-DscResource -moduleName xHyper-V

        xVhdFile FileCopy
        {
            VhdPath =  $vhdPath
            FileDirectory =  MSFT_xFileDirectory {
                               SourcePath = $itemToCopy
                               DestinationPath = $relativeDestinationPath
                               }

        }

}

# Copy File/Folder example
xVhdD_CopyFileOrFolder -vhdPath $vhdPath -itemToCopy $sampletxt -relativeDestinationPath $sampleVhdDestinationPath
Start-DscConfiguration -ComputerName localhost -Path $pwd\xVhdD_CopyFileOrFolder\ -Wait -Verbose

xVhdD_CopyFileOrFolder -vhdPath $vhdPath -itemToCopy $samplefolder -relativeDestinationPath $sampleVhdDestinationPath
Start-DscConfiguration -ComputerName localhost -Path $pwd\xVhdD_CopyFileOrFolder\ -Wait -Verbose

Configuration RemoveFileOrFolderFromVHD
{
    param(
      [Parameter(Mandatory=$true, Position=0)]
      [validatescript({Test-Path $_})]
      $vhdPath,
      [Parameter(Mandatory=$true)]
      $relativeDestinationPath,
      $Ensure = 'Absent'
    )
    Import-DscResource -moduleName xHyper-V
     xVhdFile RemoveFile
        {
            VhdPath =  $vhdPath
            FileDirectory =  MSFT_xFileDirectory {
                               DestinationPath = $relativeDestinationPath
                               Ensure = $Ensure
                               }

        }

}

RemoveFileOrFolderFromVHD -vhdPath $vhdPath -relativeDestinationPath $sampleVhdDestinationPath
Start-DscConfiguration -ComputerName localhost -Path $pwd\RemoveFileOrFolderFromVHD\ -Wait -Verbose

Configuration ChangeAttribute
{
    param(
      [Parameter(Mandatory=$true, Position=0)]
      [validatescript({Test-Path $_})]
      $vhdPath,
      [Parameter(Mandatory=$true)]
      $relativeDestinationPath,
      [ValidateSet ("Archive", "Hidden",  "ReadOnly", "System" )] $attribute
    )

    Import-DscResource -moduleName xHyper-V
      xVhdFile Change-Attribute
        {
            VhdPath =  $vhdPath
            FileDirectory =  MSFT_xFileDirectory {
                               DestinationPath = $relativeDestinationPath
                               Attributes  = $attribute
                               }

        }
}

ChangeAttribute -vhdPath $vhdPath -relativeDestinationPath $sampleVhdDestinationPath -attribute 'ReadOnly'
Start-DscConfiguration -ComputerName localhost -Path $pwd\RemoveFileOrFolderFromVHD\ -Wait -Verbose

# End to end sample for x-Hyper-v
Configuration Sample_EndToEndXHyperV_RunningVM
{

    param
    (
        [Parameter(Mandatory)]
        $baseVhdPath,

        [Parameter(Mandatory)]
        $name,
        [Parameter(Mandatory)]
        [validatescript({Test-Path $_})]
        $unattendedFilePathToCopy

    )

    Import-DscResource -module xHyper-V

    # Create a switch to be used by the VM
    xVMSwitch switch
    {
        Name =  "Test-Switch"
        Ensure = "Present"        
        Type = "Internal"
    }

    # Create new VHD file.
    xVHD NewVHD1
    {

            Ensure           = "Present"
            Name             = $name
            Path             = (Split-Path $baseVhdPath)
            Generation       = "vhd"
            ParentPath       =  $baseVhdPath

    }

    # Customize VHD by copying a folders/files to the VHD before a VM can be created
    # Example below shows copying unattended.xml before a VM can be created
    xVhdFile CopyUnattendxml
    {
            VhdPath =  $vhdPath
            FileDirectory =  MSFT_xFileDirectory {
                               SourcePath = $unattendedFilePathToCopy
                               DestinationPath = "unattended.xml"
                               }

    }

    # create the testVM out of the vhd.
    xVMHyperV testvm
    {
        Name = "$($name)_vm"
        SwitchName = "Test-Switch"
        VhdPath = Join-path (Split-Path $baseVhdPath) "$name.vhd"
        ProcessorCount = 2
        MaximumMemory  = 1GB
        MinimumMemory = 512MB
        RestartIfNeeded =  "TRUE"
        DependsOn = "[xVHD]NewVHD1","[xVMSwitch]switch","[xVhdFile]CopyUnattendxml"
        State = "Running"

    }

}

# Create a mof file.
Sample_EndToEndXHyperV_RunningVM -baseVhdPath "C:\test_vhds\testvhd.vhd" -name TestMachine -unattendedFilePathToCopy C:\temp\unattended.xml

# Run the configuration on localhost.
Start-DscConfiguration -Path $pwd\Sample_EndToEndXHyperV_RunningVM  -ComputerName localhost -Verbose -Wait

