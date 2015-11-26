@{
    RootModule = 'VirtualEngineLab.psm1';
    ModuleVersion = '0.8.8';
    GUID = '374126b4-f3d4-471d-b25e-767f69ee03d0';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2015 Virtual Engine Limited. All rights reserved.';
    Description = 'The VirtualEngineLab module contains cmdlets for provisioning Hyper-V test labs.';
    RequiredModules = @('BitsTransfer');
    PowerShellVersion = '4.0';
    FunctionsToExport = '*-*';
    CmdletsToExport = '*-*';
    VariablesToExport = '*';
    AliasesToExport = '*';
    FileList = '';
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Powershell','Test','Lab','TestLab');
            LicenseUri = 'https://github.com/VirtualEngine/Lab/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/Lab';
            IconUri = 'https://cdn.rawgit.com/VirtualEngine/Compression/38aa3a3c879fd6564d659d41bffe62ec91fb47ab/icon.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
