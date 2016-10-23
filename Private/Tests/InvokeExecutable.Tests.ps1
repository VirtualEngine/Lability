Describe 'InvokeExecutable Tests' {

   Context 'Parameters for InvokeExecutable'{

        It 'Has a Parameter called Path' {
            $Function.Parameters.Keys.Contains('Path') | Should Be 'True'
            }
        It 'Path Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Path.Attributes.Mandatory | Should be 'True'
            }
        It 'Path Parameter is of String Type' {
            $Function.Parameters.Path.ParameterType.FullName | Should be 'System.String'
            }
        It 'Path Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '0'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called Arguments' {
            $Function.Parameters.Keys.Contains('Arguments') | Should Be 'True'
            }
        It 'Arguments Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Arguments.Attributes.Mandatory | Should be 'True'
            }
        It 'Arguments Parameter is of Array Type' {
            $Function.Parameters.Arguments.ParameterType.FullName | Should be 'System.Array'
            }
        It 'Arguments Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Arguments.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Arguments Parameter Position is defined correctly' {
            [String]$Function.Parameters.Arguments.Attributes.Position | Should be '1'
            }
        It 'Does Arguments Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Arguments.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Arguments Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Arguments.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Arguments Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Arguments.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Arguments.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Arguments.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Arguments.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Arguments.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Arguments '{
            $function.Definition.Contains('.PARAMETER Arguments') | Should Be 'True'
            }
        It 'Has a Parameter called LogName' {
            $Function.Parameters.Keys.Contains('LogName') | Should Be 'True'
            }
        It 'LogName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.LogName.Attributes.Mandatory | Should be 'False'
            }
        It 'LogName Parameter is of String Type' {
            $Function.Parameters.LogName.ParameterType.FullName | Should be 'System.String'
            }
        It 'LogName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.LogName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'LogName Parameter Position is defined correctly' {
            [String]$Function.Parameters.LogName.Attributes.Position | Should be '2'
            }
        It 'Does LogName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.LogName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does LogName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.LogName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does LogName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.LogName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.LogName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.LogName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.LogName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.LogName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for LogName '{
            $function.Definition.Contains('.PARAMETER LogName') | Should Be 'True'
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


