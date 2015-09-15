### VirtualEngineLab / PSLab / Conflab / Conphlab ###
The XXX module enables simple provisioning of Windows Hyper-V development and
testing environments. It uses a declarative document for machine configuration.
However, rather than defining configurations in an external custom domain-specific
language (DSL) document, XXX extends existing PowerShell Desired
State Configuration (DSC) configuration .psd1 documents with metadata that can
be interpreted by the module. By using this approach, it allows the use of a single
confiugration document to describe all properties for provisioning Windows-centric
development and/or test environments.

The XXX module will parse the DSC configuration document and provision
Hyper-V virtual machines according to the metadata contained within. When invoked, XXX
will parse a DSC configuration document and automagically provision the following
resources:
* Virtual disk images
 * Download required Operating System installation media
 * Windows Image (WIM) image files
 * Install required Windows updates
* Virtual networks
 * Create internal and external Hyper-V switches
* Virtual machines
 * Connect to the correct virtual switch
 * Inject the virtual machine's DSC document
 * Invoke the Local Configuration Manager (LCM)
