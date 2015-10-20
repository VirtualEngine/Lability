function NewUnattendXml {
<#
    .SYNOPSIS
       Creates a Windows unattended installation file.
    .DESCRIPTION
       Creates an unattended Windows 8/2012 installation file that will configure
       an operating system deployed from a WIM file, deploy the operating system
       and ensure that Powershell's desired state configuration (DSC) is configured
       to pull its configuration from the specified pull server.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        # Local Administrator Password
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.string] $Password,
        # Computer name
        [Parameter()] [System.String] $ComputerName,
        # Product Key
        [Parameter()] [ValidatePattern('^[A-Z0-9]{5,5}-[A-Z0-9]{5,5}-[A-Z0-9]{5,5}-[A-Z0-9]{5,5}-[A-Z0-9]{5,5}$')] [System.String] $ProductKey,
        # Input Locale
        [Parameter(ValueFromPipelineByPropertyName)] [System.String] $InputLocale = 'en-US',
        # System Locale
        [Parameter(ValueFromPipelineByPropertyName)] [System.String] $SystemLocale = 'en-US',
        # User Locale
        [Parameter(ValueFromPipelineByPropertyName)] [System.String] $UserLocale = 'en-US',
        # UI Language
        [Parameter(ValueFromPipelineByPropertyName)] [System.String] $UILanguage = 'en-US',
        # Timezone
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [System.String] $Timezone,
        # Registered Owner
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()] [System.String] $RegisteredOwner = 'Virtual Engine',
        # Registered Organization
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()] [System.String] $RegisteredOrganization = 'Virtual Engine',
        # TODO: Execute synchronous commands during OOBE pass
        ## Array of hashtables with Description, Order and Path keys
        [Parameter(ValueFromPipelineByPropertyName=$true)] [System.Collections.Hashtable[]] $ExecuteCommand
    )
    begin {
        $templateUnattendXml = [xml] @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></component>
		<component name="Microsoft-Windows-Deployment" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></component>
		<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></component>
		<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></component>
    </settings>
    <settings pass="oobeSystem">
		<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
		<component name="Microsoft-Windows-International-Core" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<OOBE>
                <HideEULAPage>true</HideEULAPage>
				<HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
				<SkipUserOOBE>true</SkipUserOOBE>
				<SkipMachineOOBE>true</SkipMachineOOBE>
            </OOBE>
            <TimeZone>GMT Standard Time</TimeZone>
            <UserAccounts>
                <AdministratorPassword>
                    <Value></Value>
                    <PlainText>false</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <RegisteredOrganization>Virtual Engine</RegisteredOrganization>
            <RegisteredOwner>Virtual Engine</RegisteredOwner>
			<VisualEffects>
				<SystemDefaultBackgroundColor>2</SystemDefaultBackgroundColor>
			</VisualEffects>
        </component>
		<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<OOBE>
                <HideEULAPage>true</HideEULAPage>
				<HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
				<SkipUserOOBE>true</SkipUserOOBE>
				<SkipMachineOOBE>true</SkipMachineOOBE>
            </OOBE>
            <TimeZone>GMT Standard Time</TimeZone>
            <UserAccounts>
                <AdministratorPassword>
                    <Value></Value>
                    <PlainText>false</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <RegisteredOrganization>Virtual Engine</RegisteredOrganization>
            <RegisteredOwner>Virtual Engine</RegisteredOwner>
			<VisualEffects>
				<SystemDefaultBackgroundColor>2</SystemDefaultBackgroundColor>
			</VisualEffects>
        </component>
    </settings>
</unattend>
'@
        [xml] $unattendXml = $templateUnattendXml;

        $templateRunCommandXml = @'
<RunSynchronousCommand wcm:action="add">
    <Description>Description</Description>
    <Order>1</Order>
    <Path></Path>
</RunSynchronousCommand>
'@
    }
    process {
        foreach ($setting in $unattendXml.Unattend.Settings) {
            foreach($component in $setting.Component) {
                if ($setting.'Pass' -eq 'specialize' -and $component.'Name' -eq 'Microsoft-Windows-Deployment') {
                    if ($ExecuteCommand -ne $null -or $ExecuteCommand.Length -gt 0) {
                        $commandOrder = 1;
                        foreach ($synchronousCommand in $ExecuteCommand) {
                            $runSynchronousElement = $component.AppendChild($unattendXml.CreateElement('RunSynchronous','urn:schemas-microsoft-com:unattend'));
                            $syncCommandElement = $runSynchronousElement.AppendChild($unattendXml.CreateElement('RunSynchronousCommand','urn:schemas-microsoft-com:unattend'));
                            [ref] $null = $syncCommandElement.SetAttribute('action','http://schemas.microsoft.com/WMIConfig/2002/State','add');
                            $syncCommandDescriptionElement = $syncCommandElement.AppendChild($unattendXml.CreateElement('Description','urn:schemas-microsoft-com:unattend'));
                            $syncCommandDescriptionTextNode = $syncCommandDescriptionElement.AppendChild($unattendXml.CreateTextNode($synchronousCommand['Description']));
                            $syncCommandOrderElement = $syncCommandElement.AppendChild($unattendXml.CreateElement('Order','urn:schemas-microsoft-com:unattend'));
                            $syncCommandOrderTextNode = $syncCommandOrderElement.AppendChild($unattendXml.CreateTextNode($commandOrder));
                            $syncCommandPathElement = $syncCommandElement.AppendChild($unattendXml.CreateElement('Path','urn:schemas-microsoft-com:unattend'));
                            $syncCommandPathTextNode = $syncCommandPathElement.AppendChild($unattendXml.CreateTextNode($synchronousCommand['Path']));
                            $commandOrder++;
                        }
                    }
                }
                if (($setting.'Pass' -eq 'specialize') -and ($component.'Name' -eq 'Microsoft-Windows-Shell-Setup')) {
                    if ($ComputerName) {
                        $computerNameElement = $component.AppendChild($unattendXml.CreateElement('ComputerName','urn:schemas-microsoft-com:unattend'));
                        $computerNameTextNode = $computerNameElement.AppendChild($unattendXml.CreateTextNode($ComputerName));
                    }
                    if ($ProductKey) {
                        $productKeyElement = $component.AppendChild($unattendXml.CreateElement('ProductKey','urn:schemas-microsoft-com:unattend'));
                        $productKeyTextNode = $productKeyElement.AppendChild($unattendXml.CreateTextNode($ProductKey.ToUpper()));
                    }
                }

                if (($setting.'Pass' -eq 'oobeSystem') -and ($component.'Name' -eq 'Microsoft-Windows-International-Core')) {
                    $component.InputLocale = $InputLocale;
                    $component.SystemLocale = $SystemLocale;
                    $component.UILanguage = $UILanguage;
                    $component.UserLocale = $UserLocale;
                }

                if (($setting.'Pass' -eq 'oobeSystem') -and ($component.'Name' -eq 'Microsoft-Windows-Shell-Setup')) {
                    $component.TimeZone = $Timezone;
                    $concatenatedPassword = '{0}AdministratorPassword' -f $Password;
                    $component.UserAccounts.AdministratorPassword.Value = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($concatenatedPassword));
                    $component.RegisteredOrganization = $RegisteredOrganization;
                    $component.RegisteredOwner = $RegisteredOwner;
                } 
            } #end foreach setting.Component
        } #end foreach unattendXml.Unattend.Settings
        Write-Output $unattendXml;
    } #end process
} #end function NewUnattendXml
