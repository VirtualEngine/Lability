#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\New-LabMedia' {

    InModuleScope -ModuleName $moduleName {

        $newLabMediaParams = @{
            Id = 'Test-Media';
            Filename = 'Test-Media.iso';
            Architecture = 'x86';
            MediaType = 'ISO';
            Uri = 'http://testmedia.com/test-media.iso';
            #CustomData = @{ };
        }

        It 'Does not throw with valid mandatory parameters' {
            { New-LabMedia @newLabMediaParams } | Should Not Throw;
        }

        It 'Throws with an invalid Uri' {
            $testLabMediaParams = $newLabMediaParams.Clone();
            $testLabMediaParams['Uri'] = 'about:blank';

            { New-LabMedia @testLabMediaParams } | Should Throw;
        }

        foreach ($parameter in @('Id','Filename','Architecture','MediaType','Uri')) {

            It "Throws when ""$parameter"" parameter is missing" {
                $testLabMediaParams = $newLabMediaParams.Clone();
                $testLabMediaParams.Remove($parameter);

                { New-LabMedia @testLabMediaParams } | Should Throw;
            }
        }

        It 'Returns "System.Management.Automation.PSCustomObject" object type' {
            $labMedia = New-LabMedia @newLabMediaParams;

            $labMedia -is [System.Management.Automation.PSCustomObject] | Should Be $true;
        }

        It 'Creates ProductKey custom entry when "ProductKey" is specified' {
            $testProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO';
            $labMedia = New-LabMedia @newLabMediaParams -ProductKey $testProductKey;

            $labMedia.CustomData.ProductKey | Should Be $testProductKey;
        }

    } #end InModuleScope

} #end describe
