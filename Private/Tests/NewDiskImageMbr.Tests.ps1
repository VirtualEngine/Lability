Describe 'NewDiskImageMbr Tests' {

   Context 'Parameters for NewDiskImageMbr'{

        It 'Has a Parameter called Vhd' {
            $Function.Parameters.Keys.Contains('Vhd') | Should Be 'True'
            }
        It 'Vhd Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Vhd.Attributes.Mandatory | Should be 'True'
            }
        It 'Vhd Parameter is of Object Type' {
            $Function.Parameters.Vhd.ParameterType.FullName | Should be 'System.Object'
            }
        It 'Vhd Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Vhd.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Vhd Parameter Position is defined correctly' {
            [String]$Function.Parameters.Vhd.Attributes.Position | Should be '0'
            }
        It 'Does Vhd Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Vhd.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Vhd Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Vhd.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Vhd Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Vhd '{
            $function.Definition.Contains('.PARAMETER Vhd') | Should Be 'True'
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


