Describe 'SetUnattendXml Tests' {

   Context 'Parameters for SetUnattendXml'{

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
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '0'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'True'
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
            [String]$Function.Parameters.Credential.Attributes.Position | Should be '1'
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
        It 'Has a Parameter called ComputerName' {
            $Function.Parameters.Keys.Contains('ComputerName') | Should Be 'True'
            }
        It 'ComputerName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ComputerName.Attributes.Mandatory | Should be 'False'
            }
        It 'ComputerName Parameter is of String Type' {
            $Function.Parameters.ComputerName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ComputerName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ComputerName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ComputerName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ComputerName.Attributes.Position | Should be '2'
            }
        It 'Does ComputerName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ComputerName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ComputerName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ComputerName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ComputerName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ComputerName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ComputerName '{
            $function.Definition.Contains('.PARAMETER ComputerName') | Should Be 'True'
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
            [String]$Function.Parameters.ProductKey.Attributes.Position | Should be '3'
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
            $Function.Parameters.ProductKey.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'True'
            }
        It 'Has Parameter Help Text for ProductKey '{
            $function.Definition.Contains('.PARAMETER ProductKey') | Should Be 'True'
            }
        It 'Has a Parameter called InputLocale' {
            $Function.Parameters.Keys.Contains('InputLocale') | Should Be 'True'
            }
        It 'InputLocale Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.InputLocale.Attributes.Mandatory | Should be 'False'
            }
        It 'InputLocale Parameter is of String Type' {
            $Function.Parameters.InputLocale.ParameterType.FullName | Should be 'System.String'
            }
        It 'InputLocale Parameter is member of ParameterSets' {
            [String]$Function.Parameters.InputLocale.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'InputLocale Parameter Position is defined correctly' {
            [String]$Function.Parameters.InputLocale.Attributes.Position | Should be '4'
            }
        It 'Does InputLocale Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.InputLocale.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does InputLocale Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.InputLocale.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does InputLocale Parameter use advanced parameter Validation? ' {
            $Function.Parameters.InputLocale.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.InputLocale.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.InputLocale.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.InputLocale.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.InputLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for InputLocale '{
            $function.Definition.Contains('.PARAMETER InputLocale') | Should Be 'True'
            }
        It 'Has a Parameter called SystemLocale' {
            $Function.Parameters.Keys.Contains('SystemLocale') | Should Be 'True'
            }
        It 'SystemLocale Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.SystemLocale.Attributes.Mandatory | Should be 'False'
            }
        It 'SystemLocale Parameter is of String Type' {
            $Function.Parameters.SystemLocale.ParameterType.FullName | Should be 'System.String'
            }
        It 'SystemLocale Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SystemLocale.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SystemLocale Parameter Position is defined correctly' {
            [String]$Function.Parameters.SystemLocale.Attributes.Position | Should be '5'
            }
        It 'Does SystemLocale Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SystemLocale.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SystemLocale Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SystemLocale.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does SystemLocale Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SystemLocale.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.SystemLocale.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SystemLocale.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SystemLocale.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SystemLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SystemLocale '{
            $function.Definition.Contains('.PARAMETER SystemLocale') | Should Be 'True'
            }
        It 'Has a Parameter called UserLocale' {
            $Function.Parameters.Keys.Contains('UserLocale') | Should Be 'True'
            }
        It 'UserLocale Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.UserLocale.Attributes.Mandatory | Should be 'False'
            }
        It 'UserLocale Parameter is of String Type' {
            $Function.Parameters.UserLocale.ParameterType.FullName | Should be 'System.String'
            }
        It 'UserLocale Parameter is member of ParameterSets' {
            [String]$Function.Parameters.UserLocale.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'UserLocale Parameter Position is defined correctly' {
            [String]$Function.Parameters.UserLocale.Attributes.Position | Should be '6'
            }
        It 'Does UserLocale Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.UserLocale.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does UserLocale Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.UserLocale.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does UserLocale Parameter use advanced parameter Validation? ' {
            $Function.Parameters.UserLocale.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.UserLocale.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.UserLocale.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.UserLocale.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.UserLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for UserLocale '{
            $function.Definition.Contains('.PARAMETER UserLocale') | Should Be 'True'
            }
        It 'Has a Parameter called UILanguage' {
            $Function.Parameters.Keys.Contains('UILanguage') | Should Be 'True'
            }
        It 'UILanguage Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.UILanguage.Attributes.Mandatory | Should be 'False'
            }
        It 'UILanguage Parameter is of String Type' {
            $Function.Parameters.UILanguage.ParameterType.FullName | Should be 'System.String'
            }
        It 'UILanguage Parameter is member of ParameterSets' {
            [String]$Function.Parameters.UILanguage.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'UILanguage Parameter Position is defined correctly' {
            [String]$Function.Parameters.UILanguage.Attributes.Position | Should be '7'
            }
        It 'Does UILanguage Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.UILanguage.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does UILanguage Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.UILanguage.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does UILanguage Parameter use advanced parameter Validation? ' {
            $Function.Parameters.UILanguage.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.UILanguage.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.UILanguage.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.UILanguage.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.UILanguage.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for UILanguage '{
            $function.Definition.Contains('.PARAMETER UILanguage') | Should Be 'True'
            }
        It 'Has a Parameter called Timezone' {
            $Function.Parameters.Keys.Contains('Timezone') | Should Be 'True'
            }
        It 'Timezone Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Timezone.Attributes.Mandatory | Should be 'True'
            }
        It 'Timezone Parameter is of String Type' {
            $Function.Parameters.Timezone.ParameterType.FullName | Should be 'System.String'
            }
        It 'Timezone Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Timezone.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Timezone Parameter Position is defined correctly' {
            [String]$Function.Parameters.Timezone.Attributes.Position | Should be '8'
            }
        It 'Does Timezone Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Timezone.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Timezone Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Timezone.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Timezone Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Timezone.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Timezone.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Timezone.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Timezone.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Timezone.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Timezone '{
            $function.Definition.Contains('.PARAMETER Timezone') | Should Be 'True'
            }
        It 'Has a Parameter called RegisteredOwner' {
            $Function.Parameters.Keys.Contains('RegisteredOwner') | Should Be 'True'
            }
        It 'RegisteredOwner Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.RegisteredOwner.Attributes.Mandatory | Should be 'False'
            }
        It 'RegisteredOwner Parameter is of String Type' {
            $Function.Parameters.RegisteredOwner.ParameterType.FullName | Should be 'System.String'
            }
        It 'RegisteredOwner Parameter is member of ParameterSets' {
            [String]$Function.Parameters.RegisteredOwner.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'RegisteredOwner Parameter Position is defined correctly' {
            [String]$Function.Parameters.RegisteredOwner.Attributes.Position | Should be '9'
            }
        It 'Does RegisteredOwner Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RegisteredOwner.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RegisteredOwner Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RegisteredOwner.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RegisteredOwner Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RegisteredOwner '{
            $function.Definition.Contains('.PARAMETER RegisteredOwner') | Should Be 'True'
            }
        It 'Has a Parameter called RegisteredOrganization' {
            $Function.Parameters.Keys.Contains('RegisteredOrganization') | Should Be 'True'
            }
        It 'RegisteredOrganization Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.RegisteredOrganization.Attributes.Mandatory | Should be 'False'
            }
        It 'RegisteredOrganization Parameter is of String Type' {
            $Function.Parameters.RegisteredOrganization.ParameterType.FullName | Should be 'System.String'
            }
        It 'RegisteredOrganization Parameter is member of ParameterSets' {
            [String]$Function.Parameters.RegisteredOrganization.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'RegisteredOrganization Parameter Position is defined correctly' {
            [String]$Function.Parameters.RegisteredOrganization.Attributes.Position | Should be '10'
            }
        It 'Does RegisteredOrganization Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RegisteredOrganization.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RegisteredOrganization Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RegisteredOrganization.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RegisteredOrganization Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RegisteredOrganization '{
            $function.Definition.Contains('.PARAMETER RegisteredOrganization') | Should Be 'True'
            }
        It 'Has a Parameter called ExecuteCommand' {
            $Function.Parameters.Keys.Contains('ExecuteCommand') | Should Be 'True'
            }
        It 'ExecuteCommand Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ExecuteCommand.Attributes.Mandatory | Should be 'False'
            }
        It 'ExecuteCommand Parameter is of Hashtable[] Type' {
            $Function.Parameters.ExecuteCommand.ParameterType.FullName | Should be 'System.Collections.Hashtable[]'
            }
        It 'ExecuteCommand Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ExecuteCommand.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ExecuteCommand Parameter Position is defined correctly' {
            [String]$Function.Parameters.ExecuteCommand.Attributes.Position | Should be '11'
            }
        It 'Does ExecuteCommand Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ExecuteCommand.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ExecuteCommand Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ExecuteCommand.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ExecuteCommand Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ExecuteCommand.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ExecuteCommand.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ExecuteCommand.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ExecuteCommand.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ExecuteCommand.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ExecuteCommand '{
            $function.Definition.Contains('.PARAMETER ExecuteCommand') | Should Be 'True'
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


