---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Register-LabMedia
## SYNOPSIS
Registers a custom media entry.

## SYNTAX

```
Register-LabMedia [-Id] <String> [-MediaType] <String> [-Uri] <Uri> [-Architecture] <String>
 [[-Description] <String>] [[-ImageName] <String>] [[-Filename] <String>] [[-Checksum] <String>]
 [[-CustomData] <Hashtable>] [[-Hotfixes] <Hashtable[]>] [[-OperatingSystem] <String>] [-Force]
```

## DESCRIPTION
The Register-LabMedia cmdlet allows adding custom media to the host's configuration.
This circumvents the requirement of having to define custom media entries in the DSC configuration document (.psd1).

You can use the Register-LabMedia cmdlet to override the default media entries, e.g.
you have the media hosted internally or you wish to replace the built-in media with your own implementation.

To override a built-in media entry, specify the same media Id with the -Force switch.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Id
Specifies the media Id to register.
You can override the built-in media if required.

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

### -MediaType
Specifies the media's type.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Uri
Specifies the source Uri (http/https/file) of the media.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Architecture
Specifies the architecture of the media.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Description
Specifies a description of the media.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ImageName
Specifies the image name containing the target WIM image.
You can specify integer values.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filename
Specifies the local filename of the locally cached resource file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Checksum
Specifies the MD5 checksum of the resource file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 8
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CustomData
Specifies custom data for the media.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: False
Position: 9
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Hotfixes
Specifies additional Windows hotfixes to install post deployment.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 10
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OperatingSystem
Specifies the media type.
Linux VHD(X)s do not inject resources.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 11
Default value: Windows
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Specifies that an exiting media entry should be overwritten.

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

[Get-LabMedia
Unregister-LabMedia]()

