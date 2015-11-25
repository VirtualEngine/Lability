#Requires -RunAsAdministrator

## Set the global defaults
$labDefaults = @{
    ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path;
    ModuleName = 'VirtualEngineLab';
    ConfigurationData = 'Config';
    HostConfigFilename = 'HostDefaults.json';
    VmConfigFilename = 'VmDefaults.json';
    MediaConfigFilename = 'Media.json';
    CustomMediaConfigFilename = 'CustomMedia.json';
    DscResourceDirectory = 'DSCResources';
}

## Import localisation strings
Import-LocalizedData -BindingVariable localized -FileName Resources.psd1;

## Import the \Lib files. This permits loading of the module's functions for unit testing, without having to unload/load the module.
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleLibPath = Join-Path -Path $moduleRoot -ChildPath 'Lib';
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleLibPath,$moduleSrcPath -Include *.ps1 -Exclude '*.Tests.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }

## Deploy builtin certificates to %ALLUSERSPROFILE%\PSLab
$moduleConfigPath = Join-Path -Path $moduleRoot -ChildPath 'Config';
$allUsersConfigPath = Join-Path -Path $env:AllUsersProfile -ChildPath "$($labDefaults.ModuleName)\Certificates\";
[ref] $null = NewDirectory -Path $allUsersConfigPath;
Get-ChildItem -Path $moduleConfigPath -Include *.cer,*.pfx -Recurse | % {
    Write-Verbose ('Updating certificate ''{0}''.' -f $_.FullName);
    Copy-Item -Path $_ -Destination $allUsersConfigPath;
}
