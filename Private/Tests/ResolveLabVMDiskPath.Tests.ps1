Describe 'ResolveLabVMDiskPath Tests' {

   Context 'Parameters for ResolveLabVMDiskPath'{

        It 'Has a Parameter called Name' {
            $Function.Parameters.Keys.Contains('Name') | Should Be 'True'
            }
        It 'Name Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Name.Attributes.Mandatory | Should be 'True'
            }
        It 'Name Parameter is of String Type' {
            $Function.Parameters.Name.ParameterType.FullName | Should be 'System.String'
            }
        It 'Name Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Name.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Name Parameter Position is defined correctly' {
            [String]$Function.Parameters.Name.Attributes.Position | Should be '0'
            }
        It 'Does Name Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Name.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Name Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Name.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Name Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Name '{
            $function.Definition.Contains('.PARAMETER Name') | Should Be 'True'
            }
        It 'Has a Parameter called Generation' {
            $Function.Parameters.Keys.Contains('Generation') | Should Be 'True'
            }
        It 'Generation Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Generation.Attributes.Mandatory | Should be 'False'
            }
        It 'Generation Parameter is of String Type' {
            $Function.Parameters.Generation.ParameterType.FullName | Should be 'System.String'
            }
        It 'Generation Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Generation.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Generation Parameter Position is defined correctly' {
            [String]$Function.Parameters.Generation.Attributes.Position | Should be '1'
            }
        It 'Does Generation Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Generation.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Generation Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Generation.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Generation Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Generation.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Generation.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Generation.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Generation.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Generation.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Generation '{
            $function.Definition.Contains('.PARAMETER Generation') | Should Be 'True'
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


