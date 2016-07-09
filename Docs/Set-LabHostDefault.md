---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Set-LabHostDefault
## SYNOPSIS
Sets the lab host's default settings.

## SYNTAX

```
Set-LabHostDefault [[-ConfigurationPath] <String>] [[-IsoPath] <String>] [[-ParentVhdPath] <String>]
 [[-DifferencingVhdPath] <String>] [[-ResourcePath] <String>] [[-ResourceShareName] <String>]
 [[-HotfixPath] <String>] [-DisableLocalFileCaching] [-EnableCallStackLogging] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The Set-LabHostDefault cmdlet sets one or more lab host default settings.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationPath
Lab host .mof configuration document search path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IsoPath
Lab host Media/ISO storage location/path.

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

### -ParentVhdPath
Lab host parent/master VHD(X) storage location/path.

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

### -DifferencingVhdPath
Lab host virtual machine differencing VHD(X) storage location/path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourcePath
Lab custom resource storage location/path.

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

### -ResourceShareName
Lab host DSC resource share name (for SMB Pull Server).

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

### -HotfixPath
Lab host media hotfix storage location/path.

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

### -DisableLocalFileCaching
Disable local caching of file-based ISO and WIM files.

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

### -EnableCallStackLogging
Enable call stack logging in verbose output

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

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS

[Get-LabHostDefault
Reset-LabHostDefault]()

