---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Start-LabConfiguration
## SYNOPSIS
Invokes the deployment and configuration of a VM for each node defined in a PowerShell DSC configuration
document.

## SYNTAX

### PSCredential (Default)
```
Start-LabConfiguration -ConfigurationData <Hashtable> [-Credential <PSCredential>] [-Path <String>]
 [-NoSnapshot] [-Force] [-SkipMofCheck] [-IgnorePendingReboot]
```

### Password
```
Start-LabConfiguration -ConfigurationData <Hashtable> -Password <SecureString> [-Path <String>] [-NoSnapshot]
 [-Force] [-SkipMofCheck] [-IgnorePendingReboot]
```

## DESCRIPTION
The Start-LabConfiguration initiates the configuration of all nodes defined in a PowerShell DSC configuration
document.
The AllNodes array is enumerated and a virtual machine is created per node, using the NodeName
property.

If any existing virtual machine exists with the same name as the NodeName declaration of the AllNodes array,
the cmdlet will throw an error.
If this behaviour is not desired, you can forcibly remove the existing VM
with the -Force parameter.
NOTE: THE VIRTUAL MACHINE'S EXISTING DATA WILL BE LOST.

The virtual machines' local administrator password must be specified when creating the lab VMs.
The local
administrator password can be specified as a \[PSCredential\] or a \[SecureString\] type.
If a \[PSCredential\] is
used then the username is not used.

It is possible to override the module's virtual machine default settings by specifying the required property
on the node hashtable in the PowerShell DSC configuration document.
Default settings include the Operating
System image to use, the amount of memory assigned to the virtual machine and/or the virtual switch to
connect the virtual machine to.
If the settings are not overridden, the module's defaults are used.
Use the
Get-LabVMDefault cmdlet to view the module's default values.

Each virtual machine created by the Start-LabConfiguration cmdlet, has its PowerShell DSC configuraion (.mof)
file injected into the VHD file as it is created.
This configuration is then applied during the first boot
process to ensure the virtual machine is configured as required.
If the path to the VM's .mof files is not
specified, the module's default Configuration directory is used.
Use the Get-LabHostDefault cmdlet to view
the module's default Configuration directory path.

The virtual machine .mof files must be created before creating the lab.
If any .mof files are missing, the
Start-LabConfiguration cmdlet will generate an error.
You can choose to ignore this error by specifying
the -SkipMofCheck parameter.
If you skip the .mof file check - and no .mof file is found - no configuration
will be applied to the virtual machine's Operating System settings.

When deploying a lab, the module will create a default baseline snapshot of all virtual machines.
This
snapshot can be used to revert all VMs back to their default configuration.
If this snapshot is not
required, it can be surpressed with the -NoSnapshot parameter.

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
One virtual machine is created per node defined
in the AllNodes array.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Credential
Specifies the local administrator password of all virtual machines in the lab configuration.
The same
password is used for all virtual machines in the same lab configuration.
The username is not used.

```yaml
Type: PSCredential
Parameter Sets: PSCredential
Aliases: 

Required: False
Position: Named
Default value: (& $credentialCheckScriptBlock)
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
Specifies the local administrator password of all virtual machines in the lab configuration.
The same
password is used for all virtual machines in the same lab configuration.

```yaml
Type: SecureString
Parameter Sets: Password
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Specifies the directory path containing the individual PowerShell DSC .mof files.
If not specified, the
module's default location is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: (GetLabHostDSCConfigurationPath)
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoSnapshot
Specifies that no default snapshot will be taken when creating the virtual machine.

NOTE: If no default snapshot is not created, the lab cannot be restored to its initial configuration
with the Reset-Lab cmdlet.

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

### -Force
Specifies that any existing virtual machine with a matching name, will be removed and recreated.
By
default, if a virtual machine already exists with the same name, the cmdlet will generate an error.

NOTE: If the -Force parameter is specified - and a virtual machine with the same name already exists -
ALL EXISTING DATA WITHIN THE VM WILL BE LOST.

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

### -SkipMofCheck
Specifies that the module will configure a virtual machines that do not have a corresponding .mof file
located in the -Path specfified.
By default, if any .mof file cannot be located then the cmdlet will
generate an error.

NOTE: If no .mof file is found and the -SkipMofCheck parameter is specified, no configuration will be
applied to the virtual machine's Operating System configuration.

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

### -IgnorePendingReboot
The host's configuration is checked before invoking a lab configuration, including checking for pending
reboots.
The -IgnorePendingReboot specifies that a pending reboot should be ignored and the lab
configuration applied.

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

## INPUTS

## OUTPUTS

## NOTES
The same local administrator password is used for all virtual machines created in the same lab configuration.

## RELATED LINKS

[about_ConfigurationData
about_Bootstrap
Get-LabHostDefault
Set-LabHostDefault
Get-LabVMDefault
Set-LabVMDefault
Reset-Lab]()

