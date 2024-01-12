<#
    .SYNOPSIS
        Example configuration for consistently deploying VMs with
        multiple network adapters using VLANs.
#>
configuration MultipleNetworkExample {
    param ()

    # Import your DSC Resources
    # Import-DscResource -ModuleName xNetworking;

    node $AllNodes.NodeName {

        # Your configuration goes here...

    } #end node

} #end configuration
