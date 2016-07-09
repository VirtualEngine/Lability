---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Checkpoint-Lab
## SYNOPSIS
Snapshots all lab VMs in their current configuration.

## SYNTAX

```
Checkpoint-Lab [-ConfigurationData] <Hashtable> [-SnapshotName] <String> [-Force]
```

## DESCRIPTION
The Checkpoint-Lab creates a VM checkpoint of all the nodes defined in a PowerShell DSC configuration document.
When creating the snapshots, they will be created using the snapshot name specified.

All virtual machines should be powered off when the snapshot is taken to ensure that the machine is in a
consistent state.
If VMs are powered on, an error will be generated.
You can override this behaviour by
specifying the -Force parameter.

WARNING: If the -Force parameter is used, the virtual machine snapshot(s) may be in an inconsistent state.

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

### -SnapshotName
Specifies the virtual machine snapshot name that applied to each VM in the PowerShell DSC configuration
document.
This name is used to restore a lab configuration.
It can contain spaces, but is not recommended.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: True
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Forces virtual machine snapshots to be taken - even if there are any running virtual machines.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Restore-Lab
Reset-Lab]()

