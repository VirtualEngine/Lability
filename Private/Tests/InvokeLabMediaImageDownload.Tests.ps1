Describe 'InvokeLabMediaImageDownload Tests' {

   Context 'Parameters for InvokeLabMediaImageDownload'{

        It 'Has a Parameter called Media' {
            $Function.Parameters.Keys.Contains('Media') | Should Be 'True'
            }
        It 'Media Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Media.Attributes.Mandatory | Should be 'True'
            }
        It 'Media Parameter is of Object Type' {
            $Function.Parameters.Media.ParameterType.FullName | Should be 'System.Object'
            }
        It 'Media Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Media.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Media Parameter Position is defined correctly' {
            [String]$Function.Parameters.Media.Attributes.Position | Should be '0'
            }
        It 'Does Media Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Media Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Media Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Media '{
            $function.Definition.Contains('.PARAMETER Media') | Should Be 'True'
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
            [String]$Function.Parameters.Force.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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


