Describe 'SetLabVMDiskFileUnattendXml Tests' {

   Context 'Parameters for SetLabVMDiskFileUnattendXml'{

        It 'Has a Parameter called NodeName' {
            $Function.Parameters.Keys.Contains('NodeName') | Should Be 'True'
            }
        It 'NodeName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.NodeName.Attributes.Mandatory | Should be 'True'
            }
        It 'NodeName Parameter is of String Type' {
            $Function.Parameters.NodeName.ParameterType.FullName | Should be 'System.String'
            }
        It 'NodeName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NodeName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NodeName Parameter Position is defined correctly' {
            [String]$Function.Parameters.NodeName.Attributes.Position | Should be '0'
            }
        It 'Does NodeName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NodeName.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does NodeName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NodeName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does NodeName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NodeName '{
            $function.Definition.Contains('.PARAMETER NodeName') | Should Be 'True'
            }
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
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '1'
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
            [String]$Function.Parameters.VhdDriveLetter.Attributes.Position | Should be '2'
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
        It 'Has a Parameter called Credential' {
            $Function.Parameters.Keys.Contains('Credential') | Should Be 'True'
            }
        It 'Credential Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Credential.Attributes.Mandatory | Should be 'True'
            }
        It 'Credential Parameter is of PSCredential Type' {
            $Function.Parameters.Credential.ParameterType.FullName | Should be 'System.Management.Automation.PSCredential'
            }
        It 'Credential Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Credential.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Credential Parameter Position is defined correctly' {
            [String]$Function.Parameters.Credential.Attributes.Position | Should be '3'
            }
        It 'Does Credential Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Credential.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Credential Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Credential.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Credential Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Credential '{
            $function.Definition.Contains('.PARAMETER Credential') | Should Be 'True'
            }
        It 'Has a Parameter called ProductKey' {
            $Function.Parameters.Keys.Contains('ProductKey') | Should Be 'True'
            }
        It 'ProductKey Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ProductKey.Attributes.Mandatory | Should be 'False'
            }
        It 'ProductKey Parameter is of String Type' {
            $Function.Parameters.ProductKey.ParameterType.FullName | Should be 'System.String'
            }
        It 'ProductKey Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ProductKey.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ProductKey Parameter Position is defined correctly' {
            [String]$Function.Parameters.ProductKey.Attributes.Position | Should be '4'
            }
        It 'Does ProductKey Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ProductKey.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ProductKey Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ProductKey.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ProductKey Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ProductKey.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ProductKey.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ProductKey.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ProductKey.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ProductKey.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ProductKey '{
            $function.Definition.Contains('.PARAMETER ProductKey') | Should Be 'True'
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
            [String]$Function.Parameters.RemainingArguments.Attributes.Position | Should be '5'
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


