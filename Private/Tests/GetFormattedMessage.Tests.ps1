Describe 'GetFormattedMessage Tests' {

   Context 'Parameters for GetFormattedMessage'{

        It 'Has a Parameter called Message' {
            $Function.Parameters.Keys.Contains('Message') | Should Be 'True'
            }
        It 'Message Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Message.Attributes.Mandatory | Should be 'True'
            }
        It 'Message Parameter is of String Type' {
            $Function.Parameters.Message.ParameterType.FullName | Should be 'System.String'
            }
        It 'Message Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Message.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Message Parameter Position is defined correctly' {
            [String]$Function.Parameters.Message.Attributes.Position | Should be '0'
            }
        It 'Does Message Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Message.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Message Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Message.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Message Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Message.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Message.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Message.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Message.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Message.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Message '{
            $function.Definition.Contains('.PARAMETER Message') | Should Be 'True'
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


