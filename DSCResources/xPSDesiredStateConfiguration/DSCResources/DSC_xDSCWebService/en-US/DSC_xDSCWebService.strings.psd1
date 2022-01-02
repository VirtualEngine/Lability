# culture="en-US"
ConvertFrom-StringData -StringData @'
    ThrowCertificateThumbprint           = CertificateThumbprint must contain a certificate thumbprint, or "AllowUnencryptedTraffic" to opt-out from being secure.
    ThrowUseSecurityBestPractice         = Error: Cannot use best practice security settings with unencrypted traffic. Please set UseSecurityBestPractices to $false or use a certificate to encrypt pull server traffic.
    FindCertificateBySubjectMultiple     = More than one certificate found with subject containing {0} and using template "{1}".
    FindCertificateBySubjectNotFound     = Certificate not found with subject containing {0} and using template "{1}".
    IISInstallationPathNotFound          = IIS installation path not found
    IISWebAdministrationAssemblyNotFound = IIS version of Microsoft.Web.Administration.dll not found
    ConfigFirewallDeprecated             = The support for configuring firewall rules is deprecated. Please set ConfigureFirewall to false and use the Firewall resource from NetworkingDSC module to configure required firewall rules.
    ThrowApplicationPoolNotFound         = IIS Application pool "{0}" not found.
'@
