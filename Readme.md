| master branch | dev branch |
| ------------- | ---------- |
| [![Build status](https://ci.appveyor.com/api/projects/status/qffyfab12jucd3qj?svg=true)](https://ci.appveyor.com/project/iainbrighton/lability-9tjgw) | [![Build status](https://ci.appveyor.com/api/projects/status/qffyfab12jucd3qj/branch/dev?svg=true)](https://ci.appveyor.com/project/iainbrighton/lability-9tjgw/branch/dev)

# Lability #

<img align="right" alt="Lability logo" src="https://raw.githubusercontent.com/VirtualEngine/Lability/dev/Lability.png">

The __Lability__ module enables simple provisioning of Windows Hyper-V development and testing
environments. It uses a declarative document for machine configuration. However, rather than
defining configurations in an external custom domain-specific language (DSL) document, __Lability__
extends existing PowerShell Desired State Configuration (DSC) configuration (.psd1) documents with
metadata that can be interpreted by the module.

By using this approach, it allows the use of a single configuration document to describe all
properties for provisioning Windows-centric development and/or test environments.

The __Lability__ module will parse the DSC configuration document and provision Hyper-V virtual
machines according to the metadata contained within. When invoked, __Lability__ will parse a DSC
configuration document and automagically provision the following resources:

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


## Examples ##

An example DSC configuration document might look the following. __Note:__ this is a standard DSC
.psd1 configuration document, but has been extended with specific properties which the __Lability__
module can interpret.

```powershell
@{
    AllNodes = @(
        @{
            NodeName                = 'DC1';
            Lability_ProcessorCount = 2;
            Lability_SwitchName     = 'CORPNET';
            Lability_Media          = '2012R2_x64_Standard_EN_Eval';
        },
        @{
            NodeName                = 'APP1';
            Lability_ProcessorCount = 1;
            Lability_SwitchName     = 'CORPNET';
            Lability_Media          = '2012R2_x64_Standard_EN_Eval';
        }
    )
    NonNodeData = @{
        Lability = @{
            Network = @(
                @{
                    Name = 'CORPNET';
                    Type = 'Internal';
                }
            ) #end Network
        } #end Lability
    } #end NonNodeData
}
```

When `Start-LabConfiguration` is invoked with the above configuration document, it will:

* Create an internal Hyper-V virtual switch named 'CORPNET'
  * If no network is defined, a default internal virtual switch will automatically be created
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

More examples can be found in the [.\Examples](https://github.com/VirtualEngine/Lability/tree/master/Examples) folder
of the module's root directory.

## Community Resources ##

A brief introduction to the __VirtualEngineLab__ module presented at the European PowerShell Summit 2015 can be found
__[here](https://www.youtube.com/watch?v=jefhLaJsG3E "Man vs TestLab")__. Other generous members of the community have written some comprehensive guides to compliment the built-in documentation – a BIG thank you!

* [Lability tutorial](https://me.micahrl.com/lability-tutorial) by [mrled](https://github.com/mrled)
* [Building A Lab using Hyper-V and Lability](https://blog.kilasuit.org/2016/04/13/building-a-lab-using-hyper-v-and-lability-the-end-to-end-example/) via @kilasuit
* [The Ultimate Hyper-V Lab Tool](https://web.archive.org/web/20180830192145/http://www.absolutejam.co.uk/blog/lability-ultimate-hyperv-lab-tool/) via @absolutejam
* [Create Your Virtual Lab Environment with Lability How-To](http://blog.mscloud.guru/2016/09/17/create-your-virtual-lab-environment-with-lability-howto/) via @Naboo2604
* [Microsoft Channel 9 PSDEVOPS](https://channel9.msdn.com/Blogs/PSDEVOPSSIG/PSDEVOPSSIGEventLability-Demo-w-Iain-Brigton) presentation recording
* [Using Lability, DSC and ARM to define and deploy multi-VM environments](https://blogs.blackmarble.co.uk/rhepworth/2017/03/02/define-once-deploy-everywhere-sort-of/) via @rikhepworth
* [Building Hyper-V lab environments based on PowerShell DSC](http://www.powershell.no/hyper-v,/powershell/dsc/2017/07/19/lability.html) via @JanEgilRing

[__Lability__ image/logo attribution credit](https://openclipart.org/image/300px/svg_to_png/22734/papapishu-Lab-icon-1.png)
