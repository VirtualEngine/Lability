Describe 'Remove-LabConfiguration Tests' {

   Context 'Parameters for Remove-LabConfiguration'{

        It 'Has a Parameter called ConfigurationData' {
            $Function.Parameters.Keys.Contains('ConfigurationData') | Should Be 'True'
            }
        It 'ConfigurationData Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Mandatory | Should be 'True'
            }
        It 'ConfigurationData Parameter is of Hashtable Type' {
            $Function.Parameters.ConfigurationData.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'ConfigurationData Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ConfigurationData.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ConfigurationData Parameter Position is defined correctly' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '0'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ConfigurationData Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ConfigurationData '{
            $function.Definition.Contains('.PARAMETER ConfigurationData') | Should Be 'True'
            }
        It 'Has a Parameter called RemoveSwitch' {
            $Function.Parameters.Keys.Contains('RemoveSwitch') | Should Be 'True'
            }
        It 'RemoveSwitch Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.RemoveSwitch.Attributes.Mandatory | Should be 'False'
            }
        It 'RemoveSwitch Parameter is of SwitchParameter Type' {
            $Function.Parameters.RemoveSwitch.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'RemoveSwitch Parameter is member of ParameterSets' {
            [String]$Function.Parameters.RemoveSwitch.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'RemoveSwitch Parameter Position is defined correctly' {
            [String]$Function.Parameters.RemoveSwitch.Attributes.Position | Should be '-2147483648'
            }
        It 'Does RemoveSwitch Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RemoveSwitch.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RemoveSwitch Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RemoveSwitch.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RemoveSwitch Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RemoveSwitch.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.RemoveSwitch.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.RemoveSwitch.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RemoveSwitch.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RemoveSwitch.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RemoveSwitch '{
            $function.Definition.Contains('.PARAMETER RemoveSwitch') | Should Be 'True'
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


