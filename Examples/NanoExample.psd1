@{
    AllNodes = @(
        @{
            NodeName = '*';
            InterfaceAlias = 'Ethernet';
            DefaultGateway = '10.0.0.254';
            SubnetMask = 24;
            AddressFamily = 'IPv4';
            DnsServerAddress = '10.0.0.1';
            PSDscAllowPlainTextPassword = $true;
            Lability_SwitchName = 'Internal';
        }
        @{
            NodeName = 'NANO1';
            IPAddress = '10.0.0.10';
            Lability_Media = '2016_x64_Standard_Nano_EN_Eval';
            Lability_ProcessorCount = 2;
            Lability_StartupMemory = 2GB;
            Lability_WarningMessage = "Keyboard layout will be 'EN-US'";
        }
    );
    NonNodeData = @{
        Lability = @{
            DSCResource = @(
                @{ Name = 'xNetworking'; MinimumVersion = '2.5.0.0'; }
                @{ Name = 'xPSDesiredStateConfiguration'; MinimumVersion = '3.7.0.0'; }
            )
        };
    };
};
