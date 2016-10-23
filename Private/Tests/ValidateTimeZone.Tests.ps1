Describe 'ValidateTimeZone Tests' {

   Context 'Parameters for ValidateTimeZone'{

        It 'Has a Parameter called TimeZone' {
            $Function.Parameters.Keys.Contains('TimeZone') | Should Be 'True'
            }
        It 'TimeZone Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.TimeZone.Attributes.Mandatory | Should be 'True'
            }
        It 'TimeZone Parameter is of String Type' {
            $Function.Parameters.TimeZone.ParameterType.FullName | Should be 'System.String'
            }
        It 'TimeZone Parameter is member of ParameterSets' {
            [String]$Function.Parameters.TimeZone.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'TimeZone Parameter Position is defined correctly' {
            [String]$Function.Parameters.TimeZone.Attributes.Position | Should be '0'
            }
        It 'Does TimeZone Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.TimeZone.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does TimeZone Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.TimeZone.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does TimeZone Parameter use advanced parameter Validation? ' {
            $Function.Parameters.TimeZone.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.TimeZone.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.TimeZone.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.TimeZone.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.TimeZone.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for TimeZone '{
            $function.Definition.Contains('.PARAMETER TimeZone') | Should Be 'True'
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


