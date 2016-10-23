Describe 'SetLabVMDiskFileBootstrap Tests' {

   Context 'Parameters for SetLabVMDiskFileBootstrap'{

        It 'Has a Parameter called VhdDriveLetter' {
            $Function.Parameters.Keys.Contains('VhdDriveLetter') | Should Be 'True'
            }
        It 'VhdDriveLetter Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.VhdDriveLetter.Attributes.Mandatory | Should be 'True'
            }
        It 'VhdDriveLetter Parameter is of String Type' {
            $Function.Parameters.VhdDriveLetter.ParameterType.FullName | Should be 'System.String'
            }
        It 'VhdDriveLetter Parameter is member of ParameterSets' {
            [String]$Function.Parameters.VhdDriveLetter.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'VhdDriveLetter Parameter Position is defined correctly' {
            [String]$Function.Parameters.VhdDriveLetter.Attributes.Position | Should be '0'
            }
        It 'Does VhdDriveLetter Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.VhdDriveLetter.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does VhdDriveLetter Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.VhdDriveLetter.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does VhdDriveLetter Parameter use advanced parameter Validation? ' {
            $Function.Parameters.VhdDriveLetter.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.VhdDriveLetter.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.VhdDriveLetter.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.VhdDriveLetter.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.VhdDriveLetter.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for VhdDriveLetter '{
            $function.Definition.Contains('.PARAMETER VhdDriveLetter') | Should Be 'True'
            }
        It 'Has a Parameter called CustomBootstrap' {
            $Function.Parameters.Keys.Contains('CustomBootstrap') | Should Be 'True'
            }
        It 'CustomBootstrap Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.CustomBootstrap.Attributes.Mandatory | Should be 'False'
            }
        It 'CustomBootstrap Parameter is of String Type' {
            $Function.Parameters.CustomBootstrap.ParameterType.FullName | Should be 'System.String'
            }
        It 'CustomBootstrap Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CustomBootstrap.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CustomBootstrap Parameter Position is defined correctly' {
            [String]$Function.Parameters.CustomBootstrap.Attributes.Position | Should be '1'
            }
        It 'Does CustomBootstrap Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CustomBootstrap.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does CustomBootstrap Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CustomBootstrap.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does CustomBootstrap Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CustomBootstrap.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.CustomBootstrap.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrap.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CustomBootstrap.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrap.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CustomBootstrap '{
            $function.Definition.Contains('.PARAMETER CustomBootstrap') | Should Be 'True'
            }
        It 'Has a Parameter called CoreCLR' {
            $Function.Parameters.Keys.Contains('CoreCLR') | Should Be 'True'
            }
        It 'CoreCLR Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.CoreCLR.Attributes.Mandatory | Should be 'False'
            }
        It 'CoreCLR Parameter is of SwitchParameter Type' {
            $Function.Parameters.CoreCLR.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'CoreCLR Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CoreCLR.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CoreCLR Parameter Position is defined correctly' {
            [String]$Function.Parameters.CoreCLR.Attributes.Position | Should be '-2147483648'
            }
        It 'Does CoreCLR Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CoreCLR.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does CoreCLR Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CoreCLR.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does CoreCLR Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CoreCLR.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CoreCLR '{
            $function.Definition.Contains('.PARAMETER CoreCLR') | Should Be 'True'
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
            [String]$Function.Parameters.RemainingArguments.Attributes.Position | Should be '2'
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


