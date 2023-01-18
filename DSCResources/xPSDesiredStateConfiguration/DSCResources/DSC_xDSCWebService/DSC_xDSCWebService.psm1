$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the shared modules
Import-Module -Name (Join-Path -Path $modulePath `
    -ChildPath (Join-Path -Path 'xPSDesiredStateConfiguration.Common' `
        -ChildPath 'xPSDesiredStateConfiguration.Common.psm1'))
Import-Module -Name (Join-Path -Path $modulePath `
    -ChildPath (Join-Path -Path 'xPSDesiredStateConfiguration.PSWSIIS' `
        -ChildPath 'xPSDesiredStateConfiguration.PSWSIIS.psm1'))
Import-Module -Name (Join-Path -Path $modulePath `
    -ChildPath (Join-Path -Path 'xPSDesiredStateConfiguration.Firewall' `
        -ChildPath 'xPSDesiredStateConfiguration.Firewall.psm1'))
Import-Module -Name (Join-Path -Path $modulePath `
    -ChildPath (Join-Path -Path 'xPSDesiredStateConfiguration.Security' `
        -ChildPath 'xPSDesiredStateConfiguration.Security.psm1'))

# Import Localization Strings
$script:localizedData = Get-LocalizedData -ResourceName 'DSC_xDSCWebService'

<#
    .SYNOPSIS
        Get the state of the DSC Web Service.

    .PARAMETER EndpointName
        Prefix of the WCF SVC file.

    .PARAMETER ApplicationPoolName
        The IIS ApplicationPool to use for the Pull Server. If not specified a
        pool with name 'PSWS' will be created.

    .PARAMETER CertificateSubject
        The subject of the Certificate in CERT:\LocalMachine\MY\ for Pull Server.

    .PARAMETER CertificateTemplateName
        The certificate Template Name of the Certificate in CERT:\LocalMachine\MY\
        for Pull Server.

    .PARAMETER CertificateThumbPrint
        The thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server.

    .PARAMETER ConfigureFirewall
        Enable incomming firewall exceptions for the configured DSC Pull Server
        port. Defaults to true.

    .PARAMETER DisableSecurityBestPractices
        A list of exceptions to the security best practices to apply.

    .PARAMETER Enable32BitAppOnWin64
        Enable the DSC Pull Server to run in a 32-bit process on a 64-bit operating
        system.

    .PARAMETER UseSecurityBestPractices
        Ensure that the DSC Pull Server is created using security best practices.
#>
function Get-TargetResource
{
    [CmdletBinding(DefaultParameterSetName = 'CertificateThumbPrint')]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EndpointName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ApplicationPoolName = $DscWebServiceDefaultAppPoolName,

        [Parameter(ParameterSetName = 'CertificateSubject')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateSubject,

        [Parameter(ParameterSetName = 'CertificateSubject')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateTemplateName = 'WebServer',

        [Parameter(ParameterSetName = 'CertificateThumbPrint')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateThumbPrint,

        [Parameter()]
        [System.Boolean]
        $ConfigureFirewall = $true,

        [Parameter()]
        [ValidateSet('SecureTLSProtocols')]
        [System.String[]]
        $DisableSecurityBestPractices,

        [Parameter()]
        [System.Boolean]
        $Enable32BitAppOnWin64 = $false,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Boolean]
        $UseSecurityBestPractices
    )

    <#
        If Certificate Subject is not specified then a value for
        CertificateThumbprint must be explicitly set instead. The
        Mof schema doesn't allow for a mandatory parameter in a parameter set.
    #>
    if ($PScmdlet.ParameterSetName -eq 'CertificateThumbPrint' `
        -and $PSBoundParameters.ContainsKey('CertificateThumbPrint') -ne $true)
    {
        throw $script:localizedData.ThrowCertificateThumbprint
    }

    $webSite = Get-Website -Name $EndpointName

    if ($webSite)
    {
        Write-Verbose -Message "PullServer is deployed at '$EndpointName'."

        $Ensure = 'Present'
        $acceptSelfSignedCertificates = $false

        # Get Full Path for Web.config file
        $webConfigFullPath = Join-Path -Path $website.physicalPath -ChildPath 'web.config'

        # Get module and configuration path
        $modulePath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'ModulePath'
        $configurationPath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'ConfigurationPath'
        $registrationKeyPath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'RegistrationKeyPath'

        # Get database path
        switch ((Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'dbprovider'))
        {
            'ESENT'
            {
                $databasePath = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'dbconnectionstr' | Split-Path -Parent
            }

            'System.Data.OleDb'
            {
                $connectionString = Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'dbconnectionstr'

                if ($connectionString -match 'Data Source=(.*)\\Devices\.mdb')
                {
                    $databasePath = $Matches[0]
                }
                else
                {
                    $databasePath = $connectionString
                }
            }
        }

        $urlPrefix = $website.bindings.Collection[0].protocol + '://'

        $ipProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()

        if ($ipProperties.DomainName)
        {
            $fqdn = '{0}.{1}' -f $ipProperties.HostName, $ipProperties.DomainName
        }
        else
        {
            $fqdn = $ipProperties.HostName
        }

        $iisPort = $website.bindings.Collection[0].bindingInformation.Split(':')[1]

        $svcFileName = (Get-ChildItem -Path $website.physicalPath -Filter '*.svc').Name

        $serverUrl = $urlPrefix + $fqdn + ':' + $iisPort + '/' + $svcFileName

        $webBinding = Get-WebBinding -Name $EndpointName

        if ((Test-IISSelfSignedModuleEnabled -EndpointName $EndpointName))
        {
            $acceptSelfSignedCertificates = $true
        }

        $ConfigureFirewall = Test-PullServerFirewallConfiguration -Port $iisPort
        $ApplicationPoolName = $webSite.applicationPool
        $physicalPath = $website.physicalPath
        $state = $webSite.state
    }
    else
    {
        Write-Verbose -Message "No website found with name '$EndpointName'."
        $Ensure = 'Absent'
    }

    $output = @{
        EndpointName                 = $EndpointName
        ApplicationPoolName          = $ApplicationPoolName
        Port                         = $iisPort
        PhysicalPath                 = $physicalPath
        State                        = $state
        DatabasePath                 = $databasePath
        ModulePath                   = $modulePath
        ConfigurationPath            = $configurationPath
        DSCServerUrl                 = $serverUrl
        Ensure                       = $Ensure
        RegistrationKeyPath          = $registrationKeyPath
        AcceptSelfSignedCertificates = $acceptSelfSignedCertificates
        UseSecurityBestPractices     = $UseSecurityBestPractices
        DisableSecurityBestPractices = $DisableSecurityBestPractices
        Enable32BitAppOnWin64        = $Enable32BitAppOnWin64
        ConfigureFirewall            = $ConfigureFirewall
    }

    if ($CertificateThumbPrint -eq 'AllowUnencryptedTraffic')
    {
        Write-Verbose -Message 'Current PullServer configuration allows unencrypted traffic.'
        $output.Add('CertificateThumbPrint', $certificateThumbPrint)
    }
    else
    {
        $certificate = ([System.Array] (Get-ChildItem -Path 'Cert:\LocalMachine\My\')) |
            Where-Object -FilterScript {
                $_.Thumbprint -eq $webBinding.CertificateHash
            }

        # Try to parse the Certificate Template Name. The property is not available on all Certificates.
        $actualCertificateTemplateName = ''
        $certificateTemplateProperty = $certificate.Extensions | Where-Object -FilterScript {
            $_.Oid.FriendlyName -eq 'Certificate Template Name'
        }

        if ($null -ne $certificateTemplateProperty)
        {
            $actualCertificateTemplateName = $certificateTemplateProperty.Format($false)
        }

        $output.Add('CertificateThumbPrint', $webBinding.CertificateHash)
        $output.Add('CertificateSubject', $certificate.Subject)
        $output.Add('CertificateTemplateName', $actualCertificateTemplateName)
    }

    return $output
}

<#
    .SYNOPSIS
        Set the state of the DSC Web Service.

    .PARAMETER EndpointName
        Prefix of the WCF SVC file.

    .PARAMETER AcceptSelfSignedCertificates
        Specifies is self-signed certs will be accepted for client authentication.

    .PARAMETER ApplicationPoolName
        The IIS ApplicationPool to use for the Pull Server. If not specified a
        pool with name 'PSWS' will be created.

    .PARAMETER CertificateSubject
        The subject of the Certificate in CERT:\LocalMachine\MY\ for Pull Server.

    .PARAMETER CertificateTemplateName
        The certificate Template Name of the Certificate in CERT:\LocalMachine\MY\
        for Pull Server.

    .PARAMETER CertificateThumbPrint
        The thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server.

    .PARAMETER ConfigurationPath
        The location on the disk where the Configuration is stored.

    .PARAMETER ConfigureFirewall
        Enable incomming firewall exceptions for the configured DSC Pull Server
        port. Defaults to true.

    .PARAMETER DatabasePath
        The location on the disk where the database is stored.

    .PARAMETER DisableSecurityBestPractices
        A list of exceptions to the security best practices to apply.

    .PARAMETER Enable32BitAppOnWin64
        Enable the DSC Pull Server to run in a 32-bit process on a 64-bit operating
        system.

    .PARAMETER Ensure
        Specifies if the DSC Web Service should be installed.

    .PARAMETER PhysicalPath
        The physical path for the IIS Endpoint on the machine (usually under inetpub).

    .PARAMETER Port
        The port number of the DSC Pull Server IIS Endpoint.

    .PARAMETER ModulePath
        The location on the disk where the Modules are stored.

    .PARAMETER RegistrationKeyPath
        The location on the disk where the RegistrationKeys file is stored.

    .PARAMETER SqlConnectionString
        The connection string to use to connect to the SQL server backend database.
        Required if SqlProvider is true.

    .PARAMETER SqlProvider
        Enable DSC Pull Server to use SQL server as the backend database.

    .PARAMETER State
        Specifies the state of the DSC Web Service.

    .PARAMETER UseSecurityBestPractices
        Ensure that the DSC Pull Server is created using security best practices.
#>
function Set-TargetResource
{
    [CmdletBinding(DefaultParameterSetName = 'CertificateThumbPrint')]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EndpointName,

        [Parameter()]
        [System.Boolean]
        $AcceptSelfSignedCertificates = $true,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ApplicationPoolName = $DscWebServiceDefaultAppPoolName,

        [Parameter(ParameterSetName = 'CertificateSubject')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateSubject,

        [Parameter(ParameterSetName = 'CertificateSubject')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateTemplateName = 'WebServer',

        [Parameter(ParameterSetName = 'CertificateThumbPrint')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateThumbPrint,

        [Parameter()]
        [System.String]
        $ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration",

        [Parameter()]
        [System.Boolean]
        $ConfigureFirewall = $true,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DatabasePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService",

        [Parameter()]
        [ValidateSet('SecureTLSProtocols')]
        [System.String[]]
        $DisableSecurityBestPractices,

        [Parameter()]
        [System.Boolean]
        $Enable32BitAppOnWin64 = $false,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules",

        [Parameter()]
        [System.String]
        $PhysicalPath = "$env:SystemDrive\inetpub\$EndpointName",

        [Parameter()]
        [ValidateRange(1, 65535)]
        [System.UInt32]
        $Port = 8080,

        [Parameter()]
        [System.String]
        $RegistrationKeyPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService",

        [Parameter()]
        [System.String]
        $SqlConnectionString,

        [Parameter()]
        [System.Boolean]
        $SqlProvider = $false,

        [Parameter()]
        [ValidateSet('Started', 'Stopped')]
        [System.String]
        $State = 'Started',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Boolean]
        $UseSecurityBestPractices
    )

    <#
        If Certificate Subject is not specified then a value for CertificateThumbprint
        must be explicitly set instead. The Mof schema doesn't allow for a mandatory parameter
        in a parameter set.
    #>
    if ($PScmdlet.ParameterSetName -eq 'CertificateThumbPrint' -and $PSBoundParameters.ContainsKey('CertificateThumbPrint') -ne $true)
    {
        throw $script:localizedData.ThrowCertificateThumbprint
    }

    # Find a certificate that matches the Subject and Template Name
    if ($PSCmdlet.ParameterSetName -eq 'CertificateSubject')
    {
        $certificateThumbPrint = Find-CertificateThumbprintWithSubjectAndTemplateName -Subject $CertificateSubject -TemplateName $CertificateTemplateName
    }

    # Check parameter values
    if ($UseSecurityBestPractices -and ($CertificateThumbPrint -eq 'AllowUnencryptedTraffic'))
    {
        throw $script:localizedData.ThrowUseSecurityBestPractice
    }

    if ($ConfigureFirewall)
    {
        Write-Warning -Message $script:localizedData.ConfigFirewallDeprecated
    }

    <#
        If the Pull Server Site should be bound to the non default AppPool
        ensure that the AppPool already exists
    #>
    if ('Present' -eq $Ensure `
            -and $ApplicationPoolName -ne $DscWebServiceDefaultAppPoolName `
            -and (-not (Test-Path -Path "IIS:\AppPools\$ApplicationPoolName")))
    {
        throw ($script:localizedData.ThrowApplicationPoolNotFound -f $ApplicationPoolName)
    }

    # Initialize with default values
    $pathPullServer = "$pshome\modules\PSDesiredStateConfiguration\PullServer"
    $jet4provider = 'System.Data.OleDb'
    $jet4database = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$DatabasePath\Devices.mdb;'
    $eseprovider = 'ESENT'
    $esedatabase = "$DatabasePath\Devices.edb"

    $cultureInfo = Get-Culture
    $languagePath = $cultureInfo.IetfLanguageTag
    $language = $cultureInfo.TwoLetterISOLanguageName

    # The two letter iso languagename is not actually implemented in the source path, it's always 'en'
    if (-not (Test-Path -Path "$pathPullServer\$languagePath\Microsoft.Powershell.DesiredStateConfiguration.Service.Resources.dll"))
    {
        $languagePath = 'en'
    }

    $os = Get-OSVersion

    $isBlue = $false

    if ($os.Major -eq 6 -and $os.Minor -eq 3)
    {
        $isBlue = $true
    }

    $isDownlevelOfBlue = $false

    if ($os.Major -eq 6 -and $os.Minor -lt 3)
    {
        $isDownlevelOfBlue = $true
    }

    # Use Pull Server values for defaults
    $webConfigFileName = "$pathPullServer\PSDSCPullServer.config"
    $svcFileName = "$pathPullServer\PSDSCPullServer.svc"
    $pswsMofFileName = "$pathPullServer\PSDSCPullServer.mof"
    $pswsDispatchFileName = "$pathPullServer\PSDSCPullServer.xml"

    if (($Ensure -eq 'Absent'))
    {
        if (Test-Path -LiteralPath "IIS:\Sites\$EndpointName")
        {
            # Get the port number for the Firewall rule
            Write-Verbose -Message "Processing bindings for '$EndpointName'."
            $portList = Get-WebBinding -Name $EndpointName | ForEach-Object -Process {
                [System.Text.RegularExpressions.Regex]::Match($_.bindingInformation, ':(\d+):').Groups[1].Value
            }

            # There is a web site, but there shouldn't be one
            Write-Verbose -Message "Removing web site '$EndpointName'."
            Remove-PSWSEndpoint -SiteName $EndpointName

            $portList | ForEach-Object -Process { Remove-PullServerFirewallConfiguration -Port $_ }
        }

        # We are done here, all stuff below is for 'Present'
        return
    }

    Write-Verbose -Message 'Create the IIS endpoint'
    New-PSWSEndpoint `
        -site $EndpointName `
        -Path $PhysicalPath `
        -cfgfile $webConfigFileName `
        -port $Port `
        -appPool $ApplicationPoolName `
        -applicationPoolIdentityType LocalSystem `
        -app $EndpointName `
        -svc $svcFileName `
        -mof $pswsMofFileName `
        -dispatch $pswsDispatchFileName `
        -asax "$pathPullServer\Global.asax" `
        -dependentBinaries  "$pathPullServer\Microsoft.Powershell.DesiredStateConfiguration.Service.dll" `
        -language $language `
        -dependentMUIFiles  "$pathPullServer\$languagePath\Microsoft.Powershell.DesiredStateConfiguration.Service.Resources.dll" `
        -certificateThumbPrint $certificateThumbPrint `
        -Enable32BitAppOnWin64 $Enable32BitAppOnWin64 `

    switch ($Ensure)
    {
        'Present'
        {
            if ($ConfigureFirewall)
            {
                Write-Verbose -Message "Enabling firewall exception for port $port."
                Add-PullServerFirewallConfiguration -Port $port
            }
        }

        'Absent'
        {
            Write-Verbose -Message "Disabling firewall exception for port $port."
            Remove-PullServerFirewallConfiguration -Port $port
        }
    }

    Update-LocationTagInApplicationHostConfigForAuthentication -WebSite $EndpointName -Authentication 'anonymous'
    Update-LocationTagInApplicationHostConfigForAuthentication -WebSite $EndpointName -Authentication 'basic'
    Update-LocationTagInApplicationHostConfigForAuthentication -WebSite $EndpointName -Authentication 'windows'

    if ($SqlProvider)
    {
        Write-Verbose -Message 'Set values into the web.config that define the SQL Connection'
        Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbprovider' -Value $jet4provider
        Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbconnectionstr' -Value $SqlConnectionString

        if ($isBlue)
        {
            Set-BindingRedirectSettingInWebConfig -Path $PhysicalPath
        }
    }
    elseif ($isBlue)
    {
        Write-Verbose -Message 'Set values into the web.config that define the repository for BLUE OS'
        Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbprovider' -Value $eseprovider
        Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbconnectionstr' -Value $esedatabase

        Set-BindingRedirectSettingInWebConfig -Path $PhysicalPath
    }
    else
    {
        if ($isDownlevelOfBlue)
        {
            Write-Verbose -Message 'Set values into the web.config that define the repository for non-BLUE Downlevel OS'
            $repository = Join-Path -Path $DatabasePath -ChildPath 'Devices.mdb'
            Copy-Item -Path "$pathPullServer\Devices.mdb" -Destination $repository -Force

            Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbprovider' -Value $jet4provider
            Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbconnectionstr' -Value $jet4database
        }
        else
        {
            Write-Verbose -Message 'Set values into the web.config that define the repository later than BLUE OS'
            Write-Verbose -Message 'Only ESENT is supported on Windows Server 2016'

            Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbprovider' -Value $eseprovider
            Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'dbconnectionstr' -Value $esedatabase
        }
    }

    Write-Verbose -Message 'Pull Server: Set values into the web.config that indicate the location of repository, configuration, modules'

    # Create the application data directory calculated above
    $null = New-Item -Path $DatabasePath -ItemType 'directory' -Force
    $null = New-Item -Path $ConfigurationPath -ItemType 'directory' -Force

    Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'ConfigurationPath' -Value $configurationPath

    $null = New-Item -Path $ModulePath -ItemType 'directory' -Force

    Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'ModulePath' -Value $ModulePath

    $null = New-Item -Path $RegistrationKeyPath -ItemType 'directory' -Force

    Set-AppSettingsInWebconfig -Path $PhysicalPath -Key 'RegistrationKeyPath' -Value $registrationKeyPath

    if ($AcceptSelfSignedCertificates)
    {
        Write-Verbose -Message 'Accepting self signed certificates from incoming hosts'
        Enable-IISSelfSignedModule -EndpointName $EndpointName -Enable32BitAppOnWin64:$Enable32BitAppOnWin64
    }
    else
    {
        Disable-IISSelfSignedModule -EndpointName $EndpointName
    }

    if ($UseSecurityBestPractices)
    {
        Set-UseSecurityBestPractice -DisableSecurityBestPractices $DisableSecurityBestPractices
    }
}

<#
    .SYNOPSIS
        Test the state of the DSC Web Service.

    .PARAMETER EndpointName
        Prefix of the WCF SVC file.

    .PARAMETER AcceptSelfSignedCertificates
        Specifies is self-signed certs will be accepted for client authentication.

    .PARAMETER ApplicationPoolName
        The IIS ApplicationPool to use for the Pull Server. If not specified a
        pool with name 'PSWS' will be created.

    .PARAMETER CertificateSubject
        The subject of the Certificate in CERT:\LocalMachine\MY\ for Pull Server.

    .PARAMETER CertificateTemplateName
        The certificate Template Name of the Certificate in CERT:\LocalMachine\MY\
        for Pull Server.

    .PARAMETER CertificateThumbPrint
        The thumbprint of the Certificate in CERT:\LocalMachine\MY\ for Pull Server.

    .PARAMETER ConfigurationPath
        The location on the disk where the Configuration is stored.

    .PARAMETER ConfigureFirewall
        Enable incomming firewall exceptions for the configured DSC Pull Server
        port. Defaults to true.

    .PARAMETER DatabasePath
        The location on the disk where the database is stored.

    .PARAMETER DisableSecurityBestPractices
        A list of exceptions to the security best practices to apply.

    .PARAMETER Enable32BitAppOnWin64
        Enable the DSC Pull Server to run in a 32-bit process on a 64-bit operating
        system.

    .PARAMETER Ensure
        Specifies if the DSC Web Service should be installed.

    .PARAMETER PhysicalPath
        The physical path for the IIS Endpoint on the machine (usually under inetpub).

    .PARAMETER Port
        The port number of the DSC Pull Server IIS Endpoint.

    .PARAMETER ModulePath
        The location on the disk where the Modules are stored.

    .PARAMETER RegistrationKeyPath
        The location on the disk where the RegistrationKeys file is stored.

    .PARAMETER SqlConnectionString
        The connection string to use to connect to the SQL server backend database.
        Required if SqlProvider is true.

    .PARAMETER SqlProvider
        Enable DSC Pull Server to use SQL server as the backend database.

    .PARAMETER State
        Specifies the state of the DSC Web Service.

    .PARAMETER UseSecurityBestPractices
        Ensure that the DSC Pull Server is created using security best practices.
#>
function Test-TargetResource
{
    [CmdletBinding(DefaultParameterSetName = 'CertificateThumbPrint')]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EndpointName,

        [Parameter()]
        [System.Boolean]
        $AcceptSelfSignedCertificates,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ApplicationPoolName = $DscWebServiceDefaultAppPoolName,

        [Parameter(ParameterSetName = 'CertificateSubject')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateSubject,

        [Parameter(ParameterSetName = 'CertificateSubject')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateTemplateName = 'WebServer',

        [Parameter(ParameterSetName = 'CertificateThumbPrint')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CertificateThumbPrint,

        [Parameter()]
        [System.String]
        $ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration",

        [Parameter()]
        [System.Boolean]
        $ConfigureFirewall = $true,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DatabasePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService",

        [Parameter()]
        [ValidateSet('SecureTLSProtocols')]
        [System.String[]]
        $DisableSecurityBestPractices,

        [Parameter()]
        [System.Boolean]
        $Enable32BitAppOnWin64 = $false,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules",

        [Parameter()]
        [System.String]
        $PhysicalPath = "$env:SystemDrive\inetpub\$EndpointName",

        [Parameter()]
        [ValidateRange(1, 65535)]
        [System.UInt32]
        $Port = 8080,

        [Parameter()]
        [System.String]
        $RegistrationKeyPath,

        [Parameter()]
        [System.String]
        $SqlConnectionString,

        [Parameter()]
        [System.Boolean]
        $SqlProvider = $false,

        [Parameter()]
        [ValidateSet('Started', 'Stopped')]
        [System.String]
        $State = 'Started',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Boolean]
        $UseSecurityBestPractices
    )

    <#
        If Certificate Subject is not specified then a value for CertificateThumbprint
        must be explicitly set instead. The Mof schema doesn't allow for a mandatory
        parameter in a parameter set.
    #>
    if ($PScmdlet.ParameterSetName -eq 'CertificateThumbPrint' -and $PSBoundParameters.ContainsKey('CertificateThumbPrint') -ne $true)
    {
        throw $script:localizedData.ThrowCertificateThumbprint
    }

    $desiredConfigurationMatch = $true

    $website = Get-Website -Name $EndpointName
    $stop = $true

    :WebSiteTests do
    {
        Write-Verbose -Message 'Check Ensure.'

        if (($Ensure -eq 'Present' -and $null -eq $website))
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "The Website '$EndpointName' is not present."
            break
        }

        if (($Ensure -eq 'Absent' -and $null -ne $website))
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "The Website '$EndpointName' is present but should not be."
            break
        }

        if (($Ensure -eq 'Absent' -and $null -eq $website))
        {
            $desiredConfigurationMatch = $true
            Write-Verbose -Message "The Website '$EndpointName' is not present as requested."
            break
        }

        # The other case is: Ensure and exist, we continue with more checks
        Write-Verbose -Message 'Check Port.'
        $actualPort = $website.bindings.Collection[0].bindingInformation.Split(':')[1]

        if ($Port -ne $actualPort)
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "Port for the Website '$EndpointName' does not match the desired state."
            break
        }

        Write-Verbose -Message 'Check Application Pool.'

        if ($ApplicationPoolName -ne $website.applicationPool)
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "Currently bound application pool '$($website.applicationPool)' does not match the desired state '$ApplicationPoolName'."
            break
        }

        Write-Verbose -Message 'Check Binding.'
        $actualCertificateHash = $website.bindings.Collection[0].certificateHash
        $websiteProtocol = $website.bindings.collection[0].Protocol

        Write-Verbose -Message 'Checking firewall rule settings.'
        $ruleExists = Test-PullServerFirewallConfiguration -Port $Port

        if ($ruleExists -and -not $ConfigureFirewall)
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "Firewall rule exists for $Port and should not. Configuration does not match the desired state."
            break
        }
        elseif (-not $ruleExists -and $ConfigureFirewall)
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "Firewall rule does not exist for $Port and should. Configuration does not match the desired state."
            break
        }

        switch ($PSCmdlet.ParameterSetName)
        {
            'CertificateThumbprint'
            {
                if ($CertificateThumbPrint -eq 'AllowUnencryptedTraffic' -and $websiteProtocol -ne 'http')
                {
                    $desiredConfigurationMatch = $false
                    Write-Verbose -Message "Website '$EndpointName' is not configured for http and does not match the desired state."
                    break WebSiteTests
                }

                if ($CertificateThumbPrint -ne 'AllowUnencryptedTraffic' -and $websiteProtocol -ne 'https')
                {
                    $desiredConfigurationMatch = $false
                    Write-Verbose -Message "Website '$EndpointName' is not configured for https and does not match the desired state."
                    break WebSiteTests
                }
            }

            'CertificateSubject'
            {
                $certificateThumbPrint = Find-CertificateThumbprintWithSubjectAndTemplateName -Subject $CertificateSubject -TemplateName $CertificateTemplateName

                if ($CertificateThumbPrint -ne $actualCertificateHash)
                {
                    $desiredConfigurationMatch = $false
                    Write-Verbose -Message "Certificate Hash for the Website '$EndpointName' does not match the desired state."
                    break WebSiteTests
                }
            }
        }

        Write-Verbose -Message 'Check Physical Path property.'

        if (Test-WebsitePath -EndpointName $EndpointName -PhysicalPath $PhysicalPath)
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "Physical Path of Website '$EndpointName' does not match the desired state."
            break
        }

        Write-Verbose -Message 'Check State.'

        if ($website.state -ne $State -and $null -ne $State)
        {
            $desiredConfigurationMatch = $false
            Write-Verbose -Message "The state of Website '$EndpointName' does not match the desired state."
            break
        }

        Write-Verbose -Message 'Get Full Path for Web.config file.'
        $webConfigFullPath = Join-Path -Path $website.physicalPath -ChildPath 'web.config'

        # Changed from -eq $false to -ne $true as $IsComplianceServer is never set. This section was always being skipped
        if ($IsComplianceServer -ne $true)
        {
            Write-Verbose -Message 'Check DatabasePath.'

            switch ((Get-WebConfigAppSetting -WebConfigFullPath $webConfigFullPath -AppSettingName 'dbprovider'))
            {
                'ESENT'
                {
                    $expectedConnectionString = "$DatabasePath\Devices.edb"
                }

                'System.Data.OleDb'
                {
                    $expectedConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$DatabasePath\Devices.mdb;"
                }

                default
                {
                    $expectedConnectionString = [System.String]::Empty
                }
            }

            if ($SqlProvider)
            {
                $expectedConnectionString = $SqlConnectionString
            }

            if (([System.String]::IsNullOrEmpty($expectedConnectionString)))
            {
                $desiredConfigurationMatch = $false
                Write-Verbose -Message "The DB provider does not have a valid value: 'ESENT' or 'System.Data.OleDb'."
                break
            }

            if (-not (Test-WebConfigAppSetting `
                -WebConfigFullPath $webConfigFullPath `
                -AppSettingName 'dbconnectionstr' `
                -ExpectedAppSettingValue $expectedConnectionString))
            {
                $desiredConfigurationMatch = $false
                break
            }

            Write-Verbose -Message 'Check ModulePath.'

            if ($ModulePath)
            {
                if (-not (Test-WebConfigAppSetting `
                    -WebConfigFullPath $webConfigFullPath `
                    -AppSettingName 'ModulePath' `
                    -ExpectedAppSettingValue $ModulePath))
                {
                    $desiredConfigurationMatch = $false
                    break
                }
            }

            Write-Verbose -Message 'Check ConfigurationPath.'

            if ($ConfigurationPath)
            {
                if (-not (Test-WebConfigAppSetting `
                    -WebConfigFullPath $webConfigFullPath `
                    -AppSettingName 'ConfigurationPath' `
                    -ExpectedAppSettingValue $configurationPath))
                {
                    $desiredConfigurationMatch = $false
                    break
                }
            }

            Write-Verbose -Message 'Check RegistrationKeyPath.'

            if ($RegistrationKeyPath)
            {
                if (-not (Test-WebConfigAppSetting `
                    -WebConfigFullPath $webConfigFullPath `
                    -AppSettingName 'RegistrationKeyPath' `
                    -ExpectedAppSettingValue $registrationKeyPath))
                {
                    $desiredConfigurationMatch = $false
                    break
                }
            }

            Write-Verbose -Message 'Check AcceptSelfSignedCertificates.'

            if ($AcceptSelfSignedCertificates)
            {
                Write-Verbose -Message "AcceptSelfSignedCertificates is enabled. Checking if module Selfsigned IIS module is configured for web site at '$webConfigFullPath'."

                if (Test-IISSelfSignedModuleInstalled)
                {
                    if (-not (Test-IISSelfSignedModuleEnabled -EndpointName $EndpointName))
                    {
                        Write-Verbose -Message 'Module not enabled in web site. Current configuration does not match the desired state.'
                        $desiredConfigurationMatch = $false
                        break
                    }
                    else
                    {
                        Write-Verbose -Message 'Module present in web site. Current configuration match the desired state.'
                    }
                }
                else
                {
                    Write-Verbose -Message 'Selfsigned module not installed in IIS. Current configuration does not match the desired state.'
                    $desiredConfigurationMatch = $false
                }
            }
            else
            {
                Write-Verbose -Message "AcceptSelfSignedCertificates is disabled. Checking if module Selfsigned IIS module is NOT configured for web site at '$webConfigFullPath'."

                if (Test-IISSelfSignedModuleInstalled)
                {
                    if (-not (Test-IISSelfSignedModuleEnabled -EndpointName $EndpointName))
                    {
                        Write-Verbose -Message 'Module not enabled in web site. Current configuration does match the desired state.'
                    }
                    else
                    {
                        Write-Verbose -Message 'Module present in web site. Current configuration does not match the desired state.'
                        $desiredConfigurationMatch = $false
                        break
                    }
                }
                else
                {
                    Write-Verbose -Message 'Selfsigned module not installed in IIS. Current configuration does match the desired state.'
                }
            }
        }

        Write-Verbose -Message 'Check UseSecurityBestPractices.'

        if ($UseSecurityBestPractices)
        {
            if (-not (Test-UseSecurityBestPractice -DisableSecurityBestPractices $DisableSecurityBestPractices))
            {
                $desiredConfigurationMatch = $false
                Write-Verbose -Message 'The state of security settings does not match the desired state.'
                break
            }
        }

        $stop = $false
    }
    while ($stop)

    return $desiredConfigurationMatch
}

<#
    .SYNOPSIS
        The function returns the OS version string detected by .NET.

    .DESCRIPTION
        The function returns the OS version which ahs been detected
        by .NET. The function is added so that the dectection of the OS
        is mockable in Pester tests.

    .OUTPUTS
        System.String. The operating system version.
#>
function Get-OSVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    # Moved to a function to allow for the behaviour to be mocked.
    return [System.Environment]::OSVersion.Version
}

#region IIS Utils

<#
    .SYNOPSIS
        Returns the configuration value for a module settings from
        web.config.

    .PARAMETER WebConfigFullPath
        The full path to the web.config.

    .PARAMETER ModuleName
        The name of the IIS module.

    .OUTPUTS
        System.String. The configured value.
#>
function Get-WebConfigModulesSetting
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebConfigFullPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName
    )

    $moduleValue = ''

    if (Test-Path -Path $WebConfigFullPath)
    {
        $webConfigXml = [Xml] (Get-Content -Path $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement()

        foreach ($item in $root.'system.webServer'.modules.add)
        {
            if ($item.name -eq $ModuleName)
            {
                $moduleValue = $item.name
                break
            }
        }
    }

    return $moduleValue
}

<#
    .SYNOPSIS
        Unlocks a specifc authentication configuration section for a IIS website.

    .PARAMETER WebSite
        The name of the website.

    .PARAMETER Authentication
        The authentication section which should be unlocked.

    .OUTPUTS
        System.String. The configured value.
#>
function Update-LocationTagInApplicationHostConfigForAuthentication
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebSite,

        [Parameter(Mandatory = $true)]
        [ValidateSet('anonymous', 'basic', 'windows')]
        [System.String]
        $Authentication
    )

    $webAdminSrvMgr = Get-IISServerManager
    $appHostConfig = $webAdminSrvMgr.GetApplicationHostConfiguration()

    $authenticationType = $Authentication + 'Authentication'
    $appHostConfigSection = $appHostConfig.GetSection("system.webServer/security/authentication/$authenticationType", $WebSite)
    $appHostConfigSection.OverrideMode = 'Allow'
    $webAdminSrvMgr.CommitChanges()
}

<#
    .SYNOPSIS
        Returns an instance of the Microsoft.Web.Administration.ServerManager.

    .OUTPUTS
        The server manager as Microsoft.Web.Administration.ServerManager.
#>
function Get-IISServerManager
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param ()

    $iisInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\INetStp' -Name InstallPath).InstallPath

    if (-not $iisInstallPath)
    {
        throw ($script:localizedData.IISInstallationPathNotFound)
    }

    $assyPath = Join-Path -Path $iisInstallPath -ChildPath 'Microsoft.Web.Administration.dll' -Resolve -ErrorAction:SilentlyContinue

    if (-not $assyPath)
    {
        throw ($script:localizedData.IISWebAdministrationAssemblyNotFound)
    }

    $assy = [System.Reflection.Assembly]::LoadFrom($assyPath)
    return [System.Activator]::CreateInstance($assy.FullName, 'Microsoft.Web.Administration.ServerManager').Unwrap()
}

<#
    .SYNOPSIS
        Tests if a module installation status is equal to an expected status.

    .PARAMETER WebConfigFullPath
        The full path to the web.config.

    .PARAMETER ModuleName
        The name of the IIS module for which the state should be checked.

    .PARAMETER ExpectedInstallationStatus
        Test if the module is installed ($true) or absent ($false).

    .OUTPUTS
        Returns true if the current installation status is equal to the expected
        installation status.
#>
function Test-WebConfigModulesSetting
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebConfigFullPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [Boolean]
        $ExpectedInstallationStatus
    )

    if (Test-Path -Path $WebConfigFullPath)
    {
        $webConfigXml = [Xml] (Get-Content -Path $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement()

        foreach ($item in $root.'system.webServer'.modules.add)
        {
            if ( $item.name -eq $ModuleName )
            {
                return $ExpectedInstallationStatus -eq $true
            }
        }
    }
    else
    {
        Write-Warning -Message "Test-WebConfigModulesSetting: web.config file not found at '$WebConfigFullPath'"
    }

    return $ExpectedInstallationStatus -eq $false
}

<#
    .SYNOPSIS
        Tests if a the currently configured path for a website is equal to a given
        path.

    .PARAMETER EndpointName
        The endpoint name (website name) to test.

    .PARAMETER PhysicalPath
        The full physical path to check.

    .OUTPUTS
        Returns true if the current installation status is equal to the expected
        installation status.
#>
function Test-WebsitePath
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $EndpointName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PhysicalPath
    )

    $pathNeedsUpdating = $false

    if ((Get-ItemProperty -Path "IIS:\Sites\$EndpointName" -Name physicalPath) -ne $PhysicalPath)
    {
        $pathNeedsUpdating = $true
    }

    return $pathNeedsUpdating
}

<#
    .SYNOPSIS
        Test if a currently configured app setting is equal to a given value.

    .PARAMETER WebConfigFullPath
        The full path to the web.config.

    .PARAMETER AppSettingName
        The app setting name to check.

    .PARAMETER ExpectedAppSettingValue
        The expected value.

    .OUTPUTS
        Returns true if the current value is equal to the expected value.
#>
function Test-WebConfigAppSetting
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebConfigFullPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AppSettingName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ExpectedAppSettingValue
    )

    $returnValue = $true

    if (Test-Path -Path $WebConfigFullPath)
    {
        $webConfigXml = [System.Xml.XmlDocument] (Get-Content -Path $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement()

        foreach ($item in $root.appSettings.add)
        {
            if ( $item.key -eq $AppSettingName )
            {
                break
            }
        }

        if ($item.value -ne $ExpectedAppSettingValue)
        {
            $returnValue = $false
            Write-Verbose -Message "The state of Web.Config AppSetting '$AppSettingName' does not match the desired state."
        }
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Helper function to Get the specified Web.Config App Setting.

    .PARAMETER WebConfigFullPath
        The full path to the web.config.

    .PARAMETER AppSettingName
        The app settings name to get the value for.

    .OUTPUTS
        The current app settings value.
#>
function Get-WebConfigAppSetting
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebConfigFullPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AppSettingName
    )

    $appSettingValue = ''

    if (Test-Path -Path $WebConfigFullPath)
    {
        $webConfigXml = [System.Xml.XmlDocument] (Get-Content -Path $WebConfigFullPath)
        $root = $webConfigXml.get_DocumentElement()

        foreach ($item in $root.appSettings.add)
        {
            if ($item.key -eq $AppSettingName)
            {
                $appSettingValue = $item.value
                break
            }
        }
    }

    return $appSettingValue
}

#endregion

#region IIS Selfsigned Certficate Module

New-Variable -Name iisSelfSignedModuleAssemblyName -Value 'IISSelfSignedCertModule.dll' -Option ReadOnly -Scope Script
New-Variable -Name iisSelfSignedModuleName -Value 'IISSelfSignedCertModule(32bit)' -Option ReadOnly -Scope Script

<#
    .SYNOPSIS
        Get a powershell command instance for appcmd.exe.

    .OUTPUTS
        The appcmd.exe as System.Management.Automation.CommandInfo.
#>
function Get-IISAppCmd
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.CommandInfo])]
    param ()

    Push-Location -Path "$env:windir\system32\inetsrv"
    $appCmd = Get-Command -Name '.\appcmd.exe' -CommandType 'Application' -ErrorAction 'Stop'
    Pop-Location
    $appCmd
}

<#
    .SYNOPSIS
        Tests if two files differ.

    .PARAMETER SourceFilePath
        Path to the source file.

    .PARAMETER DestinationFilePath
        Path to the destination file.

    .OUTPUTS
        Returns true if the two files differ.
#>
function Test-FilesDiffer
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-Path -PathType Leaf -LiteralPath $_ })]
        [System.String]
        $SourceFilePath,

        [Parameter()]
        [System.String]
        $DestinationFilePath
    )

    Write-Verbose -Message "Testing for file difference between '$SourceFilePath' and '$DestinationFilePath'."

    if (Test-Path -LiteralPath $DestinationFilePath)
    {
        if (Test-Path -LiteralPath $DestinationFilePath -PathType Container)
        {
            throw "$DestinationFilePath is a container (Directory) not a leaf (File)"
        }

        Write-Verbose -Message "Destination file already exists at '$DestinationFilePath'."
        $md5Dest = Get-FileHash -LiteralPath $destinationFilePath -Algorithm MD5
        $md5Src = Get-FileHash -LiteralPath $sourceFilePath -Algorithm MD5
        return $md5Src.Hash -ne $md5Dest.Hash
    }
    else
    {
        Write-Verbose -Message "Destination file does not exist at '$DestinationFilePath'."
        return $true
    }
}

<#
    .SYNOPSIS
        Tests if the IISSelfSignedModule module is installed.

    .OUTPUTS
        Returns true if the module is installed.
#>
function Test-IISSelfSignedModuleInstalled
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    ('' -ne ((& (Get-IISAppCmd) list config -section:system.webServer/globalModules) -like "*$iisSelfSignedModuleName*"))
}

<#
    .SYNOPSIS
        Install the IISSelfSignedModule module.

    .PARAMETER Enable32BitAppOnWin64
        If set install the module as 32bit module.
#>
function Install-IISSelfSignedModule
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Switch]
        $Enable32BitAppOnWin64
    )

    if ($Enable32BitAppOnWin64)
    {
        Write-Verbose -Message "Install-IISSelfSignedModule: Providing '$iisSelfSignedModuleAssemblyName' to run in a 32 bit process."

        $sourceFilePath = Join-Path -Path "$env:windir\SysWOW64\WindowsPowerShell\v1.0\Modules\PSDesiredStateConfiguration\PullServer" `
            -ChildPath $iisSelfSignedModuleAssemblyName
        $destinationFolderPath = "$env:windir\SysWOW64\inetsrv"

        Copy-Item -Path $sourceFilePath -Destination $destinationFolderPath -Force
    }

    if (Test-IISSelfSignedModuleInstalled)
    {
        Write-Verbose -Message "Install-IISSelfSignedModule: module '$iisSelfSignedModuleName' already installed."
    }
    else
    {
        Write-Verbose -Message "Install-IISSelfSignedModule: Installing module '$iisSelfSignedModuleName'."
        $sourceFilePath = Join-Path -Path "$env:windir\System32\WindowsPowerShell\v1.0\Modules\PSDesiredStateConfiguration\PullServer" `
            -ChildPath $iisSelfSignedModuleAssemblyName
        $destinationFolderPath = "$env:windir\System32\inetsrv"
        $destinationFilePath = Join-Path -Path $destinationFolderPath `
            -ChildPath $iisSelfSignedModuleAssemblyName

        if (Test-FilesDiffer -SourceFilePath $sourceFilePath -DestinationFilePath $destinationFilePath)
        {
            # Might fail if the DLL has already been loaded by the IIS from a former PullServer Deployment
            Copy-Item -Path $sourceFilePath -Destination $destinationFolderPath -Force
        }
        else
        {
            Write-Verbose -Message "Install-IISSelfSignedModule: module '$iisSelfSignedModuleName' already installed at '$destinationFilePath' with the correct version."
        }

        Write-Verbose -Message "Install-IISSelfSignedModule: globally activating module '$iisSelfSignedModuleName'."

        & (Get-IISAppCmd) install module /name:$iisSelfSignedModuleName /image:$destinationFilePath /add:false /lock:false
    }
}

<#
    .SYNOPSIS
        Enable the IISSelfSignedModule module for a specific website (endpoint).

    .PARAMETER EndpointName
        The endpoint (website) for which the module should be enabled.

    .PARAMETER Enable32BitAppOnWin64
        If set enable the module as a 32bit module.
#>
function Enable-IISSelfSignedModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EndpointName,

        [Parameter()]
        [Switch]
        $Enable32BitAppOnWin64
    )

    Write-Verbose -Message "Enable-IISSelfSignedModule: EndpointName '$EndpointName' and Enable32BitAppOnWin64 '$Enable32BitAppOnWin64'"

    Install-IISSelfSignedModule -Enable32BitAppOnWin64:$Enable32BitAppOnWin64
    $preConditionBitnessArgumentFor32BitInstall = ''

    if ($Enable32BitAppOnWin64)
    {
        $preConditionBitnessArgumentFor32BitInstall = '/preCondition:bitness32'
    }

    & (Get-IISAppCmd) add module /name:$iisSelfSignedModuleName /app.name:"$EndpointName/" $preConditionBitnessArgumentFor32BitInstall
}

<#
    .SYNOPSIS
        Disable the IISSelfSignedModule module for a specific website (endpoint).

    .PARAMETER EndpointName
        The endpoint (website) for which the module should be disabled.
#>
function Disable-IISSelfSignedModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$EndpointName
    )

    Write-Verbose -Message "Disable-IISSelfSignedModule: EndpointName '$EndpointName'"

    & (Get-IISAppCmd) delete module /name:$iisSelfSignedModuleName  /app.name:"$EndpointName/"
}

<#
    .SYNOPSIS
        Tests if the IISSelfSignedModule module is enabled for a website (endpoint).

    .PARAMETER EndpointName
        The endpoint (website) for which the status should be checked.

    .OUTPUTS
        Returns true if the module is enabled.
#>
function Test-IISSelfSignedModuleEnabled
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EndpointName
    )

    Write-Verbose -Message "Test-IISSelfSignedModuleEnabled: EndpointName '$EndpointName'"

    $webSite = Get-Website -Name $EndpointName

    if ($webSite)
    {
        $webConfigFullPath = Join-Path -Path $website.physicalPath -ChildPath 'web.config'
        Write-Verbose -Message "Test-IISSelfSignedModuleEnabled: web.confg path '$webConfigFullPath'"
        Test-WebConfigModulesSetting -WebConfigFullPath $webConfigFullPath -ModuleName $iisSelfSignedModuleName -ExpectedInstallationStatus $true
    }
    else
    {
        throw "Website '$EndpointName' not found"
    }
}

#endregion

#region Certificate Utils

<#
    .SYNOPSIS
        Returns a certificate thumbprint from a certificate with a matching subject.

    .DESCRIPTION
        Retreives a list of certificates from the a certificate store.
        From this list all certificates will be checked to see if they match the supplied Subject and Template.
        If one certificate is found the thumbrpint is returned. Otherwise an error is thrown.

    .PARAMETER Subject
        The subject of the certificate to find the thumbprint of.

    .PARAMETER TemplateName
        The template used to create the certificate to find the subject of.

    .PARAMETER Store
        The certificate store to retrieve certificates from.

    .NOTES
        Uses certificate Oid mapping:
        1.3.6.1.4.1.311.20.2 = Certificate Template Name
        1.3.6.1.4.1.311.21.7 = Certificate Template Information
#>
function Find-CertificateThumbprintWithSubjectAndTemplateName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Subject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TemplateName,

        [Parameter()]
        [System.String]
        $Store = 'Cert:\LocalMachine\My'
    )

    $filteredCertificates = @()

    foreach ($oidFriendlyName in 'Certificate Template Name', 'Certificate Template Information')
    {
        # Only get certificates created from a template otherwise filtering by subject and template name will cause errors
        [System.Array] $certificatesFromTemplates = (Get-ChildItem -Path $Store).Where{
            $_.Extensions.Oid.FriendlyName -contains $oidFriendlyName
        }

        switch ($oidFriendlyName)
        {
            'Certificate Template Name'
            {
                $templateMatchString = $TemplateName
            }

            'Certificate Template Information'
            {
                $templateMatchString = '^Template={0}' -f $TemplateName
            }
        }

        $filteredCertificates += $certificatesFromTemplates.Where{
            $_.Subject -eq $Subject -and
            $_.Extensions.Where{
                $_.Oid.FriendlyName -eq $oidFriendlyName
            }.Format($false) -match $templateMatchString
        }
    }

    if ($filteredCertificates.Count -eq 1)
    {
        return $filteredCertificates.Thumbprint
    }
    elseif ($filteredCertificates.Count -gt 1)
    {
        throw ($script:localizedData.FindCertificateBySubjectMultiple -f $Subject, $TemplateName)
    }
    else
    {
        throw ($script:localizedData.FindCertificateBySubjectNotFound -f $Subject, $TemplateName)
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource
