Describe 'Set-LabVMDefaults Tests' {

   Context 'Parameters for Set-LabVMDefaults'{

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
            [String]$Function.Parameters.StartupMemory.Attributes.Position | Should be '0'
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
            [String]$Function.Parameters.MinimumMemory.Attributes.Position | Should be '1'
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
            [String]$Function.Parameters.MaximumMemory.Attributes.Position | Should be '2'
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
            [String]$Function.Parameters.ProcessorCount.Attributes.Position | Should be '3'
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
        It 'Has a Parameter called Media' {
            $Function.Parameters.Keys.Contains('Media') | Should Be 'True'
            }
        It 'Media Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Media.Attributes.Mandatory | Should be 'False'
            }
        It 'Media Parameter is of String Type' {
            $Function.Parameters.Media.ParameterType.FullName | Should be 'System.String'
            }
        It 'Media Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Media.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Media Parameter Position is defined correctly' {
            [String]$Function.Parameters.Media.Attributes.Position | Should be '4'
            }
        It 'Does Media Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Media Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Media Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Media '{
            $function.Definition.Contains('.PARAMETER Media') | Should Be 'True'
            }
        It 'Has a Parameter called SwitchName' {
            $Function.Parameters.Keys.Contains('SwitchName') | Should Be 'True'
            }
        It 'SwitchName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.SwitchName.Attributes.Mandatory | Should be 'False'
            }
        It 'SwitchName Parameter is of String Type' {
            $Function.Parameters.SwitchName.ParameterType.FullName | Should be 'System.String'
            }
        It 'SwitchName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SwitchName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SwitchName Parameter Position is defined correctly' {
            [String]$Function.Parameters.SwitchName.Attributes.Position | Should be '5'
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
            [String]$Function.Parameters.InputLocale.Attributes.Position | Should be '6'
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
            [String]$Function.Parameters.SystemLocale.Attributes.Position | Should be '7'
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
            [String]$Function.Parameters.UserLocale.Attributes.Position | Should be '8'
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
            [String]$Function.Parameters.UILanguage.Attributes.Position | Should be '9'
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
            [String]$Function.Parameters.Timezone.Attributes.Position | Should be '10'
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
            [String]$Function.Parameters.RegisteredOwner.Attributes.Position | Should be '11'
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
            [String]$Function.Parameters.RegisteredOrganization.Attributes.Position | Should be '12'
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
        It 'Has a Parameter called ClientCertificatePath' {
            $Function.Parameters.Keys.Contains('ClientCertificatePath') | Should Be 'True'
            }
        It 'ClientCertificatePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ClientCertificatePath.Attributes.Mandatory | Should be 'False'
            }
        It 'ClientCertificatePath Parameter is of String Type' {
            $Function.Parameters.ClientCertificatePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ClientCertificatePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ClientCertificatePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ClientCertificatePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ClientCertificatePath.Attributes.Position | Should be '13'
            }
        It 'Does ClientCertificatePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ClientCertificatePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ClientCertificatePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ClientCertificatePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ClientCertificatePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ClientCertificatePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ClientCertificatePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.ClientCertificatePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ClientCertificatePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ClientCertificatePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ClientCertificatePath '{
            $function.Definition.Contains('.PARAMETER ClientCertificatePath') | Should Be 'True'
            }
        It 'Has a Parameter called RootCertificatePath' {
            $Function.Parameters.Keys.Contains('RootCertificatePath') | Should Be 'True'
            }
        It 'RootCertificatePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.RootCertificatePath.Attributes.Mandatory | Should be 'False'
            }
        It 'RootCertificatePath Parameter is of String Type' {
            $Function.Parameters.RootCertificatePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'RootCertificatePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.RootCertificatePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'RootCertificatePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.RootCertificatePath.Attributes.Position | Should be '14'
            }
        It 'Does RootCertificatePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.RootCertificatePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does RootCertificatePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.RootCertificatePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does RootCertificatePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.RootCertificatePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.RootCertificatePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.RootCertificatePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.RootCertificatePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.RootCertificatePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for RootCertificatePath '{
            $function.Definition.Contains('.PARAMETER RootCertificatePath') | Should Be 'True'
            }
        It 'Has a Parameter called BootDelay' {
            $Function.Parameters.Keys.Contains('BootDelay') | Should Be 'True'
            }
        It 'BootDelay Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.BootDelay.Attributes.Mandatory | Should be 'False'
            }
        It 'BootDelay Parameter is of UInt16 Type' {
            $Function.Parameters.BootDelay.ParameterType.FullName | Should be 'System.UInt16'
            }
        It 'BootDelay Parameter is member of ParameterSets' {
            [String]$Function.Parameters.BootDelay.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'BootDelay Parameter Position is defined correctly' {
            [String]$Function.Parameters.BootDelay.Attributes.Position | Should be '15'
            }
        It 'Does BootDelay Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.BootDelay.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does BootDelay Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.BootDelay.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does BootDelay Parameter use advanced parameter Validation? ' {
            $Function.Parameters.BootDelay.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.BootDelay.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.BootDelay.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.BootDelay.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.BootDelay.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for BootDelay '{
            $function.Definition.Contains('.PARAMETER BootDelay') | Should Be 'True'
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
            [String]$Function.Parameters.SecureBoot.Attributes.Position | Should be '16'
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
        It 'Has a Parameter called CustomBootstrapOrder' {
            $Function.Parameters.Keys.Contains('CustomBootstrapOrder') | Should Be 'True'
            }
        It 'CustomBootstrapOrder Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.Mandatory | Should be 'False'
            }
        It 'CustomBootstrapOrder Parameter is of String Type' {
            $Function.Parameters.CustomBootstrapOrder.ParameterType.FullName | Should be 'System.String'
            }
        It 'CustomBootstrapOrder Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CustomBootstrapOrder.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CustomBootstrapOrder Parameter Position is defined correctly' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.Position | Should be '17'
            }
        It 'Does CustomBootstrapOrder Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does CustomBootstrapOrder Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CustomBootstrapOrder.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does CustomBootstrapOrder Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CustomBootstrapOrder.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CustomBootstrapOrder '{
            $function.Definition.Contains('.PARAMETER CustomBootstrapOrder') | Should Be 'True'
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
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.Position | Should be '18'
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


