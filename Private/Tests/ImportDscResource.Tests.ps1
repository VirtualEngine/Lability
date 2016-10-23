Describe 'ImportDscResource Tests' {

   Context 'Parameters for ImportDscResource'{

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
            [String]$Function.Parameters.ModuleName.Attributes.ValueFromPipeline | Should be 'True'
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
        It 'ResourceName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ResourceName.Attributes.Mandatory | Should be 'True'
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
            [String]$Function.Parameters.ResourceName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called Prefix' {
            $Function.Parameters.Keys.Contains('Prefix') | Should Be 'True'
            }
        It 'Prefix Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Prefix.Attributes.Mandatory | Should be 'False'
            }
        It 'Prefix Parameter is of String Type' {
            $Function.Parameters.Prefix.ParameterType.FullName | Should be 'System.String'
            }
        It 'Prefix Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Prefix.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Prefix Parameter Position is defined correctly' {
            [String]$Function.Parameters.Prefix.Attributes.Position | Should be '2'
            }
        It 'Does Prefix Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Prefix.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Prefix Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Prefix.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Prefix Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Prefix.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Prefix.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Prefix.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Prefix.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Prefix.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Prefix '{
            $function.Definition.Contains('.PARAMETER Prefix') | Should Be 'True'
            }
        It 'Has a Parameter called UseDefault' {
            $Function.Parameters.Keys.Contains('UseDefault') | Should Be 'True'
            }
        It 'UseDefault Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.UseDefault.Attributes.Mandatory | Should be 'False'
            }
        It 'UseDefault Parameter is of SwitchParameter Type' {
            $Function.Parameters.UseDefault.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'UseDefault Parameter is member of ParameterSets' {
            [String]$Function.Parameters.UseDefault.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'UseDefault Parameter Position is defined correctly' {
            [String]$Function.Parameters.UseDefault.Attributes.Position | Should be '-2147483648'
            }
        It 'Does UseDefault Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.UseDefault.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does UseDefault Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.UseDefault.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does UseDefault Parameter use advanced parameter Validation? ' {
            $Function.Parameters.UseDefault.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.UseDefault.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.UseDefault.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.UseDefault.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.UseDefault.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for UseDefault '{
            $function.Definition.Contains('.PARAMETER UseDefault') | Should Be 'True'
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


