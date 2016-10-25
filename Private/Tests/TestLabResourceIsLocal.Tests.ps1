Describe 'TestLabResourceIsLocal Tests' {

   Context 'Parameters for TestLabResourceIsLocal'{

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
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '0'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called ResourceId' {
            $Function.Parameters.Keys.Contains('ResourceId') | Should Be 'True'
            }
        It 'ResourceId Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ResourceId.Attributes.Mandatory | Should be 'True'
            }
        It 'ResourceId Parameter is of String Type' {
            $Function.Parameters.ResourceId.ParameterType.FullName | Should be 'System.String'
            }
        It 'ResourceId Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourceId.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ResourceId Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourceId.Attributes.Position | Should be '1'
            }
        It 'Does ResourceId Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourceId.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ResourceId Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourceId.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ResourceId Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourceId '{
            $function.Definition.Contains('.PARAMETER ResourceId') | Should Be 'True'
            }
        It 'Has a Parameter called LocalResourcePath' {
            $Function.Parameters.Keys.Contains('LocalResourcePath') | Should Be 'True'
            }
        It 'LocalResourcePath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.LocalResourcePath.Attributes.Mandatory | Should be 'True'
            }
        It 'LocalResourcePath Parameter is of String Type' {
            $Function.Parameters.LocalResourcePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'LocalResourcePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.LocalResourcePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'LocalResourcePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.LocalResourcePath.Attributes.Position | Should be '2'
            }
        It 'Does LocalResourcePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.LocalResourcePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does LocalResourcePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.LocalResourcePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does LocalResourcePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.LocalResourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.LocalResourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.LocalResourcePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.LocalResourcePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.LocalResourcePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for LocalResourcePath '{
            $function.Definition.Contains('.PARAMETER LocalResourcePath') | Should Be 'True'
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


