---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Test-LabResource
## SYNOPSIS
Tests whether a lab's resources are present.

## SYNTAX

```
Test-LabResource [-ConfigurationData] <Hashtable> [[-ResourceId] <String>] [[-ResourcePath] <String>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData
PowerShell DSC configuration document (.psd1) containing lab metadata.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: 
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ResourceId
Lab resource Id to test.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourcePath
Lab resource path

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES

## RELATED LINKS

