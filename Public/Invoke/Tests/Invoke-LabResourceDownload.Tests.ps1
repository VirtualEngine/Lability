Describe 'Invoke-LabResourceDownload Tests' {

   Context 'Parameters for Invoke-LabResourceDownload'{

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
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '-2147483648'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'True'
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
        It 'Has a Parameter called All' {
            $Function.Parameters.Keys.Contains('All') | Should Be 'True'
            }
        It 'All Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.All.Attributes.Mandatory | Should be 'False'
            }
        It 'All Parameter is of SwitchParameter Type' {
            $Function.Parameters.All.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'All Parameter is member of ParameterSets' {
            [String]$Function.Parameters.All.ParameterSets.Keys | Should Be 'All'
            }
        It 'All Parameter Position is defined correctly' {
            [String]$Function.Parameters.All.Attributes.Position | Should be '-2147483648'
            }
        It 'Does All Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.All.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does All Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.All.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does All Parameter use advanced parameter Validation? ' {
            $Function.Parameters.All.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.All.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.All.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.All.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.All.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for All '{
            $function.Definition.Contains('.PARAMETER All') | Should Be 'True'
            }
        It 'Has a Parameter called MediaId' {
            $Function.Parameters.Keys.Contains('MediaId') | Should Be 'True'
            }
        It 'MediaId Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.MediaId.Attributes.Mandatory | Should be 'False'
            }
        It 'MediaId Parameter is of String[] Type' {
            $Function.Parameters.MediaId.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'MediaId Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MediaId.ParameterSets.Keys | Should Be 'MediaId'
            }
        It 'MediaId Parameter Position is defined correctly' {
            [String]$Function.Parameters.MediaId.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MediaId Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MediaId.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MediaId Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MediaId.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called ResourceId' {
            $Function.Parameters.Keys.Contains('ResourceId') | Should Be 'True'
            }
        It 'ResourceId Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ResourceId.Attributes.Mandatory | Should be 'False'
            }
        It 'ResourceId Parameter is of String[] Type' {
            $Function.Parameters.ResourceId.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'ResourceId Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ResourceId.ParameterSets.Keys | Should Be 'ResourceId'
            }
        It 'ResourceId Parameter Position is defined correctly' {
            [String]$Function.Parameters.ResourceId.Attributes.Position | Should be '-2147483648'
            }
        It 'Does ResourceId Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ResourceId.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ResourceId Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ResourceId.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ResourceId Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ResourceId.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ResourceId '{
            $function.Definition.Contains('.PARAMETER ResourceId') | Should Be 'True'
            }
        It 'Has a Parameter called Media' {
            $Function.Parameters.Keys.Contains('Media') | Should Be 'True'
            }
        It 'Media Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Media.Attributes.Mandatory | Should be 'False'
            }
        It 'Media Parameter is of SwitchParameter Type' {
            $Function.Parameters.Media.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Media Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Media.ParameterSets.Keys | Should Be 'Media'
            }
        It 'Media Parameter Position is defined correctly' {
            [String]$Function.Parameters.Media.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Media Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Media Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Media Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Media '{
            $function.Definition.Contains('.PARAMETER Media') | Should Be 'True'
            }
        It 'Has a Parameter called Resources' {
            $Function.Parameters.Keys.Contains('Resources') | Should Be 'True'
            }
        It 'Resources Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Resources.Attributes.Mandatory | Should be 'False'
            }
        It 'Resources Parameter is of SwitchParameter Type' {
            $Function.Parameters.Resources.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Resources Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Resources.ParameterSets.Keys | Should Be 'Resources'
            }
        It 'Resources Parameter Position is defined correctly' {
            [String]$Function.Parameters.Resources.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Resources Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Resources.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Resources Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Resources.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Resources Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Resources.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Resources.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Resources.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Resources.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Resources.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Resources '{
            $function.Definition.Contains('.PARAMETER Resources') | Should Be 'True'
            }
        It 'Has a Parameter called DSCResources' {
            $Function.Parameters.Keys.Contains('DSCResources') | Should Be 'True'
            }
        It 'DSCResources Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.DSCResources.Attributes.Mandatory | Should be 'False'
            }
        It 'DSCResources Parameter is of SwitchParameter Type' {
            $Function.Parameters.DSCResources.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'DSCResources Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DSCResources.ParameterSets.Keys | Should Be 'DSCResources'
            }
        It 'DSCResources Parameter Position is defined correctly' {
            [String]$Function.Parameters.DSCResources.Attributes.Position | Should be '-2147483648'
            }
        It 'Does DSCResources Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DSCResources.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DSCResources Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DSCResources.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does DSCResources Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DSCResources.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.DSCResources.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DSCResources.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DSCResources.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DSCResources.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DSCResources '{
            $function.Definition.Contains('.PARAMETER DSCResources') | Should Be 'True'
            }
        It 'Has a Parameter called Modules' {
            $Function.Parameters.Keys.Contains('Modules') | Should Be 'True'
            }
        It 'Modules Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Modules.Attributes.Mandatory | Should be 'False'
            }
        It 'Modules Parameter is of SwitchParameter Type' {
            $Function.Parameters.Modules.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Modules Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Modules.ParameterSets.Keys | Should Be 'Modules'
            }
        It 'Modules Parameter Position is defined correctly' {
            [String]$Function.Parameters.Modules.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Modules Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Modules.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Modules Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Modules.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Modules Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Modules.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Modules.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Modules.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Modules.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Modules.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Modules '{
            $function.Definition.Contains('.PARAMETER Modules') | Should Be 'True'
            }
        It 'Has a Parameter called DestinationPath' {
            $Function.Parameters.Keys.Contains('DestinationPath') | Should Be 'True'
            }
        It 'DestinationPath Parameter is Identified as Mandatory being False False' {
            [String]$Function.Parameters.DestinationPath.Attributes.Mandatory | Should be 'False False'
            }
        It 'DestinationPath Parameter is of String Type' {
            $Function.Parameters.DestinationPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'DestinationPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DestinationPath.ParameterSets.Keys | Should Be 'ResourceId Resources'
            }
        It 'DestinationPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.DestinationPath.Attributes.Position | Should be '-2147483648 -2147483648'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipeline | Should be 'False False'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True True'
            }
        It 'Does DestinationPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DestinationPath '{
            $function.Definition.Contains('.PARAMETER DestinationPath') | Should Be 'True'
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


