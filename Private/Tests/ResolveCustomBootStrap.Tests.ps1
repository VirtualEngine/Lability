Describe 'ResolveCustomBootStrap Tests' {

   Context 'Parameters for ResolveCustomBootStrap'{

        It 'Has a Parameter called CustomBootstrapOrder' {
            $Function.Parameters.Keys.Contains('CustomBootstrapOrder') | Should Be 'True'
            }
        It 'CustomBootstrapOrder Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.Mandatory | Should be 'True'
            }
        It 'CustomBootstrapOrder Parameter is of String Type' {
            $Function.Parameters.CustomBootstrapOrder.ParameterType.FullName | Should be 'System.String'
            }
        It 'CustomBootstrapOrder Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CustomBootstrapOrder.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CustomBootstrapOrder Parameter Position is defined correctly' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.Position | Should be '0'
            }
        It 'Does CustomBootstrapOrder Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does CustomBootstrapOrder Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does CustomBootstrapOrder Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CustomBootstrapOrder '{
            $function.Definition.Contains('.PARAMETER CustomBootstrapOrder') | Should Be 'True'
            }
        It 'Has a Parameter called ConfigurationCustomBootStrap' {
            $Function.Parameters.Keys.Contains('ConfigurationCustomBootStrap') | Should Be 'True'
            }
        It 'ConfigurationCustomBootStrap Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ConfigurationCustomBootStrap.Attributes.Mandatory | Should be 'False'
            }
        It 'ConfigurationCustomBootStrap Parameter is of String Type' {
            $Function.Parameters.ConfigurationCustomBootStrap.ParameterType.FullName | Should be 'System.String'
            }
        It 'ConfigurationCustomBootStrap Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ConfigurationCustomBootStrap.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ConfigurationCustomBootStrap Parameter Position is defined correctly' {
            [String]$Function.Parameters.ConfigurationCustomBootStrap.Attributes.Position | Should be '1'
            }
        It 'Does ConfigurationCustomBootStrap Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationCustomBootStrap.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ConfigurationCustomBootStrap Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationCustomBootStrap.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ConfigurationCustomBootStrap Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ConfigurationCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ConfigurationCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationCustomBootStrap.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ConfigurationCustomBootStrap '{
            $function.Definition.Contains('.PARAMETER ConfigurationCustomBootStrap') | Should Be 'True'
            }
        It 'Has a Parameter called MediaCustomBootStrap' {
            $Function.Parameters.Keys.Contains('MediaCustomBootStrap') | Should Be 'True'
            }
        It 'MediaCustomBootStrap Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.MediaCustomBootStrap.Attributes.Mandatory | Should be 'False'
            }
        It 'MediaCustomBootStrap Parameter is of String[] Type' {
            $Function.Parameters.MediaCustomBootStrap.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'MediaCustomBootStrap Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MediaCustomBootStrap.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MediaCustomBootStrap Parameter Position is defined correctly' {
            [String]$Function.Parameters.MediaCustomBootStrap.Attributes.Position | Should be '2'
            }
        It 'Does MediaCustomBootStrap Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MediaCustomBootStrap.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MediaCustomBootStrap Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MediaCustomBootStrap.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does MediaCustomBootStrap Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MediaCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MediaCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MediaCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MediaCustomBootStrap.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MediaCustomBootStrap.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MediaCustomBootStrap '{
            $function.Definition.Contains('.PARAMETER MediaCustomBootStrap') | Should Be 'True'
            }
    }
    Context "Function $($function.Name) - Help Section" {

            It "Function $($function.Name) Has show-help comment block" {

                $function.Definition.Contains('<#') | should be 'True'
                $function.Definition.Contains('#>') | should be 'True'
            }

            It "Function $($function.Name) Has show-help comment block has a.SYNOPSIS" {

                $function.Definition.Contains('.SYNOPSIS') -or $function.Definition.Contains('.Synopsis') | should be 'True'

            }

            It "Function $($function.Name) Has show-help comment block has an example" {

                $function.Definition.Contains('.EXAMPLE') | should be 'True'
            }

            It "Function $($function.Name) Is an advanced function" {

                $function.CmdletBinding | should be 'True'
                $function.Definition.Contains('param') -or  $function.Definition.Contains('Param') | should be 'True'
            }
    
    }

 }


