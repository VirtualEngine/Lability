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
            NodeName = 'NANOCONTAINER1';
            IPAddress = '10.0.0.10';
            Lability_Media = '2016_x64_Standard_Nano_Container_EN_Eval';
            Lability_ProcessorCount = 2;
            Lability_StartupMemory = 2GB;
            Lability_WarningMessage = "Keyboard layout will be 'EN-US'";
        }
    );
    NonNodeData = @{
        Lability = @{
            Media = (
                @{
                    ## This media is a replica of the default '2016_x64_Standard_Nano_EN_Eval' media
                    ## with the additional 'Microsoft-NanoServer-Compute-Package' package added.
                    Id = '2016_x64_Standard_Nano_Container_EN_Eval';
                    Filename = '2016_x64_EN_Eval.iso';
                    Description = 'Windows Server 2016 Standard Nano 64bit English Evaluation';
                    Architecture = 'x64';
                    ImageName = 'Windows Server 2016 SERVERSTANDARDNANO';
                    MediaType = 'ISO';
                    OperatingSystem = 'Windows';
                    Uri = 'http://download.microsoft.com/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO';
                    Checksum = '18A4F00A675B0338F3C7C93C4F131BEB';
                    CustomData = @{
                        SetupComplete = 'CoreCLR';
                        PackagePath = '\NanoServer\Packages';
                        PackageLocale = 'en-US';
                        WimPath = '\NanoServer\NanoServer.wim';
                        Package = @(
                            'Microsoft-NanoServer-Guest-Package',
                            'Microsoft-NanoServer-DSC-Package',
                            'Microsoft-NanoServer-Containers-Package'
                        )
                    }
                }
            )
            DSCResource = @(
                @{ Name = 'xNetworking'; MinimumVersion = '2.5.0.0'; }
                @{ Name = 'xPSDesiredStateConfiguration'; MinimumVersion = '3.7.0.0'; }
            )
        };
    };
};
