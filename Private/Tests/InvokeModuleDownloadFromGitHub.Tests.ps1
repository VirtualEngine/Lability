Describe 'InvokeModuleDownloadFromGitHub Tests' {

   Context 'Parameters for InvokeModuleDownloadFromGitHub'{

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
            [String]$Function.Parameters.Name.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Name Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Name.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called DestinationPath' {
            $Function.Parameters.Keys.Contains('DestinationPath') | Should Be 'True'
            }
        It 'DestinationPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.DestinationPath.Attributes.Mandatory | Should be 'False'
            }
        It 'DestinationPath Parameter is of String Type' {
            $Function.Parameters.DestinationPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'DestinationPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DestinationPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DestinationPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.DestinationPath.Attributes.Position | Should be '1'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called Owner' {
            $Function.Parameters.Keys.Contains('Owner') | Should Be 'True'
            }
        It 'Owner Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Owner.Attributes.Mandatory | Should be 'False'
            }
        It 'Owner Parameter is of String Type' {
            $Function.Parameters.Owner.ParameterType.FullName | Should be 'System.String'
            }
        It 'Owner Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Owner.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Owner Parameter Position is defined correctly' {
            [String]$Function.Parameters.Owner.Attributes.Position | Should be '2'
            }
        It 'Does Owner Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Owner.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Owner Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Owner.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Owner Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Owner.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Owner.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Owner.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Owner.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Owner.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Owner '{
            $function.Definition.Contains('.PARAMETER Owner') | Should Be 'True'
            }
        It 'Has a Parameter called Repository' {
            $Function.Parameters.Keys.Contains('Repository') | Should Be 'True'
            }
        It 'Repository Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Repository.Attributes.Mandatory | Should be 'False'
            }
        It 'Repository Parameter is of String Type' {
            $Function.Parameters.Repository.ParameterType.FullName | Should be 'System.String'
            }
        It 'Repository Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Repository.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Repository Parameter Position is defined correctly' {
            [String]$Function.Parameters.Repository.Attributes.Position | Should be '3'
            }
        It 'Does Repository Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Repository.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Repository Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Repository.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Repository Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Repository.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Repository.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Repository.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Repository.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Repository.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Repository '{
            $function.Definition.Contains('.PARAMETER Repository') | Should Be 'True'
            }
        It 'Has a Parameter called Branch' {
            $Function.Parameters.Keys.Contains('Branch') | Should Be 'True'
            }
        It 'Branch Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Branch.Attributes.Mandatory | Should be 'False'
            }
        It 'Branch Parameter is of String Type' {
            $Function.Parameters.Branch.ParameterType.FullName | Should be 'System.String'
            }
        It 'Branch Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Branch.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Branch Parameter Position is defined correctly' {
            [String]$Function.Parameters.Branch.Attributes.Position | Should be '4'
            }
        It 'Does Branch Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Branch.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Branch Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Branch.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Branch Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Branch.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Branch.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Branch.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Branch.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Branch.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Branch '{
            $function.Definition.Contains('.PARAMETER Branch') | Should Be 'True'
            }
        It 'Has a Parameter called OverrideRepositoryName' {
            $Function.Parameters.Keys.Contains('OverrideRepositoryName') | Should Be 'True'
            }
        It 'OverrideRepositoryName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.OverrideRepositoryName.Attributes.Mandatory | Should be 'False'
            }
        It 'OverrideRepositoryName Parameter is of String Type' {
            $Function.Parameters.OverrideRepositoryName.ParameterType.FullName | Should be 'System.String'
            }
        It 'OverrideRepositoryName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.OverrideRepositoryName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'OverrideRepositoryName Parameter Position is defined correctly' {
            [String]$Function.Parameters.OverrideRepositoryName.Attributes.Position | Should be '5'
            }
        It 'Does OverrideRepositoryName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.OverrideRepositoryName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does OverrideRepositoryName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.OverrideRepositoryName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does OverrideRepositoryName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.OverrideRepositoryName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.OverrideRepositoryName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.OverrideRepositoryName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.OverrideRepositoryName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.OverrideRepositoryName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for OverrideRepositoryName '{
            $function.Definition.Contains('.PARAMETER OverrideRepositoryName') | Should Be 'True'
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
            [String]$Function.Parameters.RemainingArguments.Attributes.Position | Should be '6'
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


