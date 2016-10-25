Describe 'TestComputerName Tests' {

   Context 'Parameters for TestComputerName'{

        It 'Has a Parameter called ComputerName' {
            $Function.Parameters.Keys.Contains('ComputerName') | Should Be 'True'
            }
        It 'ComputerName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ComputerName.Attributes.Mandatory | Should be 'True'
            }
        It 'ComputerName Parameter is of String Type' {
            $Function.Parameters.ComputerName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ComputerName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ComputerName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ComputerName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ComputerName.Attributes.Position | Should be '0'
            }
        It 'Does ComputerName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ComputerName.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ComputerName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ComputerName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ComputerName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ComputerName '{
            $function.Definition.Contains('.PARAMETER ComputerName') | Should Be 'True'
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


