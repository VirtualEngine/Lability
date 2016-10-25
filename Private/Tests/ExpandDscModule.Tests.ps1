Describe 'ExpandDscModule Tests' {

   Context 'Parameters for ExpandDscModule'{

        It 'Has a Parameter called ModuleName' {
            $Function.Parameters.Keys.Contains('ModuleName') | Should Be 'True'
            }
        It 'ModuleName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ModuleName.Attributes.Mandatory | Should be 'True'
            }
        It 'ModuleName Parameter is of String Type' {
            $Function.Parameters.ModuleName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ModuleName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ModuleName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ModuleName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ModuleName.Attributes.Position | Should be '0'
            }
        It 'Does ModuleName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ModuleName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ModuleName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ModuleName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ModuleName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ModuleName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ModuleName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ModuleName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ModuleName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ModuleName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ModuleName '{
            $function.Definition.Contains('.PARAMETER ModuleName') | Should Be 'True'
            }
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
            [String]$Function.Parameters.Path.Attributes.Position | Should be '1'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Path Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Path '{
            $function.Definition.Contains('.PARAMETER Path') | Should Be 'True'
            }
        It 'Has a Parameter called DestinationPath' {
            $Function.Parameters.Keys.Contains('DestinationPath') | Should Be 'True'
            }
        It 'DestinationPath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.DestinationPath.Attributes.Mandatory | Should be 'True'
            }
        It 'DestinationPath Parameter is of String Type' {
            $Function.Parameters.DestinationPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'DestinationPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DestinationPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DestinationPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.DestinationPath.Attributes.Position | Should be '2'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does DestinationPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DestinationPath '{
            $function.Definition.Contains('.PARAMETER DestinationPath') | Should Be 'True'
            }
        It 'Has a Parameter called Force' {
            $Function.Parameters.Keys.Contains('Force') | Should Be 'True'
            }
        It 'Force Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Force.Attributes.Mandatory | Should be 'False'
            }
        It 'Force Parameter is of SwitchParameter Type' {
            $Function.Parameters.Force.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Force Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Force.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Force Parameter Position is defined correctly' {
            [String]$Function.Parameters.Force.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Force Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Force.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Force Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Force.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Force Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Force '{
            $function.Definition.Contains('.PARAMETER Force') | Should Be 'True'
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


