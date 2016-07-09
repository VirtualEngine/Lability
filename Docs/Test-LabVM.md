---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Test-LabVM
## SYNOPSIS
Checks whether the (external) lab virtual machine is configured as required.

## SYNTAX

```
Test-LabVM [[-Name] <String[]>] [-ConfigurationData] <Hashtable>
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

### -Name
Specifies the lab virtual machine/node name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
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

Required: True
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

