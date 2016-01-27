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
            #CertificateFile = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            #Thumbprint = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            PSDscAllowDomainUser = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            Lability_SwitchName = 'Corpnet';
            
        }
        @{
            NodeName = 'NANO1';
            IPAddress = '10.0.0.10';
            Lability_Media = '2016TP4_x64_NANO_EN';
            Lability_ProcessorCount = 2;
            Lability_StartupMemory = 2GB;
            Lability_WarningMessage = "Keyboard layout will be 'EN-US'";
        }
    );
    NonNodeData = @{
        Lability = @{
            Network = @(
                @{ Name = 'Corpnet'; Type = 'Internal'; }
            );
            DSCResource = @(
                @{ Name = 'xNetworking'; MinimumVersion = '2.5.0.0'; Provider = 'GitHub'; Owner = 'Powershell'; Branch = 'dev'; }
                @{ Name = 'xPSDesiredStateConfiguration'; MinimumVersion = '3.6.0.0'; Provider = 'GitHub'; Owner = 'Powershell'; Branch = 'dev'; }
            )
        };
    };
};
