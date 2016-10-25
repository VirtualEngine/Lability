Describe 'GetDscModule Tests' {

   Context 'Parameters for GetDscModule'{

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
        It 'Has a Parameter called ResourceName' {
            $Function.Parameters.Keys.Contains('ResourceName') | Should Be 'True'
            }
        It 'ResourceName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ResourceName.Attributes.Mandatory | Should be 'False'
            }
        It 'ResourceName Parameter is of String Type' {
            $Function.Parameters.ResourceName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ResourceName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourceName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ResourceName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourceName.Attributes.Position | Should be '1'
            }
        It 'Does ResourceName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourceName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ResourceName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourceName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ResourceName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourceName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourceName '{
            $function.Definition.Contains('.PARAMETER ResourceName') | Should Be 'True'
            }
        It 'Has a Parameter called MinimumVersion' {
            $Function.Parameters.Keys.Contains('MinimumVersion') | Should Be 'True'
            }
        It 'MinimumVersion Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.MinimumVersion.Attributes.Mandatory | Should be 'False'
            }
        It 'MinimumVersion Parameter is of String Type' {
            $Function.Parameters.MinimumVersion.ParameterType.FullName | Should be 'System.String'
            }
        It 'MinimumVersion Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MinimumVersion.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MinimumVersion Parameter Position is defined correctly' {
            [String]$Function.Parameters.MinimumVersion.Attributes.Position | Should be '2'
            }
        It 'Does MinimumVersion Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MinimumVersion.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MinimumVersion Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MinimumVersion.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does MinimumVersion Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MinimumVersion.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.MinimumVersion.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MinimumVersion.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MinimumVersion.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MinimumVersion.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MinimumVersion '{
            $function.Definition.Contains('.PARAMETER MinimumVersion') | Should Be 'True'
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


