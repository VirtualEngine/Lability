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
            #CertificateFile = "$env:AllUsersProfile\VirtualEngineLab\Certificates\LabClient.cer";
            #Thumbprint = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            PSDscAllowDomainUser = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            VirtualEngineLab_SwitchName = 'Corpnet';
            VirtualEngineLab_ProcessorCount = 1;
            VirtualEngineLab_Media = '2012R2_x64_Standard_EN_Eval';
        }
        @{
            NodeName = 'DC1';
            IPAddress = '10.0.0.1';
            DnsServerAddress = '127.0.0.1';
            Role = 'DC';
            VirtualEngineLab_ProcessorCount = 2;
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
            VirtualEngineLab_SwitchName = 'Corpnet','Internet';
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
            VirtualEngineLab_SwitchName = 'Internet';
        }
        @{
            NodeName = 'CLIENT1';
            Role = 'CLIENT';
            VirtualEngineLab_Media = 'Win81_x64_Enterprise_EN_Eval';
            <# VirtualEngineLab_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property' #>
        }
        @{
            NodeName = 'CLIENT2';
            Role = 'CLIENT';
            VirtualEngineLab_Media = 'Win10_x64_Enterprise_EN_Eval';
            <# VirtualEngineLab_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property' #>
        }
    );
    NonNodeData = @{
        VirtualEngineLab = @{
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
                ## Download from the PowerShell Gallery
                @{ Name = 'xSQLServer'; MinimumVersion = '1.3.0.0'; Provider = 'PSGallery'; }
                ## Download from a Github repository. NOTE: bootstraps the GitHubRepositoryModule
                @{ Name = 'xSqlPs'; MinimumVersion = '1.1.3.1'; Provider = 'GitHub'; Owner = 'Powershell'; Repository = 'xSqlPs'; Branch = 'dev'; }
            );
        };
    };
};
