Describe 'New-LabVM Tests' {

   Context 'Parameters for New-LabVM'{

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
        It 'Has a Parameter called StartupMemory' {
            $Function.Parameters.Keys.Contains('StartupMemory') | Should Be 'True'
            }
        It 'StartupMemory Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.StartupMemory.Attributes.Mandatory | Should be 'False'
            }
        It 'StartupMemory Parameter is of Int64 Type' {
            $Function.Parameters.StartupMemory.ParameterType.FullName | Should be 'System.Int64'
            }
        It 'StartupMemory Parameter is member of ParameterSets' {
            [String]$Function.Parameters.StartupMemory.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'StartupMemory Parameter Position is defined correctly' {
            [String]$Function.Parameters.StartupMemory.Attributes.Position | Should be '-2147483648'
            }
        It 'Does StartupMemory Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.StartupMemory.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does StartupMemory Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.StartupMemory.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does StartupMemory Parameter use advanced parameter Validation? ' {
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'True'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for StartupMemory '{
            $function.Definition.Contains('.PARAMETER StartupMemory') | Should Be 'True'
            }
        It 'Has a Parameter called MinimumMemory' {
            $Function.Parameters.Keys.Contains('MinimumMemory') | Should Be 'True'
            }
        It 'MinimumMemory Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.MinimumMemory.Attributes.Mandatory | Should be 'False'
            }
        It 'MinimumMemory Parameter is of Int64 Type' {
            $Function.Parameters.MinimumMemory.ParameterType.FullName | Should be 'System.Int64'
            }
        It 'MinimumMemory Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MinimumMemory.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MinimumMemory Parameter Position is defined correctly' {
            [String]$Function.Parameters.MinimumMemory.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MinimumMemory Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MinimumMemory.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MinimumMemory Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MinimumMemory.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does MinimumMemory Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'True'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MinimumMemory '{
            $function.Definition.Contains('.PARAMETER MinimumMemory') | Should Be 'True'
            }
        It 'Has a Parameter called MaximumMemory' {
            $Function.Parameters.Keys.Contains('MaximumMemory') | Should Be 'True'
            }
        It 'MaximumMemory Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.MaximumMemory.Attributes.Mandatory | Should be 'False'
            }
        It 'MaximumMemory Parameter is of Int64 Type' {
            $Function.Parameters.MaximumMemory.ParameterType.FullName | Should be 'System.Int64'
            }
        It 'MaximumMemory Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MaximumMemory.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MaximumMemory Parameter Position is defined correctly' {
            [String]$Function.Parameters.MaximumMemory.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MaximumMemory Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MaximumMemory.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MaximumMemory Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MaximumMemory.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does MaximumMemory Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'True'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MaximumMemory '{
            $function.Definition.Contains('.PARAMETER MaximumMemory') | Should Be 'True'
            }
        It 'Has a Parameter called ProcessorCount' {
            $Function.Parameters.Keys.Contains('ProcessorCount') | Should Be 'True'
            }
        It 'ProcessorCount Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ProcessorCount.Attributes.Mandatory | Should be 'False'
            }
        It 'ProcessorCount Parameter is of Int32 Type' {
            $Function.Parameters.ProcessorCount.ParameterType.FullName | Should be 'System.Int32'
            }
        It 'ProcessorCount Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ProcessorCount.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ProcessorCount Parameter Position is defined correctly' {
            [String]$Function.Parameters.ProcessorCount.Attributes.Position | Should be '-2147483648'
            }
        It 'Does ProcessorCount Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ProcessorCount.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ProcessorCount Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ProcessorCount.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ProcessorCount Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'True'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ProcessorCount '{
            $function.Definition.Contains('.PARAMETER ProcessorCount') | Should Be 'True'
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
            [String]$Function.Parameters.InputLocale.Attributes.Position | Should be '-2147483648'
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
            $Function.Parameters.InputLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'True'
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
            [String]$Function.Parameters.SystemLocale.Attributes.Position | Should be '-2147483648'
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
            $Function.Parameters.SystemLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'True'
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
            [String]$Function.Parameters.UserLocale.Attributes.Position | Should be '-2147483648'
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
            $Function.Parameters.UserLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'True'
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
            [String]$Function.Parameters.UILanguage.Attributes.Position | Should be '-2147483648'
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
            $Function.Parameters.UILanguage.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'True'
            }
        It 'Has Parameter Help Text for UILanguage '{
            $function.Definition.Contains('.PARAMETER UILanguage') | Should Be 'True'
            }
        It 'Has a Parameter called Timezone' {
            $Function.Parameters.Keys.Contains('Timezone') | Should Be 'True'
            }
        It 'Timezone Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Timezone.Attributes.Mandatory | Should be 'False'
            }
        It 'Timezone Parameter is of String Type' {
            $Function.Parameters.Timezone.ParameterType.FullName | Should be 'System.String'
            }
        It 'Timezone Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Timezone.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Timezone Parameter Position is defined correctly' {
            [String]$Function.Parameters.Timezone.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Timezone Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Timezone.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Timezone Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Timezone.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Timezone Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Timezone.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
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
            [String]$Function.Parameters.RegisteredOwner.Attributes.Position | Should be '-2147483648'
            }
        It 'Does RegisteredOwner Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RegisteredOwner.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RegisteredOwner Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RegisteredOwner.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RegisteredOwner Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.RegisteredOwner.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
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
            [String]$Function.Parameters.RegisteredOrganization.Attributes.Position | Should be '-2147483648'
            }
        It 'Does RegisteredOrganization Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RegisteredOrganization.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RegisteredOrganization Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RegisteredOrganization.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RegisteredOrganization Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RegisteredOrganization.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RegisteredOrganization '{
            $function.Definition.Contains('.PARAMETER RegisteredOrganization') | Should Be 'True'
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
        It 'Has a Parameter called SwitchName' {
            $Function.Parameters.Keys.Contains('SwitchName') | Should Be 'True'
            }
        It 'SwitchName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.SwitchName.Attributes.Mandatory | Should be 'False'
            }
        It 'SwitchName Parameter is of String[] Type' {
            $Function.Parameters.SwitchName.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'SwitchName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SwitchName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SwitchName Parameter Position is defined correctly' {
            [String]$Function.Parameters.SwitchName.Attributes.Position | Should be '-2147483648'
            }
        It 'Does SwitchName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SwitchName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SwitchName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SwitchName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does SwitchName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SwitchName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.SwitchName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SwitchName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SwitchName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SwitchName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SwitchName '{
            $function.Definition.Contains('.PARAMETER SwitchName') | Should Be 'True'
            }
        It 'Has a Parameter called MACAddress' {
            $Function.Parameters.Keys.Contains('MACAddress') | Should Be 'True'
            }
        It 'MACAddress Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.MACAddress.Attributes.Mandatory | Should be 'False'
            }
        It 'MACAddress Parameter is of String[] Type' {
            $Function.Parameters.MACAddress.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'MACAddress Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MACAddress.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MACAddress Parameter Position is defined correctly' {
            [String]$Function.Parameters.MACAddress.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MACAddress Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MACAddress.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MACAddress Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MACAddress.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does MACAddress Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MACAddress.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.MACAddress.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MACAddress.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MACAddress.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MACAddress.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MACAddress '{
            $function.Definition.Contains('.PARAMETER MACAddress') | Should Be 'True'
            }
        It 'Has a Parameter called SecureBoot' {
            $Function.Parameters.Keys.Contains('SecureBoot') | Should Be 'True'
            }
        It 'SecureBoot Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.SecureBoot.Attributes.Mandatory | Should be 'False'
            }
        It 'SecureBoot Parameter is of Boolean Type' {
            $Function.Parameters.SecureBoot.ParameterType.FullName | Should be 'System.Boolean'
            }
        It 'SecureBoot Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SecureBoot.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SecureBoot Parameter Position is defined correctly' {
            [String]$Function.Parameters.SecureBoot.Attributes.Position | Should be '-2147483648'
            }
        It 'Does SecureBoot Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SecureBoot.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SecureBoot Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SecureBoot.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does SecureBoot Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SecureBoot.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.SecureBoot.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SecureBoot.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SecureBoot.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SecureBoot.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SecureBoot '{
            $function.Definition.Contains('.PARAMETER SecureBoot') | Should Be 'True'
            }
        It 'Has a Parameter called GuestIntegrationServices' {
            $Function.Parameters.Keys.Contains('GuestIntegrationServices') | Should Be 'True'
            }
        It 'GuestIntegrationServices Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.Mandatory | Should be 'False'
            }
        It 'GuestIntegrationServices Parameter is of Boolean Type' {
            $Function.Parameters.GuestIntegrationServices.ParameterType.FullName | Should be 'System.Boolean'
            }
        It 'GuestIntegrationServices Parameter is member of ParameterSets' {
            [String]$Function.Parameters.GuestIntegrationServices.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'GuestIntegrationServices Parameter Position is defined correctly' {
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.Position | Should be '-2147483648'
            }
        It 'Does GuestIntegrationServices Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does GuestIntegrationServices Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does GuestIntegrationServices Parameter use advanced parameter Validation? ' {
            $Function.Parameters.GuestIntegrationServices.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.GuestIntegrationServices.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.GuestIntegrationServices.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.GuestIntegrationServices.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.GuestIntegrationServices.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for GuestIntegrationServices '{
            $function.Definition.Contains('.PARAMETER GuestIntegrationServices') | Should Be 'True'
            }
        It 'Has a Parameter called CustomData' {
            $Function.Parameters.Keys.Contains('CustomData') | Should Be 'True'
            }
        It 'CustomData Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.CustomData.Attributes.Mandatory | Should be 'False'
            }
        It 'CustomData Parameter is of Hashtable Type' {
            $Function.Parameters.CustomData.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'CustomData Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CustomData.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CustomData Parameter Position is defined correctly' {
            [String]$Function.Parameters.CustomData.Attributes.Position | Should be '-2147483648'
            }
        It 'Does CustomData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CustomData.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does CustomData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CustomData.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does CustomData Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CustomData '{
            $function.Definition.Contains('.PARAMETER CustomData') | Should Be 'True'
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
        It 'Has a Parameter called MediaId' {
            $Function.Parameters.Keys.Contains('MediaId') | Should Be 'True'
            }
        It 'MediaId Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.MediaId.Attributes.Mandatory | Should be 'True'
            }
        It 'MediaId Parameter is of String Type' {
            $Function.Parameters.MediaId.ParameterType.FullName | Should be 'System.String'
            }
        It 'MediaId Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MediaId.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MediaId Parameter Position is defined correctly' {
            [String]$Function.Parameters.MediaId.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MediaId Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MediaId.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MediaId Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MediaId.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does MediaId Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MediaId.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MediaId.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MediaId.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MediaId.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MediaId.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MediaId '{
            $function.Definition.Contains('.PARAMETER MediaId') | Should Be 'True'
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


