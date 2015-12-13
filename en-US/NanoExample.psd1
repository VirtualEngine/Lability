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
            
        }
        @{
            NodeName = 'NANO1';
            IPAddress = '10.0.0.10';
            VirtualEngineLab_Media = '2016TP4_x64_NANO_EN';
            VirtualEngineLab_ProcessorCount = 2;
            VirtualEngineLab_StartupMemory = 2GB;
            VirtualEngineLab_WarningMessage = "Keyboard layout will be 'EN-US'";
        }
    );
    NonNodeData = @{
        VirtualEngineLab = @{
            Network = @(
                @{ Name = 'Corpnet'; Type = 'Internal'; }
            );
        };
    };
};
