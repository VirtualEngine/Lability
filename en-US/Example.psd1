@{
    AllNodes = @(
        @{
            NodeName = '*';
            InterfaceAlias = 'Ethernet';
            DefaultGateway = '10.0.0.254';
            SubnetMask = 24;
            AddressFamily = 'IPv4';
            DnsServerAddress = '10.0.0.1';
            DomainName = 'corp.contoso.com';
            PSDscAllowPlainTextPassword = $true;
            #CertificateFile = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            #Thumbprint = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            PSDscAllowDomainUser = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            Lability_SwitchName = 'Corpnet';
            Lability_ProcessorCount = 1;
            Lability_Media = '2012R2_x64_Standard_EN_Eval';
        }
        @{
            NodeName = 'DC1';
            IPAddress = '10.0.0.1';
            DnsServerAddress = '127.0.0.1';
            Role = 'DC';
            Lability_ProcessorCount = 2;
        }
        @{
            NodeName = 'EDGE1';
            IPAddress = '10.0.0.2';
            SecondaryIPAddress = '131.107.0.2';
            SecondaryDnsServerAddress = '131.107.0.1';
            SecondaryInterfaceAlias = 'Ethernet 2';
            SecondarySubnetMask = 24;
            Role = 'EDGE';
            ## Windows sees the two NICs in reverse order, e.g. first switch is 'Ethernet 2' and second is 'Ethernet'!?
            Lability_SwitchName = 'Corpnet','Internet';
        }
        @{
            NodeName = 'APP1';
            IPAddress = '10.0.0.3';
            Role = 'APP';
        }
        @{
            NodeName = 'INET1';
            IPAddress = '131.107.0.1';
            DnsServerAddress = '127.0.0.1';
            DefaultGateway = '';
            Role = 'INET';
            
            ## If no network is specified, the virtual machine will be attached to a default internal virtual switch. 
            Lability_SwitchName = 'Internet';
        }
        @{
            NodeName = 'CLIENT1';
            Role = 'CLIENT';
            Lability_Media = 'Win81_x64_Enterprise_EN_Eval';
            <# Lability_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property #>
        }
        @{
            NodeName = 'CLIENT2';
            Role = 'CLIENT';
            Lability_Media = 'Win10_x64_Enterprise_EN_Eval';
            <# Lability_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property #>
        }
    );
    NonNodeData = @{
        Lability = @{
            Media = @();
            Network = @(
                @{ Name = 'Corpnet'; Type = 'Internal'; }
                @{ Name = 'Internet'; Type = 'Internal'; }
                # @{ Name = 'Corpnet'; Type = 'External'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true; }
                <# 
                    IPAddress: The desired IP address.
                    InterfaceAlias: Alias of the network interface for which the IP address should be set. <- Use NetAdapterName
                    DefaultGateway: Specifies the IP address of the default gateway for the host. <- Not needed for internal switch
                    Subnet: Local subnet CIDR (used for cloud routing).
                    AddressFamily: IP address family: { IPv4 | IPv6 }
                #>
            );
            DSCResource = @(
                ## Download published version from the PowerShell Gallery
                ## If not specified, it defaults to the PSGallery provider type
                @{ Name = 'xComputerManagement'; MinimumVersion = '1.3.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xSmbShare'; MinimumVersion = '1.1.0.0'; }
                ## Download development/unpublished version from a Github repository.
                ## If not specified, the repository name defaults to the DSC module name
                ## NOTE: bootstraps the GitHubRepository module
                @{ Name = 'xNetworking'; MinimumVersion = '2.5.0.0'; Provider = 'GitHub'; Owner = 'Powershell'; Repository = 'xNetworking'; Branch = 'dev'; }
                @{ Name = 'xActiveDirectory'; MinimumVersion = '2.8.0.0'; Provider = 'GitHub'; Owner = 'PowerShell'; Branch = 'dev'; }
                @{ Name = 'xDnsServer'; MinimumVersion = '1.4.0.0'; Provider = 'GitHub'; Owner = 'PowerShell'; Branch = 'dev'; }
                @{ Name = 'xDhcpServer'; MinimumVersion = '1.2'; Provider = 'GitHub'; Owner = 'PowerShell'; Branch = 'dev'; }
            );
        };
    };
};
