  $name = New-DscResourceProperty -Name Name -Type String -Attribute Key -Description "Name of the VM Switch"
  $type = New-DscResourceProperty -Name Type -Type String -Attribute Key -ValidateSet "Internal","Private" -Description "Type of switch"
  $netAdapter = New-DscResourceProperty -Name NetAdapterName -Type String -Attribute Write -Description "Network adapter name for external switch type"
  $allowManagementOS = New-DscResourceProperty -Name AllowManagementOS -Type Boolean -Attribute Write -Description "Specify is the VM host has access to the physical NIC"
  $ensure = New-DscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet "Present","Absent" -Description "Whether switch should be present or absent"
  $id = New-DscResourceProperty -Name Id -Type String -Attribute Read -Description "Unique ID for the switch"
  $netDescription = New-DscResourceProperty -Name NetAdapterInterfaceDescription -Type String -Attribute Read -Description "Description of the network interface"
   New-DscResource -Name MSFT_xVMSwitch -Path . -Properties $name,$type,$netAdapter,$allowManagementOS,$ensure,$id,$netDescription -ClassVersion 1.0.0.0 -FriendlyName xVMSwitch
