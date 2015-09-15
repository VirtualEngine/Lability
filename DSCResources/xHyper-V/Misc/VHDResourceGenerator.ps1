  $name = New-DscResourceProperty -Name Name -Type String -Attribute Key -Description "Name of the VHD File"
  $path = New-DscResourceProperty -Name Path -Type String -Attribute Key -Description "Folder where the VHD will be created"
  $parentPath = New-DscResourceProperty -Name ParentPath -Type String -Attribute Write -Description "Parent VHD file path, for differencing disk"
  $generation = New-DscResourceProperty -Name Generation -Type String -Attribute Write -ValidateSet "Vhd","Vhdx" -Description "Virtual disk format - Vhd or Vhdx"
  $ensure = New-DscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet "Present","Absent" -Description "Should the VHD be created or deleted"
  $MaximumSizeBytes = New-DscResourceProperty -Name MaximumSizeBytes -Type Uint32 -Attribute Write -Description "Maximum size of Vhd to be created"

  $id = New-DscResourceProperty -Name ID -Type String -Attribute Read -Description "Virtual Disk Identifier"
  $type = New-DscResourceProperty -Name Type -Type String -Attribute Read -Description "Type of Vhd - Dynamic, Fixed, Differencing"
  $FileSizeBytes = New-DscResourceProperty -Name FileSizeBytes -Type Uint32 -Attribute Read -Description "Current size of the VHD"
  $IsAttached = New-DscResourceProperty -Name IsAttached -Type Boolean -Attribute Read -Description "Is the VHD attached to a VM or not"

  New-DscResource -Name MSFT_xVHD -Properties $name,$path,$parentPath,$generation,$ensure,$id,$type,$MaximumSizeBytes,$FileSizeBytes,$IsAttached -Path . -ClassVersion 1.0.0 -FriendlyName xVHD
