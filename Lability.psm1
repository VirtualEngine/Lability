#Requires -RunAsAdministrator

## Set the global defaults
$labDefaults = @{
    ModuleRoot                = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
    ModuleName                = 'Lability';
    ConfigurationData         = 'Config';
    HostConfigFilename        = 'HostDefaults.json';
    VmConfigFilename          = 'VmDefaults.json';
    MediaConfigFilename       = 'Media.json';
    CustomMediaConfigFilename = 'CustomMedia.json';
    LegacyMediaPath           = 'LegacyMedia';
    DscResourceDirectory      = 'DSCResources';
    RepositoryUri             = 'https://www.powershellgallery.com/api/v2/package';
    DismVersion               = $null;
}

#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $labDefaults.ModuleRoot -ChildPath $PSUICulture)) {
    $culture = $PSUICulture
}
$importLocalizedDataParams = @{
    BindingVariable = 'localized';
    Filename        = 'Lability.Resources.psd1';
    BaseDirectory   = $moduleRoot;
    UICulture       = $culture;
}
Import-LocalizedData @importLocalizedDataParams;
#endregion LocalizedData

## Import the \Src files. This permits loading of the module's functions for unit testing, without having to unload/load the module.
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include *.ps1 -Exclude '*.Tests.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        # https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
        . ([System.Management.Automation.ScriptBlock]::Create(
                [System.IO.File]::ReadAllText($_.FullName)
            ));
    }

## Deploy builtin certificates to %ALLUSERSPROFILE%\PSLab
$moduleConfigPath = Join-Path -Path $moduleRoot -ChildPath 'Config';
$allUsersConfigPath = Join-Path -Path $env:AllUsersProfile -ChildPath "$($labDefaults.ModuleName)\Certificates\";
[ref] $null = New-Directory -Path $allUsersConfigPath;
Get-ChildItem -Path $moduleConfigPath -Include *.cer, *.pfx -Recurse | ForEach-Object {
    if (-not (Test-Path -Path (Join-Path -Path $allUsersConfigPath -ChildPath $_.Name))) {
        Write-Verbose -Message ('Updating certificate ''{0}''.' -f $_.FullName);
        Copy-Item -Path $_ -Destination $allUsersConfigPath;
    }
}

## Create the credential check scriptblock
$credentialCheckScriptBlock = {
    ## Only prompt if -Password is not specified. This works around the credential pop-up regardless of the ParameterSet!
    if ($PSCmdlet.ParameterSetName -eq 'PSCredential') {
        Get-Credential -Message $localized.EnterLocalAdministratorPassword -UserName 'LocalAdministrator';
    }
}

## Store the BitLocker full drive encryption status (used by Disable-BitLockerFDV and Assert-BitLockerFDV functions)
$fdvDenyWriteAccessPath = 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE'
$fdvDenyWriteAccess = (Get-ItemProperty -Path $fdvDenyWriteAccessPath -Name 'FDVDenyWriteAccess' -ErrorAction SilentlyContinue).FDVDenyWriteAccess -as [System.Boolean]

## Load the call stack logging setting referenced by Write-Verbose
$labDefaults['CallStackLogging'] = (Get-LabHostDefault).EnableCallStackLogging -eq $true;

## Ensure we load the required DISM module version
Import-DismModule;
