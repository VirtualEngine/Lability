#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Resolve-LabCustomBootStrap' {

    InModuleScope $moduleName {

        It 'Returns empty string when "CustomBootStrapOrder" = "Disabled"' {
            $configurationBootstrap = 'Configuration';
            $mediaBootstrap = 'Media';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder Disabled -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

            $bootstrap | Should BeNullOrEmpty;
        }

        It 'Returns configuration bootstrap when "CustomBootStrapOrder" = "ConfigurationOnly"' {
            $configurationBootstrap = 'Configuration';
            $mediaBootstrap = 'Media';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder ConfigurationOnly -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

            $bootstrap | Should Be $configurationBootstrap;
        }

        It 'Returns media bootstrap when "CustomBootStrapOrder" = "MediaOnly"' {
            $configurationBootstrap = 'Configuration';
            $mediaBootstrap = 'Media';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder MediaOnly -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

            $bootstrap | Should Be $mediaBootstrap;
        }

        It 'Returns configuration bootstrap first when "CustomBootStrapOrder" = "ConfigurationFirst"' {
            $configurationBootstrap = 'Configuration';
            $mediaBootstrap = 'Media';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder ConfigurationFirst -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

            $bootstrap | Should Be "$configurationBootStrap`r`n$mediaBootstrap";
        }

        It 'Returns media bootstrap first when "CustomBootStrapOrder" = "MediaFirst"' {
            $configurationBootstrap = 'Configuration';
            $mediaBootstrap = 'Media';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder MediaFirst -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

            $bootstrap | Should Be "$mediaBootstrap`r`n$configurationBootStrap";
        }

        It 'Returns configuration bootstrap when "MediaCustomBootstrap" is null' {
            $configurationBootstrap = 'Configuration';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder ConfigurationFirst -ConfigurationCustomBootstrap $configurationBootstrap;

            $bootstrap | Should Be "$configurationBootStrap`r`n$mediaBootstrap";
        }

        It 'Returns media bootstrap when "ConfigurationCustomBootstrap" is null' {
            $mediaBootstrap = 'Media';

            $bootstrap = Resolve-LabCustomBootStrap -CustomBootstrapOrder MediaFirst -MediaCustomBootstrap $mediaBootstrap;

            $bootstrap | Should Be "$mediaBootstrap`r`n$configurationBootStrap";
        }

    } #end InModuleScope
} #end Describe
