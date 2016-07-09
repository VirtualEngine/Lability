---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Test-LabConfiguration
## SYNOPSIS
Tests the configuration of all VMs in a lab.

## SYNTAX

```
Test-LabConfiguration [-ConfigurationData] <Hashtable>
```

## DESCRIPTION
The Test-LabConfiguration determines whether all nodes defined in a PowerShell DSC configuration document
are configured correctly and returns the results.

WANRING: Only the virtual machine configuration is checked, not in the internal VM configuration.
For example,
the virtual machine's memory configuraiton, virtual switch configuration and processor count are tested.
The
VM's operating system configuration is not checked.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData
Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
configuration document used to create the virtual machines.
Each node defined in the AllNodes array is
tested.

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[about_ConfigurationData
Start-LabConfiguration]()

