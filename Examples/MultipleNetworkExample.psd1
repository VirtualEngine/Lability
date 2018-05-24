@{
    AllNodes = @(
        @{
            NodeName            = 'MULTINETWORK';

            ## Hyper-V MAC address range '00-15-5d-00-00-00' thru '00-15-5d-ff-ff-ff'.
            ## NOTE: BE CAREFUL OF DUPLICATE MAC ADDRESSES IF USING EXTERNAL SWITCHES!
            Lability_MACAddress = '00-15-5d-ff-ff-01', '00-15-5d-ff-ff-02';

            ## Hyper-V switch name to attach each NIC to. The first network adapter
            ## with be attached to the 'Default Switch' virtual switch and given the
            ## '00-15-5d-ff-ff-01' MAC address.
            Lability_SwitchName = 'Default Switch',  'Internal';

            ## Name to be given to the NIC (inside the VM) using xNetAdapterName
            ## resource. This is implemented in the 'MultipleNetworkExample.ps1'
            ## configuration. After renaming the interfaces, these names can then
            ## reliably be used in the 'InterfaceAlias' property of xDNSServerAddress,
            ## xIPAddress and xDefaultGatewayAddress resources etc.
            Lability_NICName    = 'Public', 'Management';
        }
    );
    NonNodeData = @{
        Lability = @{
            DscResource = @(
                @{ Name = 'xNetworking'; RequiredVersion = '5.7.0.0'; }
            )
        }
    }
};
