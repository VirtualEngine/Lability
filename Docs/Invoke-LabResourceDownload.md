---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Invoke-LabResourceDownload
## SYNOPSIS
Starts a download of all required lab resources.

## SYNTAX

### All (Default)
```
Invoke-LabResourceDownload [-ConfigurationData <Hashtable>] [-All] [-Force]
```

### MediaId
```
Invoke-LabResourceDownload [-ConfigurationData <Hashtable>] [-MediaId <String[]>] [-Force]
```

### ResourceId
```
Invoke-LabResourceDownload [-ConfigurationData <Hashtable>] [-ResourceId <String[]>]
 [-DestinationPath <String>] [-Force]
```

### Media
```
Invoke-LabResourceDownload [-ConfigurationData <Hashtable>] [-Media] [-Force]
```

### Resources
```
Invoke-LabResourceDownload [-ConfigurationData <Hashtable>] [-Resources] [-DestinationPath <String>] [-Force]
```

### DSCResources
```
Invoke-LabResourceDownload [-ConfigurationData <Hashtable>] [-DSCResources] [-Force]
```

## DESCRIPTION
When a lab configuration is started, Lability will attempt to download all the required media and resources.

In some scenarios you many need to download lab resources in advance, e.g.
where internet access is not
readily available or permitted.
The \`Invoke-LabResourceDownload\` cmdlet can be used to manually download
all required resources or specific media/resources as needed.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -All
```

Downloads all required lab media, any custom resources and DSC resources defined in the 'MyLab.psd1' configuration.

### -------------------------- EXAMPLE 2 --------------------------
```
Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -MediaId 'WIN10_x64_Enterprise_EN_Eval'
```

Downloads only the 'WIN10_x64_Enterprise_EN_Eval' media.

### -------------------------- EXAMPLE 3 --------------------------
```
Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -ResourceId 'MyCustomResource'
```

Downloads only the 'MyCustomResource' resource defined in the 'MyLab.psd1' configuration.

### -------------------------- EXAMPLE 4 --------------------------
```
Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -Media
```

Downloads only the media defined in the 'MyLab.psd1' configuration.

### -------------------------- EXAMPLE 5 --------------------------
```
Invoke-LabResourceDownload -ConfigurationData ~\Documents\MyLab.psd1 -Resources -DSCResources
```

Downloads only the custom file resources and DSC resources defined in the 'MyLab.psd1' configuration.

## PARAMETERS

### -ConfigurationData
Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: @{ }
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Specifies all media, custom and DSC resources should be downloaded.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MediaId
Specifies the specific media IDs to download.

```yaml
Type: String[]
Parameter Sets: MediaId
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourceId
Specifies the specific custom resource IDs to download.

```yaml
Type: String[]
Parameter Sets: ResourceId
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Media
Specifies all media IDs should be downloaded.

```yaml
Type: SwitchParameter
Parameter Sets: Media
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Resources
Specifies all custom resource IDs should be downloaded.

```yaml
Type: SwitchParameter
Parameter Sets: Resources
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DSCResources
Specifies all DSC resources should be downloaded.

```yaml
Type: SwitchParameter
Parameter Sets: DSCResources
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationPath
Specifies the target destination path of downloaded custom resources (not media or DSC resources).

```yaml
Type: String
Parameter Sets: ResourceId, Resources
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Forces a download of all resources, overwriting any existing resources.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

