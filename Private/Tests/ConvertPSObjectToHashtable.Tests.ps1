Describe 'ConvertPSObjectToHashtable Tests' {

   Context 'Parameters for ConvertPSObjectToHashtable'{

        It 'Has a Parameter called InputObject' {
            $Function.Parameters.Keys.Contains('InputObject') | Should Be 'True'
            }
        It 'InputObject Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.InputObject.Attributes.Mandatory | Should be 'True'
            }
        It 'InputObject Parameter is of PSObject[] Type' {
            $Function.Parameters.InputObject.ParameterType.FullName | Should be 'System.Management.Automation.PSObject[]'
            }
        It 'InputObject Parameter is member of ParameterSets' {
            [String]$Function.Parameters.InputObject.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'InputObject Parameter Position is defined correctly' {
            [String]$Function.Parameters.InputObject.Attributes.Position | Should be '0'
            }
        It 'Does InputObject Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.InputObject.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does InputObject Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.InputObject.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does InputObject Parameter use advanced parameter Validation? ' {
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for InputObject '{
            $function.Definition.Contains('.PARAMETER InputObject') | Should Be 'True'
            }
        It 'Has a Parameter called IgnoreNullValues' {
            $Function.Parameters.Keys.Contains('IgnoreNullValues') | Should Be 'True'
            }
        It 'IgnoreNullValues Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.IgnoreNullValues.Attributes.Mandatory | Should be 'False'
            }
        It 'IgnoreNullValues Parameter is of SwitchParameter Type' {
            $Function.Parameters.IgnoreNullValues.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'IgnoreNullValues Parameter is member of ParameterSets' {
            [String]$Function.Parameters.IgnoreNullValues.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'IgnoreNullValues Parameter Position is defined correctly' {
            [String]$Function.Parameters.IgnoreNullValues.Attributes.Position | Should be '-2147483648'
            }
        It 'Does IgnoreNullValues Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.IgnoreNullValues.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does IgnoreNullValues Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.IgnoreNullValues.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does IgnoreNullValues Parameter use advanced parameter Validation? ' {
            $Function.Parameters.IgnoreNullValues.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.IgnoreNullValues.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.IgnoreNullValues.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.IgnoreNullValues.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.IgnoreNullValues.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for IgnoreNullValues '{
            $function.Definition.Contains('.PARAMETER IgnoreNullValues') | Should Be 'True'
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


