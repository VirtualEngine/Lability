Describe 'NewDirectory Tests' {

   Context 'Parameters for NewDirectory'{

        It 'Has a Parameter called InputObject' {
            $Function.Parameters.Keys.Contains('InputObject') | Should Be 'True'
            }
        It 'InputObject Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.InputObject.Attributes.Mandatory | Should be 'True'
            }
        It 'InputObject Parameter is of DirectoryInfo[] Type' {
            $Function.Parameters.InputObject.ParameterType.FullName | Should be 'System.IO.DirectoryInfo[]'
            }
        It 'InputObject Parameter is member of ParameterSets' {
            [String]$Function.Parameters.InputObject.ParameterSets.Keys | Should Be 'ByDirectoryInfo'
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
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.InputObject.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for InputObject '{
            $function.Definition.Contains('.PARAMETER InputObject') | Should Be 'True'
            }
        It 'Has a Parameter called Path' {
            $Function.Parameters.Keys.Contains('Path') | Should Be 'True'
            }
        It 'Path Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Path.Attributes.Mandatory | Should be 'True'
            }
        It 'Path Parameter is of String[] Type' {
            $Function.Parameters.Path.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'Path Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be 'ByString'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '0'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Path Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Path '{
            $function.Definition.Contains('.PARAMETER Path') | Should Be 'True'
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


