Describe 'NewBootStrap Tests' {

   Context 'Parameters for NewBootStrap'{

        It 'Has a Parameter called CoreCLR' {
            $Function.Parameters.Keys.Contains('CoreCLR') | Should Be 'True'
            }
        It 'CoreCLR Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.CoreCLR.Attributes.Mandatory | Should be 'False'
            }
        It 'CoreCLR Parameter is of SwitchParameter Type' {
            $Function.Parameters.CoreCLR.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'CoreCLR Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CoreCLR.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CoreCLR Parameter Position is defined correctly' {
            [String]$Function.Parameters.CoreCLR.Attributes.Position | Should be '-2147483648'
            }
        It 'Does CoreCLR Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CoreCLR.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does CoreCLR Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CoreCLR.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does CoreCLR Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CoreCLR '{
            $function.Definition.Contains('.PARAMETER CoreCLR') | Should Be 'True'
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


