---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Restore-Lab
## SYNOPSIS
Restores all lab VMs to a previous configuration.

## SYNTAX

```
Restore-Lab [-ConfigurationData] <Hashtable> [-SnapshotName] <String> [-Force]
```

## DESCRIPTION
The Restore-Lab reverts all the nodes defined in a PowerShell DSC configuration document, back to a
previously captured configuration.

When creating the snapshots, they are created using a snapshot name.
To restore a lab to a previous
configuration, you must supply the same snapshot name.

All virtual machines should be powered off when the snapshots are restored.
If VMs are powered on,
an error will be generated.
You can override this behaviour by specifying the -Force parameter.

WARNING: If the -Force parameter is used, running virtual machines will be powered off automatically.

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
Specifies the virtual machine snapshot name to be restored.
You must use the same snapshot name used when
creating the snapshot with the Checkpoint-Lab cmdlet.

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
Forces virtual machine snapshots to be restored - even if there are any running virtual machines.

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

[Checkpoint-Lab
Reset-Lab]()

