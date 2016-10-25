Describe 'ExpandWindowsImage Tests' {

   Context 'Parameters for ExpandWindowsImage'{

        It 'Has a Parameter called MediaPath' {
            $Function.Parameters.Keys.Contains('MediaPath') | Should Be 'True'
            }
        It 'MediaPath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.MediaPath.Attributes.Mandatory | Should be 'True'
            }
        It 'MediaPath Parameter is of String Type' {
            $Function.Parameters.MediaPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'MediaPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MediaPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MediaPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.MediaPath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does MediaPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MediaPath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does MediaPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MediaPath.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does MediaPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MediaPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MediaPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MediaPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MediaPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MediaPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MediaPath '{
            $function.Definition.Contains('.PARAMETER MediaPath') | Should Be 'True'
            }
        It 'Has a Parameter called WimImageIndex' {
            $Function.Parameters.Keys.Contains('WimImageIndex') | Should Be 'True'
            }
        It 'WimImageIndex Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.WimImageIndex.Attributes.Mandatory | Should be 'True'
            }
        It 'WimImageIndex Parameter is of Int32 Type' {
            $Function.Parameters.WimImageIndex.ParameterType.FullName | Should be 'System.Int32'
            }
        It 'WimImageIndex Parameter is member of ParameterSets' {
            [String]$Function.Parameters.WimImageIndex.ParameterSets.Keys | Should Be 'Index'
            }
        It 'WimImageIndex Parameter Position is defined correctly' {
            [String]$Function.Parameters.WimImageIndex.Attributes.Position | Should be '-2147483648'
            }
        It 'Does WimImageIndex Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.WimImageIndex.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does WimImageIndex Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.WimImageIndex.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does WimImageIndex Parameter use advanced parameter Validation? ' {
            $Function.Parameters.WimImageIndex.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.WimImageIndex.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.WimImageIndex.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.WimImageIndex.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.WimImageIndex.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for WimImageIndex '{
            $function.Definition.Contains('.PARAMETER WimImageIndex') | Should Be 'True'
            }
        It 'Has a Parameter called WimImageName' {
            $Function.Parameters.Keys.Contains('WimImageName') | Should Be 'True'
            }
        It 'WimImageName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.WimImageName.Attributes.Mandatory | Should be 'True'
            }
        It 'WimImageName Parameter is of String Type' {
            $Function.Parameters.WimImageName.ParameterType.FullName | Should be 'System.String'
            }
        It 'WimImageName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.WimImageName.ParameterSets.Keys | Should Be 'Name'
            }
        It 'WimImageName Parameter Position is defined correctly' {
            [String]$Function.Parameters.WimImageName.Attributes.Position | Should be '-2147483648'
            }
        It 'Does WimImageName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.WimImageName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does WimImageName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.WimImageName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does WimImageName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.WimImageName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.WimImageName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.WimImageName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.WimImageName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.WimImageName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for WimImageName '{
            $function.Definition.Contains('.PARAMETER WimImageName') | Should Be 'True'
            }
        It 'Has a Parameter called Vhd' {
            $Function.Parameters.Keys.Contains('Vhd') | Should Be 'True'
            }
        It 'Vhd Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Vhd.Attributes.Mandatory | Should be 'True'
            }
        It 'Vhd Parameter is of Object Type' {
            $Function.Parameters.Vhd.ParameterType.FullName | Should be 'System.Object'
            }
        It 'Vhd Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Vhd.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Vhd Parameter Position is defined correctly' {
            [String]$Function.Parameters.Vhd.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Vhd Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Vhd.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Vhd Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Vhd.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Vhd Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Vhd.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Vhd '{
            $function.Definition.Contains('.PARAMETER Vhd') | Should Be 'True'
            }
        It 'Has a Parameter called PartitionStyle' {
            $Function.Parameters.Keys.Contains('PartitionStyle') | Should Be 'True'
            }
        It 'PartitionStyle Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.PartitionStyle.Attributes.Mandatory | Should be 'True'
            }
        It 'PartitionStyle Parameter is of String Type' {
            $Function.Parameters.PartitionStyle.ParameterType.FullName | Should be 'System.String'
            }
        It 'PartitionStyle Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PartitionStyle.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PartitionStyle Parameter Position is defined correctly' {
            [String]$Function.Parameters.PartitionStyle.Attributes.Position | Should be '-2147483648'
            }
        It 'Does PartitionStyle Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PartitionStyle.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PartitionStyle Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PartitionStyle.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does PartitionStyle Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PartitionStyle '{
            $function.Definition.Contains('.PARAMETER PartitionStyle') | Should Be 'True'
            }
        It 'Has a Parameter called WindowsOptionalFeature' {
            $Function.Parameters.Keys.Contains('WindowsOptionalFeature') | Should Be 'True'
            }
        It 'WindowsOptionalFeature Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.Mandatory | Should be 'False'
            }
        It 'WindowsOptionalFeature Parameter is of String[] Type' {
            $Function.Parameters.WindowsOptionalFeature.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'WindowsOptionalFeature Parameter is member of ParameterSets' {
            [String]$Function.Parameters.WindowsOptionalFeature.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'WindowsOptionalFeature Parameter Position is defined correctly' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.Position | Should be '-2147483648'
            }
        It 'Does WindowsOptionalFeature Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does WindowsOptionalFeature Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does WindowsOptionalFeature Parameter use advanced parameter Validation? ' {
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for WindowsOptionalFeature '{
            $function.Definition.Contains('.PARAMETER WindowsOptionalFeature') | Should Be 'True'
            }
        It 'Has a Parameter called SourcePath' {
            $Function.Parameters.Keys.Contains('SourcePath') | Should Be 'True'
            }
        It 'SourcePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.SourcePath.Attributes.Mandatory | Should be 'False'
            }
        It 'SourcePath Parameter is of String Type' {
            $Function.Parameters.SourcePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'SourcePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SourcePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SourcePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.SourcePath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does SourcePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SourcePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SourcePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SourcePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does SourcePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.SourcePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SourcePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SourcePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SourcePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SourcePath '{
            $function.Definition.Contains('.PARAMETER SourcePath') | Should Be 'True'
            }
        It 'Has a Parameter called WimPath' {
            $Function.Parameters.Keys.Contains('WimPath') | Should Be 'True'
            }
        It 'WimPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.WimPath.Attributes.Mandatory | Should be 'False'
            }
        It 'WimPath Parameter is of String Type' {
            $Function.Parameters.WimPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'WimPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.WimPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'WimPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.WimPath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does WimPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.WimPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does WimPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.WimPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does WimPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.WimPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.WimPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.WimPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.WimPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.WimPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for WimPath '{
            $function.Definition.Contains('.PARAMETER WimPath') | Should Be 'True'
            }
        It 'Has a Parameter called Package' {
            $Function.Parameters.Keys.Contains('Package') | Should Be 'True'
            }
        It 'Package Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Package.Attributes.Mandatory | Should be 'False'
            }
        It 'Package Parameter is of String[] Type' {
            $Function.Parameters.Package.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'Package Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Package.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Package Parameter Position is defined correctly' {
            [String]$Function.Parameters.Package.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Package Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Package.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Package Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Package.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Package Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Package '{
            $function.Definition.Contains('.PARAMETER Package') | Should Be 'True'
            }
        It 'Has a Parameter called PackagePath' {
            $Function.Parameters.Keys.Contains('PackagePath') | Should Be 'True'
            }
        It 'PackagePath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.PackagePath.Attributes.Mandatory | Should be 'False'
            }
        It 'PackagePath Parameter is of String Type' {
            $Function.Parameters.PackagePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'PackagePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PackagePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PackagePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.PackagePath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does PackagePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PackagePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PackagePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PackagePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does PackagePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PackagePath '{
            $function.Definition.Contains('.PARAMETER PackagePath') | Should Be 'True'
            }
        It 'Has a Parameter called PackageLocale' {
            $Function.Parameters.Keys.Contains('PackageLocale') | Should Be 'True'
            }
        It 'PackageLocale Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.PackageLocale.Attributes.Mandatory | Should be 'False'
            }
        It 'PackageLocale Parameter is of String Type' {
            $Function.Parameters.PackageLocale.ParameterType.FullName | Should be 'System.String'
            }
        It 'PackageLocale Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PackageLocale.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PackageLocale Parameter Position is defined correctly' {
            [String]$Function.Parameters.PackageLocale.Attributes.Position | Should be '-2147483648'
            }
        It 'Does PackageLocale Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PackageLocale.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PackageLocale Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PackageLocale.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does PackageLocale Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PackageLocale '{
            $function.Definition.Contains('.PARAMETER PackageLocale') | Should Be 'True'
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


