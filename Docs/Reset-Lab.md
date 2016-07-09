---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Reset-Lab
## SYNOPSIS
Reverts all VMs in a lab back to their initial configuration.

## SYNTAX

```
Reset-Lab [-ConfigurationData] <Hashtable>
```

## DESCRIPTION
The Reset-Lab cmdlet will reset all the nodes defined in a PowerShell DSC configuration document, back to their
initial state.
If virtual machines are powered on, they will automatically be powered off when restoring the
snapshot.

When virtual machines are created - before they are powered on - a baseline snapshot is created.
This snapshot
is taken before the Sysprep process has been run and/or any PowerShell DSC configuration has been applied.

WARNING: You will lose all changes to all virtual machines that have not been committed via another snapshot.

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
This cmdlet uses the baseline snapshot snapshot created by the Start-LabConfiguration cmdlet.
If the baseline
was not created or the baseline snapshot does not exist, the lab VMs can be recreated with the
Start-LabConfiguration -Force.

## RELATED LINKS

[Checkpoint-Lab]()

