Describe 'Test-LabHostConfiguration Tests' {

   Context 'Parameters for Test-LabHostConfiguration'{

        It 'Has a Parameter called IgnorePendingReboot' {
            $Function.Parameters.Keys.Contains('IgnorePendingReboot') | Should Be 'True'
            }
        It 'IgnorePendingReboot Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.Mandatory | Should be 'False'
            }
        It 'IgnorePendingReboot Parameter is of SwitchParameter Type' {
            $Function.Parameters.IgnorePendingReboot.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'IgnorePendingReboot Parameter is member of ParameterSets' {
            [String]$Function.Parameters.IgnorePendingReboot.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'IgnorePendingReboot Parameter Position is defined correctly' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.Position | Should be '-2147483648'
            }
        It 'Does IgnorePendingReboot Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does IgnorePendingReboot Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does IgnorePendingReboot Parameter use advanced parameter Validation? ' {
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for IgnorePendingReboot '{
            $function.Definition.Contains('.PARAMETER IgnorePendingReboot') | Should Be 'True'
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


