Describe 'RemoveLabVirtualMachine Tests' {

   Context 'Parameters for RemoveLabVirtualMachine'{

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
            [String]$Function.Parameters.Name.Attributes.ValueFromPipeline | Should be 'False'
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
        It 'Has a Parameter called SwitchName' {
            $Function.Parameters.Keys.Contains('SwitchName') | Should Be 'True'
            }
        It 'SwitchName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.SwitchName.Attributes.Mandatory | Should be 'True'
            }
        It 'SwitchName Parameter is of String[] Type' {
            $Function.Parameters.SwitchName.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'SwitchName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SwitchName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SwitchName Parameter Position is defined correctly' {
            [String]$Function.Parameters.SwitchName.Attributes.Position | Should be '1'
            }
        It 'Does SwitchName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SwitchName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SwitchName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SwitchName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called Media' {
            $Function.Parameters.Keys.Contains('Media') | Should Be 'True'
            }
        It 'Media Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Media.Attributes.Mandatory | Should be 'True'
            }
        It 'Media Parameter is of String Type' {
            $Function.Parameters.Media.ParameterType.FullName | Should be 'System.String'
            }
        It 'Media Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Media.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Media Parameter Position is defined correctly' {
            [String]$Function.Parameters.Media.Attributes.Position | Should be '2'
            }
        It 'Does Media Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Media Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called StartupMemory' {
            $Function.Parameters.Keys.Contains('StartupMemory') | Should Be 'True'
            }
        It 'StartupMemory Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.StartupMemory.Attributes.Mandatory | Should be 'True'
            }
        It 'StartupMemory Parameter is of UInt64 Type' {
            $Function.Parameters.StartupMemory.ParameterType.FullName | Should be 'System.UInt64'
            }
        It 'StartupMemory Parameter is member of ParameterSets' {
            [String]$Function.Parameters.StartupMemory.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'StartupMemory Parameter Position is defined correctly' {
            [String]$Function.Parameters.StartupMemory.Attributes.Position | Should be '3'
            }
        It 'Does StartupMemory Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.StartupMemory.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does StartupMemory Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.StartupMemory.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does StartupMemory Parameter use advanced parameter Validation? ' {
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.StartupMemory.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for StartupMemory '{
            $function.Definition.Contains('.PARAMETER StartupMemory') | Should Be 'True'
            }
        It 'Has a Parameter called MinimumMemory' {
            $Function.Parameters.Keys.Contains('MinimumMemory') | Should Be 'True'
            }
        It 'MinimumMemory Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.MinimumMemory.Attributes.Mandatory | Should be 'True'
            }
        It 'MinimumMemory Parameter is of UInt64 Type' {
            $Function.Parameters.MinimumMemory.ParameterType.FullName | Should be 'System.UInt64'
            }
        It 'MinimumMemory Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MinimumMemory.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MinimumMemory Parameter Position is defined correctly' {
            [String]$Function.Parameters.MinimumMemory.Attributes.Position | Should be '4'
            }
        It 'Does MinimumMemory Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MinimumMemory.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MinimumMemory Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MinimumMemory.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does MinimumMemory Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MinimumMemory.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MinimumMemory '{
            $function.Definition.Contains('.PARAMETER MinimumMemory') | Should Be 'True'
            }
        It 'Has a Parameter called MaximumMemory' {
            $Function.Parameters.Keys.Contains('MaximumMemory') | Should Be 'True'
            }
        It 'MaximumMemory Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.MaximumMemory.Attributes.Mandatory | Should be 'True'
            }
        It 'MaximumMemory Parameter is of UInt64 Type' {
            $Function.Parameters.MaximumMemory.ParameterType.FullName | Should be 'System.UInt64'
            }
        It 'MaximumMemory Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MaximumMemory.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MaximumMemory Parameter Position is defined correctly' {
            [String]$Function.Parameters.MaximumMemory.Attributes.Position | Should be '5'
            }
        It 'Does MaximumMemory Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MaximumMemory.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MaximumMemory Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MaximumMemory.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does MaximumMemory Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MaximumMemory.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MaximumMemory '{
            $function.Definition.Contains('.PARAMETER MaximumMemory') | Should Be 'True'
            }
        It 'Has a Parameter called ProcessorCount' {
            $Function.Parameters.Keys.Contains('ProcessorCount') | Should Be 'True'
            }
        It 'ProcessorCount Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ProcessorCount.Attributes.Mandatory | Should be 'True'
            }
        It 'ProcessorCount Parameter is of Int32 Type' {
            $Function.Parameters.ProcessorCount.ParameterType.FullName | Should be 'System.Int32'
            }
        It 'ProcessorCount Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ProcessorCount.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ProcessorCount Parameter Position is defined correctly' {
            [String]$Function.Parameters.ProcessorCount.Attributes.Position | Should be '6'
            }
        It 'Does ProcessorCount Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ProcessorCount.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ProcessorCount Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ProcessorCount.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ProcessorCount Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ProcessorCount.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ProcessorCount '{
            $function.Definition.Contains('.PARAMETER ProcessorCount') | Should Be 'True'
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
            [String]$Function.Parameters.MACAddress.Attributes.Position | Should be '7'
            }
        It 'Does MACAddress Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MACAddress.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MACAddress Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MACAddress.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does MACAddress Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MACAddress.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
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
            [String]$Function.Parameters.SecureBoot.Attributes.Position | Should be '8'
            }
        It 'Does SecureBoot Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SecureBoot.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SecureBoot Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SecureBoot.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.Position | Should be '9'
            }
        It 'Does GuestIntegrationServices Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does GuestIntegrationServices Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.GuestIntegrationServices.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called ConfigurationData' {
            $Function.Parameters.Keys.Contains('ConfigurationData') | Should Be 'True'
            }
        It 'ConfigurationData Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Mandatory | Should be 'False'
            }
        It 'ConfigurationData Parameter is of Hashtable Type' {
            $Function.Parameters.ConfigurationData.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'ConfigurationData Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ConfigurationData.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ConfigurationData Parameter Position is defined correctly' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '10'
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


