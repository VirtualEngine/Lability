Configuration Example {
    param (
        [Parameter(Mandatory)] [ValidateNotNull()] [PSCredential] $Credential
    )
    Import-DscResource -Module xComputerManagement, xNetworking, xActiveDirectory;
    Import-DscResource -Module cWaitForTcpPort, xSmbShare, PSDesiredStateConfiguration;
    Import-DscResource -Module xDHCPServer, xDNSServer;

    node $AllNodes.Where({$_.Role -in 'DC','APP','EDGE'}).NodeName {
        ## CLIENT1 is set to DHCP!
        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress;
            InterfaceAlias = $node.InterfaceAlias;
            DefaultGateway = $node.DefaultGateway;
            SubnetMask     = $node.SubnetMask;
            AddressFamily  = $node.AddressFamily;
        }

        xDnsServerAddress 'DNSClient' {
            Address        = $node.DnsServerAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily  = $node.AddressFamily
        }
    }

    node $AllNodes.Where({$true}).NodeName {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode = 'ApplyAndAutocorrect';
            CertificateID = $node.Thumbprint;
        }
        
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)';
            DisplayGroup = 'File and Printer Sharing';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction = 'Inbound';
            Access = 'Allow';
            State = 'Enabled';
            Profile = 'Any';
        }
    } #end nodes ALL
  
    node $AllNodes.Where({$_.Role -in 'DC'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object System.Management.Automation.PSCredential("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        xComputer 'Hostname' {
            Name = $node.NodeName;
        }
        
        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'AD-Domain-Services',
                'GPMC',
                'RSAT-AD-Tools'
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
                DependsOn = '[xComputer]Hostname';
            }
        }
        
        xADDomain ADDomain {
            DomainName = $node.DomainName;
            #DomainNetBiosName = $node.NetBIOSDomainName;
            SafemodeAdministratorPassword = $Credential;
            DomainAdministratorCredential = $Credential;
            DependsOn = '[WindowsFeature]ADDomainServices';
        }

        foreach ($feature in @(
                'DHCP',
                'RSAT-DHCP'
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
                DependsOn = '[xADDomain]ADDomain';
            }
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
            Router = '10.0.0.2';
            AddressFamily = 'IPv4';
            DependsOn = '[xDhcpServerScope]DhcpScope10_0_0_0';
        }
        
        xADUser User1 { 
            DomainName = $node.DomainName;
            DomainAdministratorCredential = $domainCredential;
            UserName = 'User1';
            Password = $Credential;
            Ensure = 'Present';
            DependsOn = '[xADDomain]ADDomain';
        }
    } #end nodes DC
    
    ## TODO: CLIENT1 does not support adding to the domain the xComputer resource
    node $AllNodes.Where({$_.Role -in 'APP','EDGE'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object System.Management.Automation.PSCredential("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        cWaitForTcpPort 'WaitForADDomain' {
            #Hostname = ($ConfigurationData.AllNodes | Where Role -eq 'DC1' | Select -First 1).IPAddress;
            Hostname = '10.0.0.1'; ## Used for debugging whilst DC01 was excluded from the config!
            Port = 389;
            RetryIntervalSec = 30;
            RetryCount = 10;
            DependsOn = '[xIPAddress]PrimaryIPAddress';
        }
        
        xComputer 'DomainMembership' {
            Name = $node.NodeName;
            DomainName = $node.DomainName;
            Credential = $domainCredential;
            DependsOn = '[cWaitForTcpPort]WaitForADDomain';
        }
    } #end nodes DomainJoined
    
    node $AllNodes.Where({$_.Role -in 'APP'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object System.Management.Automation.PSCredential("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);
        
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
            ChangeAccess = 'BUILTIN\Administrators';
            DependsOn = '[File]FilesFolder';
            Ensure = 'Present';
        }
    } #end nodes APP

    node $AllNodes.Where({$_.Role -in 'INET'}).NodeName {
        
        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress;
            InterfaceAlias = $node.InterfaceAlias;
            SubnetMask     = $node.SubnetMask;
            AddressFamily  = $node.AddressFamily;
        }

        xComputer 'Hostname' {
            Name = $node.NodeName;
        }

        xDnsServerAddress 'DNSClient' {
            Address        = $node.DnsServerAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily  = $node.AddressFamily
        }

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

    } #end nodes INET
}
