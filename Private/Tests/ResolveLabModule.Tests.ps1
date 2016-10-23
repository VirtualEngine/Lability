Describe 'ResolveLabModule Tests' {

   Context 'Parameters for ResolveLabModule'{

        It 'Has a Parameter called NodeName' {
            $Function.Parameters.Keys.Contains('NodeName') | Should Be 'True'
            }
        It 'NodeName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.NodeName.Attributes.Mandatory | Should be 'True'
            }
        It 'NodeName Parameter is of String Type' {
            $Function.Parameters.NodeName.ParameterType.FullName | Should be 'System.String'
            }
        It 'NodeName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NodeName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NodeName Parameter Position is defined correctly' {
            [String]$Function.Parameters.NodeName.Attributes.Position | Should be '0'
            }
        It 'Does NodeName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NodeName.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does NodeName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NodeName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does NodeName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NodeName '{
            $function.Definition.Contains('.PARAMETER NodeName') | Should Be 'True'
            }
        It 'Has a Parameter called ConfigurationData' {
            $Function.Parameters.Keys.Contains('ConfigurationData') | Should Be 'True'
            }
        It 'ConfigurationData Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Mandatory | Should be 'True'
            }
        It 'ConfigurationData Parameter is of Hashtable Type' {
            $Function.Parameters.ConfigurationData.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'ConfigurationData Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ConfigurationData.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ConfigurationData Parameter Position is defined correctly' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '1'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ConfigurationData Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ConfigurationData '{
            $function.Definition.Contains('.PARAMETER ConfigurationData') | Should Be 'True'
            }
        It 'Has a Parameter called ModuleType' {
            $Function.Parameters.Keys.Contains('ModuleType') | Should Be 'True'
            }
        It 'ModuleType Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ModuleType.Attributes.Mandatory | Should be 'True'
            }
        It 'ModuleType Parameter is of String Type' {
            $Function.Parameters.ModuleType.ParameterType.FullName | Should be 'System.String'
            }
        It 'ModuleType Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ModuleType.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ModuleType Parameter Position is defined correctly' {
            [String]$Function.Parameters.ModuleType.Attributes.Position | Should be '2'
            }
        It 'Does ModuleType Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ModuleType.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ModuleType Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ModuleType.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ModuleType Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ModuleType.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ModuleType.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ModuleType.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ModuleType.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ModuleType.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ModuleType '{
            $function.Definition.Contains('.PARAMETER ModuleType') | Should Be 'True'
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


