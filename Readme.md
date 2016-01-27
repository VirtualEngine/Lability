### VirtualEngineLab ###
<img align="right" alt="VirtualEngineLab logo" src="https://raw.githubusercontent.com/VirtualEngine/Lab/dev/VirtualEngineLab.png">

The __VirtualEngineLab__ module enables simple provisioning of Windows Hyper-V development and
testing environments. It uses a declarative document for machine configuration.
However, rather than defining configurations in an external custom domain-specific
language (DSL) document, __VirtualEngineLab__ extends existing PowerShell Desired
State Configuration (DSC) configuration .psd1 documents with metadata that can
be interpreted by the module.

By using this approach, it allows the use of a single confiugration document to
describe all properties for provisioning Windows-centric development and/or test
environments.

The __VirtualEngineLab__ module will parse the DSC configuration document and provision
Hyper-V virtual machines according to the metadata contained within. When invoked,
__VirtualEngineLab__ will parse a DSC configuration document and automagically
provision the following resources:
* Virtual machine disk images
 * Download required evaluation Operating System installation media
 * Expand Windows Image (WIM) image files into Sysprep'd virtual machine parent disks, including Server 2016 TP4 and Nano server
 * Apply required/recommended DSC Windows updates
* Virtual networks
 * Create internal and external Hyper-V switches
* Virtual machines
 * Connect to the correct virtual switches
 * Inject DSC resources from the host machine
 * Inject a dynamically created Unattend.xml file
 * Inject external ISO, EXE and ZIP resources 
 * Inject the virtual machine's DSC document
 * Invoke the Local Configuration Manager (LCM) after Sysprep
 
An example DSC configuration document might look the following. Note: this is a
standard DSC .psd1 configuration document, but has been extended with specific
properties which the __VirtualEngineLab__ module can interpret.

```powershell
@{
    AllNodes = @(
		@{
			NodeName = 'DC1';
            VirtualEngineLab_ProcessorCount = 2;
			VirtualEngineLab_SwitchName = 'CORPNET';
			VirtualEngineLab_Media = '2012R2_x64_Standard_EN_Eval';
		},
		@{
			NodeName = 'APP1';
            VirtualEngineLab_ProcessorCount = 1;
			VirtualEngineLab_SwitchName = 'CORPNET';
			VirtualEngineLab_Media = '2012R2_x64_Standard_EN_Eval';
		}	
	)
	NonNodeData = @{
        VirtualEngineLab = @{
            Network = @(
                @{ Name = 'CORPNET'; Type = 'Internal'; }
			)
		}
	}
}
```
When `Start-LabConfiguration` is invoked with the above configuration document, it
will:
* Create an internal Hyper-V virtual switch named 'CORPNET'
* Download required Server 2012 R2 Standard Edition evaluation media
 * Create a Sysprep'd Server 2012 R2 Standard Edition parent VHDX
 * Install required/recommended DSC hotfixes
* Provision two Hyper-V virtual machines called 'DC1' and 'APP1'
 * Each VM will be given 2GB RAM (configurable default)
 * 'DC1' will be assigned 2 virtual CPUs
 * 'APP1' will be assigned 1 virtual CPU
 * Attach each virtual machine to the 'CORPNET' virtual switch
 * Create differencing VHDX for each VM
 * Inject a dynamically created Unattend.xml file into the differencing VHDX

A brief introduction to the __VirtualEngineLab__ module presented at the European
PowerShell Summit 2015 can be found __[here](https://www.youtube.com/watch?v=jefhLaJsG3E "Man vs TestLab")__.

[__VirtualEngineLab__ image/logo attribution credit](https://openclipart.org/image/300px/svg_to_png/22734/papapishu-Lab-icon-1.png)
