Describe 'ResolveProgramFilesFolder Tests' {

   Context 'Parameters for ResolveProgramFilesFolder'{

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
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called Drive' {
            $Function.Parameters.Keys.Contains('Drive') | Should Be 'True'
            }
        It 'Drive Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Drive.Attributes.Mandatory | Should be 'True'
            }
        It 'Drive Parameter is of String Type' {
            $Function.Parameters.Drive.ParameterType.FullName | Should be 'System.String'
            }
        It 'Drive Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Drive.ParameterSets.Keys | Should Be 'Drive'
            }
        It 'Drive Parameter Position is defined correctly' {
            [String]$Function.Parameters.Drive.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Drive Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Drive.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Drive Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Drive.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Drive Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Drive.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Drive.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Drive.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Drive.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Drive.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Drive '{
            $function.Definition.Contains('.PARAMETER Drive') | Should Be 'True'
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


