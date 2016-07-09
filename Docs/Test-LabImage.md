---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Test-LabImage
## SYNOPSIS
Tests whether a master/parent lab image is present.

## SYNTAX

```
Test-LabImage [-Id] <String> [[-ConfigurationData] <Hashtable>]
```

## DESCRIPTION
The Test-LabImage cmdlet returns whether a specified disk image is present.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Test-LabImage -Id 2012R2_x64_Standard_EN_Eval
```

Tests whether the '-Id 2012R2_x64_Standard_EN_Eval' lab image is present.

## PARAMETERS

### -Id
Specifies the media Id of the image to test.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: 
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ConfigurationData
Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
configuration document that contains the required media definition.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES

## RELATED LINKS

[Get-LabImage]()

