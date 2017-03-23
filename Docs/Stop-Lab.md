---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Stop-Lab
## SYNOPSIS
Stops all VMs in a lab in a predefined order.

## SYNTAX

```
Stop-Lab [-ConfigurationData] <Hashtable>
```

## DESCRIPTION
The Stop-Lab cmdlet stops all nodes defined in a PowerShell DSC configuration document, in a preconfigured
order.

Unlike the standard Stop-VM cmdlet, the Stop-Lab cmdlet will read the specified PowerShell DSC configuration
document and infer the required shutdown order.

The PowerShell DSC configuration document can define the start/stop order of the virtual machines and the boot
delay between each VM power operation.
This is defined with the BootOrder and BootDelay properties.
The higher
the virtual machine's BootOrder index, the earlier it is stopped (in relation to the other VMs).

For example, a VM with a BootOrder index of 11 will be stopped before a VM with a BootOrder index of 10.
All
virtual machines receive a BootOrder value of 99 unless specified otherwise.

The delay between each power operation is defined with the BootDelay property.
This value is specified in
seconds and is enforced between starting or stopping a virtual machine.

For example, a VM with a BootDelay of 30 will enforce a 30 second delay after being powered on or after the
power off command is issued.
All VMs receive a BootDelay value of 0 (no delay) unless specified otherwise.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData
Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
configuration document.

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
Start-Lab]()

