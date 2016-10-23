Describe 'Export-LabHostConfiguration Tests' {

   Context 'Parameters for Export-LabHostConfiguration'{

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
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be 'Path'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called LiteralPath' {
            $Function.Parameters.Keys.Contains('LiteralPath') | Should Be 'True'
            }
        It 'LiteralPath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.LiteralPath.Attributes.Mandatory | Should be 'True'
            }
        It 'LiteralPath Parameter is of String Type' {
            $Function.Parameters.LiteralPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'LiteralPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.LiteralPath.ParameterSets.Keys | Should Be 'LiteralPath'
            }
        It 'LiteralPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.LiteralPath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does LiteralPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.LiteralPath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does LiteralPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.LiteralPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does LiteralPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for LiteralPath '{
            $function.Definition.Contains('.PARAMETER LiteralPath') | Should Be 'True'
            }
        It 'Has a Parameter called NoClobber' {
            $Function.Parameters.Keys.Contains('NoClobber') | Should Be 'True'
            }
        It 'NoClobber Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.NoClobber.Attributes.Mandatory | Should be 'False'
            }
        It 'NoClobber Parameter is of SwitchParameter Type' {
            $Function.Parameters.NoClobber.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'NoClobber Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NoClobber.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NoClobber Parameter Position is defined correctly' {
            [String]$Function.Parameters.NoClobber.Attributes.Position | Should be '-2147483648'
            }
        It 'Does NoClobber Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NoClobber.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does NoClobber Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NoClobber.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does NoClobber Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NoClobber.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NoClobber.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.NoClobber.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NoClobber.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NoClobber.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NoClobber '{
            $function.Definition.Contains('.PARAMETER NoClobber') | Should Be 'True'
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


