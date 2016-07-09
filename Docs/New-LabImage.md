---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# New-LabImage
## SYNOPSIS
Creates a new master/parent lab image.

## SYNTAX

```
New-LabImage [-Id] <String> [[-ConfigurationData] <Hashtable>] [-Force] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The New-LabImage cmdlet starts the creation of a lab VHD(X) master image from the specified media Id.

Lability will automatically create lab images as required.
If there is a need to manally recreate an image,
then the New-LabImage cmdlet can be used.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-LabImage -Id 2012R2_x64_Standard_EN_Eval
```

Creates the VHD(X) image from the '2012R2_x64_Standard_EN_Eval' media Id.

### -------------------------- EXAMPLE 2 --------------------------
```
New-LabImage -Id 2012R2_x64_Standard_EN_Eval -Force
```

Creates the VHD(X) image from the '2012R2_x64_Standard_EN_Eval' media Id, overwriting an existing image with the same name.

## PARAMETERS

### -Id
Specifies the media Id of the image to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: 
Accept pipeline input: True (ByPropertyName)
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

### -Force
Specifies that any existing image should be overwritten.

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

### -WhatIf
{{Fill WhatIf Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
{{Fill Confirm Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.IO.FileInfo

## NOTES

## RELATED LINKS

[Get-LabMedia
Get-LabImage]()

