<#
    .SYNOPSIS
        Example configuration for consistently deploying VMs with
        multiple network adapters using MAC address for mapping.
#>
configuration MultipleNetworkExample {
    param ()

    Import-DscResource -ModuleName xNetworking;

    node $AllNodes.NodeName {

        ## Enumerate all MAC addresses of the node
        for ($i = 0; $i -lt @($node.Lability_MACAddress).Count; $i++) {

            ## Use the NetAdapterName resource to rename the network adapter
            ## to the corresponding 'NICName' using the MAC address key.
            xNetAdapterName "RenameNetAdapter$i" {

                NewName    = $node.Lability_NICName[$i];
                MacAddress = $node.Lability_MACAddress[$i];
            }

        } #end for

    } #end node

} #end configuration
