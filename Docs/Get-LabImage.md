---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Get-LabImage
## SYNOPSIS
Gets master/parent disk image.

## SYNTAX

```
Get-LabImage [[-Id] <String>] [[-ConfigurationData] <Hashtable>]
```

## DESCRIPTION
The Get-LabImage cmdlet returns current master/parent disk image properties.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LabImage
```

Returns all current lab images on the host.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-LabImage -Id 2012R2_x64_Standard_EN_Eval
```

Returns the '2012R2_x64_Standard_EN_Eval' lab image properties, if available.

## PARAMETERS

### -Id
Specifies the media Id of the image to return.
If this parameter is not specified, all images are returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
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

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS

