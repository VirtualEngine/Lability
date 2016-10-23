Describe 'Test-LabResource Tests' {

   Context 'Parameters for Test-LabResource'{

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
        It 'ResourceId Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ResourceId.Attributes.Mandatory | Should be 'False'
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
        It 'Has a Parameter called ResourcePath' {
            $Function.Parameters.Keys.Contains('ResourcePath') | Should Be 'True'
            }
        It 'ResourcePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ResourcePath.Attributes.Mandatory | Should be 'False'
            }
        It 'ResourcePath Parameter is of String Type' {
            $Function.Parameters.ResourcePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ResourcePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourcePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ResourcePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourcePath.Attributes.Position | Should be '2'
            }
        It 'Does ResourcePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourcePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ResourcePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourcePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ResourcePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourcePath '{
            $function.Definition.Contains('.PARAMETER ResourcePath') | Should Be 'True'
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


