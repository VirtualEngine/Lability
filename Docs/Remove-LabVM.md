---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Remove-LabVM
## SYNOPSIS
Removes a bare-metal virtual machine and differencing VHD(X).

## SYNTAX

```
Remove-LabVM [-Name] <String[]> [[-ConfigurationData] <Hashtable>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The Remove-LabVM cmdlet removes a virtual machine and it's VHD(X) file.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
Virtual machine name

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: 
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ConfigurationData
Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.

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

## NOTES

## RELATED LINKS

