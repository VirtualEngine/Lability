---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Show-LabNodeResourceList
## SYNOPSIS
Generates a display-friendly list of required custom resources for each node.

## SYNTAX

```
Show-LabNodeResourceList [-ConfigurationData] <Hashtable> [[-Name] <String[]>]
```

## DESCRIPTION
Outputs string of each selected node containing all required custom resources.
This is handy to create a
list of resources when manually configuring nodes is required, e.g.
locally on VMware Workstation or in
Microsoft Azure etc.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData
{{Fill ConfigurationData Description}}

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

### -Name
{{Fill Name Description}}

```yaml
Type: String[]
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

### System.String

## NOTES

## RELATED LINKS

