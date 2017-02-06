@{
    AllNodes = @(
        @{
            NodeName                    = '*';
            InterfaceAlias              = 'Ethernet';
            DefaultGateway              = '10.0.0.254';
            PrefixLength                = 24;
            AddressFamily               = 'IPv4';
            DnsServerAddress            = '10.0.0.1';
            PSDscAllowPlainTextPassword = $true;
            Lability_SwitchName         = 'Internal';
        }
        @{
            NodeName                    = 'NANO1';
            IPAddress                   = '10.0.0.10';
            Lability_Media              = '2016_x64_Datacenter_Nano_EN_Eval';
            Lability_ProcessorCount     = 2;
            Lability_StartupMemory      = 2GB;
            Lability_WarningMessage     = "Keyboard layout will be 'EN-US'";
        }
    );
    NonNodeData = @{
        Lability = @{
            DSCResource = @(
                @{ Name = 'xNetworking'; RequiredVersion = '3.2.0.0'; }
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '6.0.0.0'; }
            )
        };
    };
};
