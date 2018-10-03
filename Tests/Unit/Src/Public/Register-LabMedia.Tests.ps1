#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Register-LabMedia' {

    InModuleScope -ModuleName $moduleName {

        $testMediaParams = @{
            Id = 'TestId';
            Uri = 'http://contoso.com/testmedia';
            Architecture = 'x64';
        }
        $testCustomMedia = @(
            [PSObject] $testMediaParams,
            [PSObject] @{ Id = 'TestId2'; Uri = 'http://contoso.com/testmedia'; Architecture = 'x64'; }
        )

        It 'Throws when custom media type is "ISO" and OperatingSystem is "Linux"' {
            { Register-LabMedia @testMediaParams -OperatingSystem Linux -MediaType ISO } | Should Throw;
        }

        It 'Throws when custom media type is "WIM" and OperatingSystem is "Linux"' {
            { Register-LabMedia @testMediaParams -OperatingSystem Linux -MediaType WIM } | Should Throw;
        }

        It 'Throws when custom media type is "ISO" and "ImageName" is not specified' {
            { Register-LabMedia @testMediaParams -MediaType ISO } | Should Throw;
        }

        It 'Throws when custom media type is "WIM" and "ImageName" is not specified' {
            { Register-LabMedia @testMediaParams -MediaType WIM } | Should Throw;
        }

        It 'Throws when custom media already exists and "Force" is not specified' {
            Mock Resolve-LabMedia { return $testCustomMedia[0]; }

            { Register-LabMedia @testMediaParams -MediaType VHD -WarningAction SilentlyContinue } | Should Throw;
        }

        It 'Does not throw when custom media type is "VHD" and "ImageName" is not specified' {
            Mock Resolve-LabMedia { }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { };
            Mock Set-ConfigurationData { }

            { Register-LabMedia @testMediaParams -MediaType VHD -WarningAction SilentlyContinue } | Should Not Throw;
        }

        It 'Does not throw when custom media already exists and "Force" is specified' {
            Mock Resolve-LabMedia { return $testCustomMedia[0]; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { return $testCustomMedia; };
            Mock Set-ConfigurationData { }

            { Register-LabMedia @testMediaParams -MediaType VHD -Force -WarningAction SilentlyContinue } | Should Not Throw;
        }

        It 'Converts custom media from a JSON file/Uri' {
            $customMediaPath = "$TestDrive\CustomMedia.json";
            $customMedia = @'
                {
                    "Id": "LabilityCustomMediaTest",
                    "Filename": "WIN10_x64_ENT_RS4_EN_Eval.iso",
                    "Description": "Windows 10 64bit Enterprise 1804 English Evaluation",
                    "Architecture": "x64",
                    "ImageName": "Windows 10 Enterprise Evaluation",
                    "MediaType": "ISO",
                    "OperatingSystem": "Windows",
                    "Uri": "https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso",
                    "Checksum": "89F6B3079B3669560D29F3C4BE9CC74D"
                }
'@
            Set-Content -Path $customMediaPath -Value $customMedia -Force;
            Mock Resolve-LabMedia { }
            Mock Set-ConfigurationData { }

            $media = Register-LabMedia -FromUri $customMediaPath;

            $media.Id | Should Be 'LabilityCustomMediaTest';
        }

    } #end InModuleScope

} #end describe
