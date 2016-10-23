Describe 'Set-LabHostDefaults Tests' {

   Context 'Parameters for Set-LabHostDefaults'{

        It 'Has a Parameter called ConfigurationPath' {
            $Function.Parameters.Keys.Contains('ConfigurationPath') | Should Be 'True'
            }
        It 'ConfigurationPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ConfigurationPath.Attributes.Mandatory | Should be 'False'
            }
        It 'ConfigurationPath Parameter is of String Type' {
            $Function.Parameters.ConfigurationPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ConfigurationPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ConfigurationPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ConfigurationPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ConfigurationPath.Attributes.Position | Should be '0'
            }
        It 'Does ConfigurationPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ConfigurationPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ConfigurationPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ConfigurationPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ConfigurationPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ConfigurationPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ConfigurationPath '{
            $function.Definition.Contains('.PARAMETER ConfigurationPath') | Should Be 'True'
            }
        It 'Has a Parameter called IsoPath' {
            $Function.Parameters.Keys.Contains('IsoPath') | Should Be 'True'
            }
        It 'IsoPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.IsoPath.Attributes.Mandatory | Should be 'False'
            }
        It 'IsoPath Parameter is of String Type' {
            $Function.Parameters.IsoPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'IsoPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.IsoPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'IsoPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.IsoPath.Attributes.Position | Should be '1'
            }
        It 'Does IsoPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.IsoPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does IsoPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.IsoPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does IsoPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.IsoPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.IsoPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.IsoPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.IsoPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.IsoPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for IsoPath '{
            $function.Definition.Contains('.PARAMETER IsoPath') | Should Be 'True'
            }
        It 'Has a Parameter called ParentVhdPath' {
            $Function.Parameters.Keys.Contains('ParentVhdPath') | Should Be 'True'
            }
        It 'ParentVhdPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ParentVhdPath.Attributes.Mandatory | Should be 'False'
            }
        It 'ParentVhdPath Parameter is of String Type' {
            $Function.Parameters.ParentVhdPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ParentVhdPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ParentVhdPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ParentVhdPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ParentVhdPath.Attributes.Position | Should be '2'
            }
        It 'Does ParentVhdPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ParentVhdPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ParentVhdPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ParentVhdPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ParentVhdPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ParentVhdPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ParentVhdPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ParentVhdPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ParentVhdPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ParentVhdPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ParentVhdPath '{
            $function.Definition.Contains('.PARAMETER ParentVhdPath') | Should Be 'True'
            }
        It 'Has a Parameter called DifferencingVhdPath' {
            $Function.Parameters.Keys.Contains('DifferencingVhdPath') | Should Be 'True'
            }
        It 'DifferencingVhdPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.DifferencingVhdPath.Attributes.Mandatory | Should be 'False'
            }
        It 'DifferencingVhdPath Parameter is of String Type' {
            $Function.Parameters.DifferencingVhdPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'DifferencingVhdPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DifferencingVhdPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DifferencingVhdPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.DifferencingVhdPath.Attributes.Position | Should be '3'
            }
        It 'Does DifferencingVhdPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DifferencingVhdPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DifferencingVhdPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DifferencingVhdPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does DifferencingVhdPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DifferencingVhdPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.DifferencingVhdPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DifferencingVhdPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DifferencingVhdPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DifferencingVhdPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DifferencingVhdPath '{
            $function.Definition.Contains('.PARAMETER DifferencingVhdPath') | Should Be 'True'
            }
        It 'Has a Parameter called ModuleCachePath' {
            $Function.Parameters.Keys.Contains('ModuleCachePath') | Should Be 'True'
            }
        It 'ModuleCachePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ModuleCachePath.Attributes.Mandatory | Should be 'False'
            }
        It 'ModuleCachePath Parameter is of String Type' {
            $Function.Parameters.ModuleCachePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ModuleCachePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ModuleCachePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ModuleCachePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ModuleCachePath.Attributes.Position | Should be '4'
            }
        It 'Does ModuleCachePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ModuleCachePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ModuleCachePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ModuleCachePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ModuleCachePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ModuleCachePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ModuleCachePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ModuleCachePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ModuleCachePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ModuleCachePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ModuleCachePath '{
            $function.Definition.Contains('.PARAMETER ModuleCachePath') | Should Be 'True'
            }
        It 'Has a Parameter called ResourcePath' {
            $Function.Parameters.Keys.Contains('ResourcePath') | Should Be 'True'
            }
        It 'ResourcePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ResourcePath.Attributes.Mandatory | Should be 'False'
            }
        It 'ResourcePath Parameter is of String Type' {
            $Function.Parameters.ResourcePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ResourcePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourcePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ResourcePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourcePath.Attributes.Position | Should be '5'
            }
        It 'Does ResourcePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourcePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ResourcePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourcePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ResourcePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourcePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourcePath '{
            $function.Definition.Contains('.PARAMETER ResourcePath') | Should Be 'True'
            }
        It 'Has a Parameter called ResourceShareName' {
            $Function.Parameters.Keys.Contains('ResourceShareName') | Should Be 'True'
            }
        It 'ResourceShareName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ResourceShareName.Attributes.Mandatory | Should be 'False'
            }
        It 'ResourceShareName Parameter is of String Type' {
            $Function.Parameters.ResourceShareName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ResourceShareName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourceShareName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ResourceShareName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourceShareName.Attributes.Position | Should be '6'
            }
        It 'Does ResourceShareName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourceShareName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ResourceShareName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourceShareName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ResourceShareName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourceShareName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ResourceShareName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourceShareName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourceShareName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourceShareName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourceShareName '{
            $function.Definition.Contains('.PARAMETER ResourceShareName') | Should Be 'True'
            }
        It 'Has a Parameter called HotfixPath' {
            $Function.Parameters.Keys.Contains('HotfixPath') | Should Be 'True'
            }
        It 'HotfixPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.HotfixPath.Attributes.Mandatory | Should be 'False'
            }
        It 'HotfixPath Parameter is of String Type' {
            $Function.Parameters.HotfixPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'HotfixPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.HotfixPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'HotfixPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.HotfixPath.Attributes.Position | Should be '7'
            }
        It 'Does HotfixPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.HotfixPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does HotfixPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.HotfixPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does HotfixPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.HotfixPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.HotfixPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.HotfixPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.HotfixPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.HotfixPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for HotfixPath '{
            $function.Definition.Contains('.PARAMETER HotfixPath') | Should Be 'True'
            }
        It 'Has a Parameter called DisableLocalFileCaching' {
            $Function.Parameters.Keys.Contains('DisableLocalFileCaching') | Should Be 'True'
            }
        It 'DisableLocalFileCaching Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.DisableLocalFileCaching.Attributes.Mandatory | Should be 'False'
            }
        It 'DisableLocalFileCaching Parameter is of SwitchParameter Type' {
            $Function.Parameters.DisableLocalFileCaching.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'DisableLocalFileCaching Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DisableLocalFileCaching.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DisableLocalFileCaching Parameter Position is defined correctly' {
            [String]$Function.Parameters.DisableLocalFileCaching.Attributes.Position | Should be '-2147483648'
            }
        It 'Does DisableLocalFileCaching Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DisableLocalFileCaching.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DisableLocalFileCaching Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DisableLocalFileCaching.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does DisableLocalFileCaching Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DisableLocalFileCaching.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.DisableLocalFileCaching.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DisableLocalFileCaching.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DisableLocalFileCaching.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DisableLocalFileCaching.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DisableLocalFileCaching '{
            $function.Definition.Contains('.PARAMETER DisableLocalFileCaching') | Should Be 'True'
            }
        It 'Has a Parameter called EnableCallStackLogging' {
            $Function.Parameters.Keys.Contains('EnableCallStackLogging') | Should Be 'True'
            }
        It 'EnableCallStackLogging Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.EnableCallStackLogging.Attributes.Mandatory | Should be 'False'
            }
        It 'EnableCallStackLogging Parameter is of SwitchParameter Type' {
            $Function.Parameters.EnableCallStackLogging.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'EnableCallStackLogging Parameter is member of ParameterSets' {
            [String]$Function.Parameters.EnableCallStackLogging.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'EnableCallStackLogging Parameter Position is defined correctly' {
            [String]$Function.Parameters.EnableCallStackLogging.Attributes.Position | Should be '-2147483648'
            }
        It 'Does EnableCallStackLogging Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.EnableCallStackLogging.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does EnableCallStackLogging Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.EnableCallStackLogging.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does EnableCallStackLogging Parameter use advanced parameter Validation? ' {
            $Function.Parameters.EnableCallStackLogging.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.EnableCallStackLogging.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.EnableCallStackLogging.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.EnableCallStackLogging.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.EnableCallStackLogging.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for EnableCallStackLogging '{
            $function.Definition.Contains('.PARAMETER EnableCallStackLogging') | Should Be 'True'
            }
        It 'Has a Parameter called DismPath' {
            $Function.Parameters.Keys.Contains('DismPath') | Should Be 'True'
            }
        It 'DismPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.DismPath.Attributes.Mandatory | Should be 'False'
            }
        It 'DismPath Parameter is of String Type' {
            $Function.Parameters.DismPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'DismPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DismPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DismPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.DismPath.Attributes.Position | Should be '8'
            }
        It 'Does DismPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DismPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DismPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DismPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does DismPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DismPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.DismPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DismPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DismPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DismPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DismPath '{
            $function.Definition.Contains('.PARAMETER DismPath') | Should Be 'True'
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


