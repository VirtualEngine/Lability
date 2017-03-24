function Get-LabStatus {
<#
    .SYNOPSIS
        Queries computers' LCM state to determine whether an existing DSC configuration has applied.
    .EXAMPLE
        Get-LabStatus -ComputerName CONTROLLER, XENAPP
        Queries the CONTROLLER and XENAPP computers' LCM state.
    .EXAMPLE
        Get-LabStatus -ComputerName CONTROLLER, EXCHANGE -Credential (Get-Credential)
        Prompts for credentials to connect to the CONTROLLER and EXCHANGE computers to query the LCM state.
    .EXAMPLE
        Get-LabStatus -ConfigurationData .\TestLabGuide.psd1 -Credential (Get-Credential)
        Prompts for credentials to connect to the computers defined in the DSC configuration document (.psd1) and query
        the LCM state.
    .EXAMPLE
        Get-LabStatus -ConfigurationData .\TestLabGuide.psd1 -PreferNodeProperty IPAddress -Credential (Get-Credential)
        Prompts for credentials to connect to the computers by their IPAddress node property as defined in the DSC
        configuration document (.psd1) and query the LCM state.
#>
    [CmdletBinding()]
    param (
        ## Connect to the computer name(s) specified.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ComputerName')]
        [System.String[]]
        $ComputerName,

        ## Connect to all nodes defined in the a Desired State Configuration (DSC) configuration (.psd1) document.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ConfigurationData')]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Use an alternative property for the computer name to connect to. Use this option when a configuration document's
        ## node name does not match the computer name, e.g. use the IPAddress property instead of the NodeName property.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ConfigurationData')]
        [System.String]
        $PreferNodeProperty,

        ## Specifies the application name in the connection. The default value of the ApplicationName parameter is WSMAN.
        ## The complete identifier for the remote endpoint is in the following format:
        ##
        ## <transport>://<server>:<port>/<ApplicationName>
        ##
        ## For example: `http://server01:8080/WSMAN`
        ##
        ## Internet Information Services (IIS), which hosts the session, forwards requests with this endpoint to the
        ## specified application. This default setting of WSMAN is appropriate for most uses. This parameter is designed
        ## to be used if many computers establish remote connections to one computer that is running Windows PowerShell.
        ## In this case, IIS hosts Web Services for Management (WS-Management) for efficiency.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $ApplicationName,

        ## Specifies the authentication mechanism to be used at the server. The acceptable values for this parameter are:
        ##
        ## - Basic. Basic is a scheme in which the user name and password are sent in clear text to the server or proxy.
        ## - Default. Use the authentication method implemented by the WS-Management protocol. This is the default.  -
        ## Digest. Digest is a challenge-response scheme that uses a server-specified data string for the challenge.  -
        ## Kerberos. The client computer and the server mutually authenticate by using Kerberos certificates.  -
        ## Negotiate. Negotiate is a challenge-response scheme that negotiates with the server or proxy to determine the
        ## scheme to use for authentication. For example, this parameter value allows for negotiation to determine
        ## whether the Kerberos protocol or NTLM is used.  - CredSSP. Use Credential Security Support Provider (CredSSP)
        ## authentication, which lets the user delegate credentials. This option is designed for commands that run on one
        ## remote computer but collect data from or run additional commands on other remote computers.
        ##
        ## Caution: CredSSP delegates the user credentials from the local computer to a remote computer. This practice
        ## increases the security risk of the remote operation. If the remote computer is compromised, when credentials
        ## are passed to it, the credentials can be used to control the network session.
        ##
        ## Important: If you do not specify the Authentication parameter,, the Test-WSMan request is sent to the remote
        ## computer anonymously, without using authentication. If the request is made anonymously, it returns no
        ## information that is specific to the operating-system version. Instead, this cmdlet displays null values for
        ## the operating system version and service pack level (OS: 0.0.0 SP: 0.0).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None','Default','Digest','Negotiate','Basic','Kerberos','ClientCertificate','Credssp')]
        [System.String] $Authentication = 'Default',

        ## Specifies the digital public key certificate (X509) of a user account that has permission to perform this
        ## action. Enter the certificate thumbprint of the certificate.
        ##
        ## Certificates are used in client certificate-based authentication. They can be mapped only to local user
        ## accounts; they do not work with domain accounts.
        ##
        ## To get a certificate thumbprint, use the Get-Item or Get-ChildItem command in the Windows PowerShell Cert:
        ## drive.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $CertificateThumbprint,

        ## Specifies the port to use when the client connects to the WinRM service. When the transport is HTTP, the
        ## default port is 80. When the transport is HTTPS, the default port is 443.
        ##
        ## When you use HTTPS as the transport, the value of the ComputerName parameter must match the server's
        ## certificate common name (CN).
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Int32] $Port,

        ## Specifies that the Secure Sockets Layer (SSL) protocol is used to establish a connection to the remote
        ## computer. By default, SSL is not used.
        ##
        ## WS-Management encrypts all the Windows PowerShell content that is transmitted over the network. The UseSSL
        ## parameter lets you specify the additional protection of HTTPS instead of HTTP. If SSL is not available on the
        ## port that is used for the connection, and you specify this parameter, the command fails.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $UseSSL,

        ## Credential used to connect to the remote computer.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    begin {

        ## Authentication might not be explicitly passed, add it so it gets splatted
        $PSBoundParameters['Authentication'] = $Authentication;

    }
    process {

        if ($PSCmdlet.ParameterSetName -eq 'ConfigurationData') {

            $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };

            foreach ($node in $nodes) {

                $nodeName = $node.NodeName;
                if (($PSBoundParameters.ContainsKey('PreferNodeProperty')) -and
                    (-not [System.String]::IsNullOrEmpty($node[$PreferNodeProperty]))) {

                    $nodeName = $node[$PreferNodeProperty];
                }

                $ComputerName += $nodeName;
            }
        }

        $sessions = Get-PSSession;
        $activeSessions = @();
        $inactiveSessions = @();

        ## Remove parameters that aren't supported by Get-PSSession, Test-WSMan and New-PSSession
        [ref] $null = $PSBoundParameters.Remove('ComputerName');
        [ref] $null = $PSBoundParameters.Remove('ConfigurationData');
        [ref] $null = $PSBoundParameters.Remove('PreferNodeProperty');

        foreach ($computer in $computerName) {

            $session = $sessions | Where-Object { $_.ComputerName -eq $computer -and $_.State -eq 'Opened' } | Select-Object -First 1;

            if (-not $session) {

                WriteVerbose -Message ($localized.TestingWinRMConnection -f $computer);
                if (-not (Test-WSMan -ComputerName $computer -ErrorAction SilentlyContinue @PSBoundParameters)) {

                    WriteWarning -Message ($localized.ComputerNotReachableWarning -f $computer);
                    $inactiveSessions += $computer;
                }
                else {

                    WriteVerbose -Message ($localized.ConnectingRemoteSession -f $computer);
                    $activeSessions += New-PSSession -ComputerName $computer @PSBoundParameters;
                }
            }
            else {

                WriteVerbose ($localized.ReusingExistingRemoteSession -f $computer);
                $activeSessions += $session
            }

        } #end foreach computer

        WriteVerbose -Message ($localized.QueryingActiveSessions -f ($activeSessions.ComputerName -join "','"));
        $results = Invoke-Command -Session $activeSessions -ScriptBlock { Get-DscLocalConfigurationManager | Select-Object -Property LCMVersion,LCMState; };

        foreach ($computer in $ComputerName) {

            if ($computer -in $inactiveSessions) {

                $labState = [PSCustomObject] @{
                    ComputerName = $inactiveSession;
                    LCMVersion = '';
                    LCMState = 'Unknown';
                    Completed = $false;
                }
                Write-Output -InputObject $labState;
            }
            else {

                $result = $results | Where-Object { $_.PSComputerName -eq $computer };
                $labState = [PSCustomObject] @{
                    ComputerName = $result.PSComputerName;
                    LCMVersion = $result.LCMVersion;
                    LCMState = $result.LCMState;
                    Completed = $result.LCMState -eq 'Idle';
                }
                Write-Output -InputObject $labState;
            }

        } #end foreach computer

    } #end process
} #end function
