Describe 'Test-LabMedia Tests' {

   Context 'Parameters for Test-LabMedia'{

        It 'Has a Parameter called Id' {
            $Function.Parameters.Keys.Contains('Id') | Should Be 'True'
            }
        It 'Id Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Id.Attributes.Mandatory | Should be 'True'
            }
        It 'Id Parameter is of String Type' {
            $Function.Parameters.Id.ParameterType.FullName | Should be 'System.String'
            }
        It 'Id Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Id.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Id Parameter Position is defined correctly' {
            [String]$Function.Parameters.Id.Attributes.Position | Should be '0'
            }
        It 'Does Id Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Id.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Id Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Id.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Id Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Id '{
            $function.Definition.Contains('.PARAMETER Id') | Should Be 'True'
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


