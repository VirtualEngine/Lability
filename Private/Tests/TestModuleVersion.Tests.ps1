Describe 'TestModuleVersion Tests' {

   Context 'Parameters for TestModuleVersion'{

        It 'Has a Parameter called ModulePath' {
            $Function.Parameters.Keys.Contains('ModulePath') | Should Be 'True'
            }
        It 'ModulePath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ModulePath.Attributes.Mandatory | Should be 'True'
            }
        It 'ModulePath Parameter is of String Type' {
            $Function.Parameters.ModulePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ModulePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ModulePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ModulePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ModulePath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does ModulePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ModulePath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ModulePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ModulePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ModulePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ModulePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ModulePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ModulePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ModulePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ModulePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ModulePath '{
            $function.Definition.Contains('.PARAMETER ModulePath') | Should Be 'True'
            }
        It 'Has a Parameter called MinimumVersion' {
            $Function.Parameters.Keys.Contains('MinimumVersion') | Should Be 'True'
            }
        It 'MinimumVersion Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.MinimumVersion.Attributes.Mandatory | Should be 'True'
            }
        It 'MinimumVersion Parameter is of Version Type' {
            $Function.Parameters.MinimumVersion.ParameterType.FullName | Should be 'System.Version'
            }
        It 'MinimumVersion Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MinimumVersion.ParameterSets.Keys | Should Be 'MinimumVersion'
            }
        It 'MinimumVersion Parameter Position is defined correctly' {
            [String]$Function.Parameters.MinimumVersion.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MinimumVersion Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MinimumVersion.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MinimumVersion Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MinimumVersion.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called RequiredVersion' {
            $Function.Parameters.Keys.Contains('RequiredVersion') | Should Be 'True'
            }
        It 'RequiredVersion Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.RequiredVersion.Attributes.Mandatory | Should be 'True'
            }
        It 'RequiredVersion Parameter is of Version Type' {
            $Function.Parameters.RequiredVersion.ParameterType.FullName | Should be 'System.Version'
            }
        It 'RequiredVersion Parameter is member of ParameterSets' {
            [String]$Function.Parameters.RequiredVersion.ParameterSets.Keys | Should Be 'RequiredVersion'
            }
        It 'RequiredVersion Parameter Position is defined correctly' {
            [String]$Function.Parameters.RequiredVersion.Attributes.Position | Should be '-2147483648'
            }
        It 'Does RequiredVersion Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RequiredVersion.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RequiredVersion Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RequiredVersion.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RequiredVersion Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RequiredVersion.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.RequiredVersion.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.RequiredVersion.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RequiredVersion.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RequiredVersion.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RequiredVersion '{
            $function.Definition.Contains('.PARAMETER RequiredVersion') | Should Be 'True'
            }
        It 'Has a Parameter called RemainingArguments' {
            $Function.Parameters.Keys.Contains('RemainingArguments') | Should Be 'True'
            }
        It 'RemainingArguments Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.RemainingArguments.Attributes.Mandatory | Should be 'False'
            }
        It 'RemainingArguments Parameter is of Object Type' {
            $Function.Parameters.RemainingArguments.ParameterType.FullName | Should be 'System.Object'
            }
        It 'RemainingArguments Parameter is member of ParameterSets' {
            [String]$Function.Parameters.RemainingArguments.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'RemainingArguments Parameter Position is defined correctly' {
            [String]$Function.Parameters.RemainingArguments.Attributes.Position | Should be '-2147483648'
            }
        It 'Does RemainingArguments Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RemainingArguments.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RemainingArguments Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RemainingArguments.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does RemainingArguments Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RemainingArguments.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.RemainingArguments.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.RemainingArguments.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RemainingArguments.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RemainingArguments.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RemainingArguments '{
            $function.Definition.Contains('.PARAMETER RemainingArguments') | Should Be 'True'
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


