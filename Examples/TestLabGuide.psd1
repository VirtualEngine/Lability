@{
    AllNodes = @(
        @{
            NodeName                    = '*';
            InterfaceAlias              = 'Ethernet';
            DefaultGateway              = '10.0.0.254';
            PrefixLength                = 24;
            AddressFamily               = 'IPv4';
            DnsServerAddress            = '10.0.0.1';
            DomainName                  = 'corp.contoso.com';
            PSDscAllowPlainTextPassword = $true;
            #CertificateFile             = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            #Thumbprint                  = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            PSDscAllowDomainUser        = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            Lability_SwitchName         = 'Corpnet';
            Lability_ProcessorCount     = 1;
            Lability_StartupMemory      = 2GB;
            Lability_Media              = '2012R2_x64_Standard_EN_Eval';
        }
        @{
            NodeName                = 'DC1';
            IPAddress               = '10.0.0.1';
            DnsServerAddress        = '127.0.0.1';
            Role                    = 'DC';
            Lability_ProcessorCount = 2;
        }
        @{
            NodeName                     = 'EDGE1';
            IPAddress                    = '10.0.0.2';
            DnsConnectionSuffix          = 'corp.contoso.com';
            SecondaryIPAddress           = '131.107.0.2';
            SecondaryDnsServerAddress    = '131.107.0.1';
            SecondaryInterfaceAlias      = 'Ethernet 2';
            SecondaryDnsConnectionSuffix = 'isp.example.com';
            SecondaryPrefixLength        = 24;
            Role                         = 'EDGE';
            ## Windows sees the two NICs in reverse order, e.g. first switch is 'Ethernet 2' and second is 'Ethernet'!?
            Lability_SwitchName          = 'Corpnet','Internet';
        }
        @{
            NodeName  = 'APP1';
            IPAddress = '10.0.0.3';
            Role      = 'APP';
        }
        @{
            NodeName            = 'INET1';
            IPAddress           = '131.107.0.1';
            DnsServerAddress    = '127.0.0.1';
            DefaultGateway      = '';
            DnsConnectionSuffix = 'isp.example.com';
            Role                = 'INET';
            Lability_SwitchName = 'Internet';
        }
        @{
            NodeName       = 'CLIENT1';
            Role           = 'CLIENT';
            Lability_Media = 'Win81_x64_Enterprise_EN_Eval';
            <# Lability_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property #>
        }
        @{
            NodeName       = 'CLIENT2';
            Role           = 'CLIENT';
            Lability_Media = 'Win10_x64_Enterprise_EN_Eval';
            <# Lability_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property #>
        }
    );
    NonNodeData = @{
        Lability = @{
            EnvironmentPrefix = 'TLG-';
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

            <#
                If you are generating the .mof files on the host and/or you want Labilty to use the DSC
                resource versions/modules installed on the physical host, you should remove the 'DSCResource' key.
                Lability will then "just" copy all local DSC resources.
            #>
            DSCResource = @(
                ## Download published version from the PowerShell Gallery
                @{ Name = 'xComputerManagement'; RequiredVersion = '1.9.0.0'; Provider = 'PSGallery'; }
                ## If not specified, the provider defaults to the PSGallery.
                @{ Name = 'xSmbShare'; RequiredVersion = '2.0.0.0'; }
                @{ Name = 'xNetworking'; RequiredVersion = '3.2.0.0'; }
                @{ Name = 'xActiveDirectory'; MinimumVersion = '2.16.0.0'; }
                @{ Name = 'xDnsServer'; RequiredVersion = '1.7.0.0'; }
                @{ Name = 'xDhcpServer'; RequiredVersion = '1.5.0.0'; }
                ## The 'GitHub# provider can download modules directly from a GitHub repository, for example:
                ## @{ Name = 'Lability'; Provider = 'GitHub'; Owner = 'VirtualEngine'; Repository = 'Lability'; Branch = 'dev'; }
            );
        };
    };
};
