Describe 'Reset-LabVM Tests' {

   Context 'Parameters for Reset-LabVM'{

        It 'Has a Parameter called Name' {
            $Function.Parameters.Keys.Contains('Name') | Should Be 'True'
            }
        It 'Name Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Name.Attributes.Mandatory | Should be 'True'
            }
        It 'Name Parameter is of String[] Type' {
            $Function.Parameters.Name.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'Name Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Name.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Name Parameter Position is defined correctly' {
            [String]$Function.Parameters.Name.Attributes.Position | Should be '-2147483648'
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
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '-2147483648'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called Credential' {
            $Function.Parameters.Keys.Contains('Credential') | Should Be 'True'
            }
        It 'Credential Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Credential.Attributes.Mandatory | Should be 'False'
            }
        It 'Credential Parameter is of PSCredential Type' {
            $Function.Parameters.Credential.ParameterType.FullName | Should be 'System.Management.Automation.PSCredential'
            }
        It 'Credential Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Credential.ParameterSets.Keys | Should Be 'PSCredential'
            }
        It 'Credential Parameter Position is defined correctly' {
            [String]$Function.Parameters.Credential.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Credential Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Credential.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Credential Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Credential.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Credential Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Credential.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Credential '{
            $function.Definition.Contains('.PARAMETER Credential') | Should Be 'True'
            }
        It 'Has a Parameter called Password' {
            $Function.Parameters.Keys.Contains('Password') | Should Be 'True'
            }
        It 'Password Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Password.Attributes.Mandatory | Should be 'True'
            }
        It 'Password Parameter is of SecureString Type' {
            $Function.Parameters.Password.ParameterType.FullName | Should be 'System.Security.SecureString'
            }
        It 'Password Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Password.ParameterSets.Keys | Should Be 'Password'
            }
        It 'Password Parameter Position is defined correctly' {
            [String]$Function.Parameters.Password.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Password Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Password.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Password Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Password.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Password Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Password.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Password.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Password.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Password.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Password.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Password '{
            $function.Definition.Contains('.PARAMETER Password') | Should Be 'True'
            }
        It 'Has a Parameter called Path' {
            $Function.Parameters.Keys.Contains('Path') | Should Be 'True'
            }
        It 'Path Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Path.Attributes.Mandatory | Should be 'False'
            }
        It 'Path Parameter is of String Type' {
            $Function.Parameters.Path.ParameterType.FullName | Should be 'System.String'
            }
        It 'Path Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'False'
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
        It 'Has a Parameter called NoSnapshot' {
            $Function.Parameters.Keys.Contains('NoSnapshot') | Should Be 'True'
            }
        It 'NoSnapshot Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.NoSnapshot.Attributes.Mandatory | Should be 'False'
            }
        It 'NoSnapshot Parameter is of SwitchParameter Type' {
            $Function.Parameters.NoSnapshot.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'NoSnapshot Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NoSnapshot.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NoSnapshot Parameter Position is defined correctly' {
            [String]$Function.Parameters.NoSnapshot.Attributes.Position | Should be '-2147483648'
            }
        It 'Does NoSnapshot Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NoSnapshot.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does NoSnapshot Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NoSnapshot.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does NoSnapshot Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NoSnapshot.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NoSnapshot.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.NoSnapshot.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NoSnapshot.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NoSnapshot.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NoSnapshot '{
            $function.Definition.Contains('.PARAMETER NoSnapshot') | Should Be 'True'
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


