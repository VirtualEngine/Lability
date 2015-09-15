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
            #PSDscAllowPlainTextPassword = $true;
            CertificateFile = "$env:AllUsersProfile\VirtualEngineLab\Certificates\LabClient.cer";
            Thumbprint = '599E0BDA95ADED538154DC9FA6DE94920424BCB1';
            PSDscAllowDomainUser = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            VirtualEngineLab_SwitchName = 'Corpnet';
            VirtualEngineLab_ProcessorCount = 1;
            VirtualEngineLab_Media = '2012R2_x64_Standard_EN_Eval';
        },
        @{
            NodeName = 'DC1';
            IPAddress = '10.0.0.1';
            DnsServerAddress = '127.0.0.1';
            Role = 'DC';
            VirtualEngineLab_ProcessorCount = 2;
        },
        @{
            NodeName = 'EDGE1';
            IPAddress = '10.0.0.2';
            Role = 'EDGE';
        },
        @{
            NodeName = 'APP1';
            IPAddress = '10.0.0.3';
            Role = 'APP';
        },
        @{
            NodeName = 'INET1';
            VirtualEngineLab_SwitchName = 'Internet';
            IPAddress = '131.107.0.1';
            DnsServerAddress = '127.0.0.1';
            DefaultGateway = '0.0.0.0';
            Role = 'INET';
        },
        @{
            NodeName = 'CLIENT1';
            IPAddress = '10.0.0.99';
            Role = 'CLIENT';
            VirtualEngineLab_Media = 'Win81_x64_Enterprise_EN_Eval';
        }
    );
    NonNodeData = @{
        VirtualEngineLab = @{
            Media = @();
            Network = @(
                @{ Name = 'Corpnet'; Type = 'Internal'; }
                @{ Name = 'Internet'; Type = 'Internal'; }
                # @{ Name = 'Corpnet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true; }
                <# 
                    IPAddress: The desired IP address.
                    InterfaceAlias: Alias of the network interface for which the IP address should be set. <- Use NetAdapterName
                    DefaultGateway: Specifies the IP address of the default gateway for the host. <- Not needed for internal switch
                    SubnetMask: Local subnet size.
                    AddressFamily: IP address family: { IPv4 | IPv6 }
                #>
            );
        };
    };
};
