---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Remove-LabConfiguration
## SYNOPSIS
Removes all VMs and associated snapshots of all nodes defined in a PowerShell DSC configuration document.

## SYNTAX

```
Remove-LabConfiguration [-ConfigurationData] <Hashtable> [-RemoveSwitch] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The Remove-LabConfiguration removes all virtual machines that have a corresponding NodeName defined in the
AllNode array of the PowerShell DSC configuration document.

WARNING: ALL EXISTING VIRTUAL MACHINE DATA WILL BE LOST WHEN VIRTUAL MACHINES ARE REMOVED.

By default, associated virtual machine switches are not removed as they may be used by other virtual
machines or lab configurations.
If you wish to remove any virtual switche defined in the PowerShell DSC
configuration document, specify the -RemoveSwitch parameter.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData
Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
configuration document used to remove existing virtual machines.
One virtual machine is removed per node
defined in the AllNodes array.

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

### -RemoveSwitch
Specifies that any connected virtual switch should also be removed when the virtual machine is removed.

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

## NOTES

## RELATED LINKS

[about_ConfigurationData
Start-LabConfiguration]()

