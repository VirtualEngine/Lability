Describe 'Start-LabConfiguration Tests' {

   Context 'Parameters for Start-LabConfiguration'{

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
        It 'Has a Parameter called Force' {
            $Function.Parameters.Keys.Contains('Force') | Should Be 'True'
            }
        It 'Force Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Force.Attributes.Mandatory | Should be 'False'
            }
        It 'Force Parameter is of SwitchParameter Type' {
            $Function.Parameters.Force.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Force Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Force.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Force Parameter Position is defined correctly' {
            [String]$Function.Parameters.Force.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Force Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Force.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Force Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Force.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Force Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Force '{
            $function.Definition.Contains('.PARAMETER Force') | Should Be 'True'
            }
        It 'Has a Parameter called SkipMofCheck' {
            $Function.Parameters.Keys.Contains('SkipMofCheck') | Should Be 'True'
            }
        It 'SkipMofCheck Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.SkipMofCheck.Attributes.Mandatory | Should be 'False'
            }
        It 'SkipMofCheck Parameter is of SwitchParameter Type' {
            $Function.Parameters.SkipMofCheck.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'SkipMofCheck Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SkipMofCheck.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SkipMofCheck Parameter Position is defined correctly' {
            [String]$Function.Parameters.SkipMofCheck.Attributes.Position | Should be '-2147483648'
            }
        It 'Does SkipMofCheck Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SkipMofCheck.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SkipMofCheck Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SkipMofCheck.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does SkipMofCheck Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SkipMofCheck.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.SkipMofCheck.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SkipMofCheck.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SkipMofCheck.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SkipMofCheck.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SkipMofCheck '{
            $function.Definition.Contains('.PARAMETER SkipMofCheck') | Should Be 'True'
            }
        It 'Has a Parameter called IgnorePendingReboot' {
            $Function.Parameters.Keys.Contains('IgnorePendingReboot') | Should Be 'True'
            }
        It 'IgnorePendingReboot Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.Mandatory | Should be 'False'
            }
        It 'IgnorePendingReboot Parameter is of SwitchParameter Type' {
            $Function.Parameters.IgnorePendingReboot.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'IgnorePendingReboot Parameter is member of ParameterSets' {
            [String]$Function.Parameters.IgnorePendingReboot.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'IgnorePendingReboot Parameter Position is defined correctly' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.Position | Should be '-2147483648'
            }
        It 'Does IgnorePendingReboot Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does IgnorePendingReboot Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.IgnorePendingReboot.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does IgnorePendingReboot Parameter use advanced parameter Validation? ' {
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.IgnorePendingReboot.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for IgnorePendingReboot '{
            $function.Definition.Contains('.PARAMETER IgnorePendingReboot') | Should Be 'True'
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


