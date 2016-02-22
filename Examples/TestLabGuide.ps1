Configuration TestLabGuide {
<#
    Requires the following custom DSC resources:
        xComputerManagement (v1.4.0.0 or later): https://github.com/PowerShell/xComputerManagement
        xNetworking/dev (v2.7.0.0 or later):     https://github.com/PowerShell/xNetworking
        xActiveDirectory (v2.9.0.0 or later):    https://github.com/PowerShell/xActiveDirectory
        xSmbShare (v1.1.0.0 or later):           https://github.com/PowerShell/xSmbShare
        xDhcpServer (v1.3.0 or later):           https://github.com/PowerShell/xDhcpServer
        xDnsServer (v1.5.0 or later):            https://github.com/PowerShell/xDnsServer
#>
    param (
        [Parameter()] [ValidateNotNull()] [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')
    )
    Import-DscResource -Module xComputerManagement, xNetworking, xActiveDirectory;
    Import-DscResource -Module xSmbShare, PSDesiredStateConfiguration;
    Import-DscResource -Module xDHCPServer, xDnsServer;

    node $AllNodes.Where({$true}).NodeName {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode = 'ApplyOnly';
            CertificateID = $node.Thumbprint;
        }

        if (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
            xIPAddress 'PrimaryIPAddress' {
                IPAddress      = $node.IPAddress;
                InterfaceAlias = $node.InterfaceAlias;
                SubnetMask     = $node.SubnetMask;
                AddressFamily  = $node.AddressFamily;
            }

            if (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {
                xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                    InterfaceAlias = $node.InterfaceAlias;
                    Address = $node.DefaultGateway;
                    AddressFamily = $node.AddressFamily;
                }
            }
            
            if (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {
                xDnsServerAddress 'PrimaryDNSClient' {
                    Address        = $node.DnsServerAddress;
                    InterfaceAlias = $node.InterfaceAlias;
                    AddressFamily  = $node.AddressFamily;
                }
            }
            
            if (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
                xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                    InterfaceAlias = $node.InterfaceAlias;
                    ConnectionSpecificSuffix = $node.DnsConnectionSuffix;
                }
            }
            
        } #end if IPAddress
        
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction = 'Inbound';
            Action = 'Allow';
            Enabled = 'True';
            Profile = 'Any';
        }

        xFirewall 'FPS-ICMP6-ERQ-In' {
            Name = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction = 'Inbound';
            Action = 'Allow';
            Enabled = 'True';
            Profile = 'Any';
        }
    } #end nodes ALL
  
    node $AllNodes.Where({$_.Role -in 'DC'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        xComputer 'Hostname' {
            Name = $node.NodeName;
        }
        
        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'AD-Domain-Services',
                'GPMC',
                'RSAT-AD-Tools',
                'DHCP',
                'RSAT-DHCP'
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
            }
        }
        
        xADDomain 'ADDomain' {
            DomainName = $node.DomainName;
            SafemodeAdministratorPassword = $Credential;
            DomainAdministratorCredential = $Credential;
            DependsOn = '[WindowsFeature]ADDomainServices';
        }

        xDhcpServerAuthorization 'DhcpServerAuthorization' {
            Ensure = 'Present';
            DependsOn = '[WindowsFeature]DHCP','[xADDomain]ADDomain';
        }
        
        xDhcpServerScope 'DhcpScope10_0_0_0' {
            Name = 'Corpnet';
            IPStartRange = '10.0.0.100';
            IPEndRange = '10.0.0.200';
            SubnetMask = '255.255.255.0';
            LeaseDuration = '00:08:00';
            State = 'Active';
            AddressFamily = 'IPv4';
            DependsOn = '[WindowsFeature]DHCP';
        }

        xDhcpServerOption 'DhcpScope10_0_0_0_Option' {
            ScopeID = '10.0.0.0';
            DnsDomain = 'corp.contoso.com';
            DnsServerIPAddress = '10.0.0.1';
            #Router = '10.0.0.2';
            AddressFamily = 'IPv4';
            DependsOn = '[xDhcpServerScope]DhcpScope10_0_0_0';
        }
        
        xADUser User1 { 
            DomainName = $node.DomainName;
            UserName = 'User1';
            Description = 'Lability Test Lab user';
            Password = $Credential;
            Ensure = 'Present';
            DependsOn = '[xADDomain]ADDomain';
        }
        
        xADGroup DomainAdmins {
            GroupName = 'Domain Admins';
            MembersToInclude = 'User1';
            DependsOn = '[xADUser]User1';
        }
        
        xADGroup EnterpriseAdmins {
            GroupName = 'Enterprise Admins';
            GroupScope = 'Universal';
            MembersToInclude = 'User1';
            DependsOn = '[xADUser]User1';
        }

    } #end nodes DC
    
    ## INET1 is on the 'Internet' subnet and not domain-joined
    node $AllNodes.Where({$_.Role -in 'CLIENT','APP','EDGE'}).NodeName {
        ## Flip credential into username@domain.com
        $upn = '{0}@{1}' -f $Credential.UserName, $node.DomainName;
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($upn, $Credential.Password);

        xComputer 'DomainMembership' {
            Name = $node.NodeName;
            DomainName = $node.DomainName;
            Credential = $domainCredential;
        }
    } #end nodes DomainJoined
    
    node $AllNodes.Where({$_.Role -in 'APP'}).NodeName {
        ## Flip credential into username@domain.com
        $upn = '{0}@{1}' -f $Credential.UserName, $node.DomainName;
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($upn, $Credential.Password);

        foreach ($feature in @(
                'Web-Default-Doc',
                'Web-Dir-Browsing',
                'Web-Http-Errors',
                'Web-Static-Content',
                'Web-Http-Logging',
                'Web-Stat-Compression',
                'Web-Filtering',
                'Web-Mgmt-Tools',
                'Web-Mgmt-Console')) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
                DependsOn = '[xComputer]DomainMembership';
            }
        }

        File 'FilesFolder' {
            DestinationPath = 'C:\Files';
            Type = 'Directory';
        }

        File 'ExampleTxt' {
            DestinationPath = 'C:\Files\Example.txt'
            Type = 'File';
            Contents = 'This is a shared file.';
            DependsOn = '[File]FilesFolder';
        }

        xSmbShare 'FilesShare' {
            Name = 'Files';
            Path = 'C:\Files';
            ChangeAccess = 'CORP\User1';
            DependsOn = '[File]FilesFolder';
            Ensure = 'Present';
        }
    } #end nodes APP

    node $AllNodes.Where({$_.Role -in 'EDGE'}).NodeName {

        xIPAddress 'SecondaryIPAddress' {
            IPAddress      = $node.SecondaryIPAddress;
            InterfaceAlias = $node.SecondaryInterfaceAlias;
            SubnetMask     = $node.SecondarySubnetMask;
            AddressFamily  = $node.AddressFamily;
        }

        xDnsServerAddress 'SecondaryDNSClient' {
            Address        = $node.SecondaryDnsServerAddress;
            InterfaceAlias = $node.SecondaryInterfaceAlias;
            AddressFamily  = $node.AddressFamily
        }
        
        xDnsConnectionSuffix 'SecondarySuffix' {
            InterfaceAlias = $node.SecondaryInterfaceAlias;
            ConnectionSpecificSuffix = $node.SecondaryDnsConnectionSuffix;
        }

    }

    node $AllNodes.Where({$_.Role -in 'INET'}).NodeName {
        
        foreach ($feature in @(
                'Web-Default-Doc',
                'Web-Dir-Browsing',
                'Web-Http-Errors',
                'Web-Static-Content',
                'Web-Http-Logging',
                'Web-Stat-Compression',
                'Web-Filtering',
                'Web-Mgmt-Tools',
                'Web-Mgmt-Console',
                'DNS',
                'DHCP',
                'RSAT-DNS-Server',
                'RSAT-DHCP')) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
            }
        }

        xDhcpServerScope 'DhcpScope137_107_0_0' {
            Name = 'Corpnet';
            IPStartRange = '131.107.0.100';
            IPEndRange = '131.107.0.150';
            SubnetMask = '255.255.255.0';
            LeaseDuration = '00:08:00';
            State = 'Active';
            AddressFamily = 'IPv4';
            DependsOn = '[WindowsFeature]DHCP';
        }

        xDhcpServerOption 'DhcpScope137_107_0_0_Option' {
            ScopeID = '131.107.0.0';
            DnsDomain = 'isp.example.com';
            DnsServerIPAddress = '131.107.0.1';
            Router = '131.107.0.1';
            AddressFamily = 'IPv4';
            DependsOn = '[xDhcpServerScope]DhcpScope137_107_0_0';
        }

        File 'NCSI' {
            DestinationPath = 'C:\inetpub\wwwroot\ncsi.txt';
            Type = 'File';
            Contents = 'Microsoft NCSI';
            DependsOn = '[WindowsFeature]WebDefaultDoc';
        }
        
        xDnsServerPrimaryZone 'isp_example_com' {
            Name = 'isp.example.com';
            DependsOn = '[WindowsFeature]DNS';
        }
        
        xDnsRecord 'inet1_isp_example_com' {
            Name = 'inet1';
            Target = '131.107.0.1';
            Zone = 'isp.example.com';
            Type = 'ARecord';
            DependsOn = '[xDnsServerPrimaryZone]isp_example_com';
        }
        
        xDnsServerPrimaryZone 'contoso_com' {
            Name = 'contoso.com';
            DependsOn = '[WindowsFeature]DNS';
        }
        
        xDnsRecord 'edge1_contoso_com' {
            Name = 'edge1';
            Target = '131.107.0.2';
            Zone = 'contoso.com';
            Type = 'ARecord';
            DependsOn = '[xDnsServerPrimaryZone]contoso_com';
        }
        
        xDnsServerPrimaryZone 'msftncsi_com' {
            Name = 'msftncsi.com';
            DependsOn = '[WindowsFeature]DNS';
        }
        
        xDnsRecord 'www_msftncsi_com' {
            Name = 'www';
            Target = '131.107.0.1';
            Zone = 'msftncsi.com';
            Type = 'ARecord';
            DependsOn = '[xDnsServerPrimaryZone]msftncsi_com';
        }
        
        xDnsRecord 'dns_msftncsi_com' {
            Name = 'dns';
            Target = '131.107.255.255';
            Zone = 'msftncsi.com';
            Type = 'ARecord';
            DependsOn = '[xDnsServerPrimaryZone]msftncsi_com';
        }

    } #end nodes INET

} #end Configuration Example
