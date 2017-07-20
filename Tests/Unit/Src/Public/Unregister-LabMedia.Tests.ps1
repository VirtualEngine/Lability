#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Unregister-LabMedia' {

    InModuleScope -ModuleName $moduleName {

        $testMediaId = 'TestId';
        $testCustomMedia = @(
            [PSObject] @{ Id = $testMediaId; Uri = 'http://contoso.com/testmedia'; Architecture = 'x64'; }
            [PSObject] @{ Id = 'TestId2'; Uri = 'http://contoso.com/testmedia'; Architecture = 'x64'; }
        )

        It "Removes existing custom media entry when 'Id' does exist" {

            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { return $testCustomMedia; };
            Mock Set-ConfigurationData { }

            Unregister-LabMedia -Id $testMediaId -WarningAction SilentlyContinue;

            Assert-MockCalled Set-ConfigurationData -ParameterFilter { $InputObject.Count -eq ($testCustomMedia.Count -1) } -Scope It;

        }

        It "Does not remove any entries when custom media 'Id' doesn't exist" {

            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { return $testCustomMedia; };
            Mock Set-ConfigurationData { }

            Unregister-LabMedia -Id 'Non-existent' -WarningAction SilentlyContinue;

            Assert-MockCalled Set-ConfigurationData -Scope It -Exactly 0;
        }

    } #end InModuleScope

} #end describe
