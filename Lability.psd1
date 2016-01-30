@{
    RootModule = 'Lability.psm1';
    ModuleVersion = '0.9.2';
    GUID = '374126b4-f3d4-471d-b25e-767f69ee03d0';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'The Lability module contains cmdlets for provisioning Hyper-V test lab and development environments.';
    PowerShellVersion = '4.0';
    FunctionsToExport = '*-*';
    CmdletsToExport = '*-*';
    VariablesToExport = '*';
    AliasesToExport = '*';
    FileList = '';
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Lability','Powershell','Development','Test','Lab','TestLab');
            LicenseUri = 'https://github.com/VirtualEngine/Lability/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/Lability';
            IconUri = 'https://raw.githubusercontent.com/VirtualEngine/Lability/master/Lability.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
