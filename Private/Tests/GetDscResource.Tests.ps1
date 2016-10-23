Describe 'GetDscResource Tests' {

   Context 'Parameters for GetDscResource'{

        It 'Has a Parameter called ResourceName' {
            $Function.Parameters.Keys.Contains('ResourceName') | Should Be 'True'
            }
        It 'ResourceName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ResourceName.Attributes.Mandatory | Should be 'True'
            }
        It 'ResourceName Parameter is of String Type' {
            $Function.Parameters.ResourceName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ResourceName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourceName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ResourceName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourceName.Attributes.Position | Should be '0'
            }
        It 'Does ResourceName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourceName.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ResourceName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourceName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ResourceName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourceName '{
            $function.Definition.Contains('.PARAMETER ResourceName') | Should Be 'True'
            }
        It 'Has a Parameter called Parameters' {
            $Function.Parameters.Keys.Contains('Parameters') | Should Be 'True'
            }
        It 'Parameters Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Parameters.Attributes.Mandatory | Should be 'True'
            }
        It 'Parameters Parameter is of Hashtable Type' {
            $Function.Parameters.Parameters.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'Parameters Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Parameters.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Parameters Parameter Position is defined correctly' {
            [String]$Function.Parameters.Parameters.Attributes.Position | Should be '1'
            }
        It 'Does Parameters Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Parameters.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Parameters Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Parameters.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Parameters Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Parameters.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Parameters.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Parameters.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Parameters.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Parameters.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Parameters '{
            $function.Definition.Contains('.PARAMETER Parameters') | Should Be 'True'
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


