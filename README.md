# **Swarm On Azure**


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDarinShapiroMS%2FSwarmOnAzure%2Fmaster%2Fazuredeploy.json" target="_new">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

conflict
conflict
This repo contains a PowerShell script, an ARM template, and an exe that will deploy a cluster of Unreal Swarm Agents using Azure Virtual Machine Scale Sets. Requiring private network connectivity via EspressRoute or Virtual Network Gateway, the instances that are spun up connect to an Unreal Swarm Coordinator to manage the tasks they will execute. 

### **Overview**

The "Deploy To Azure" button above will submit the azuredeploy.json arm template to the Azure Portal for provisioning the required Azure services.  The arm template first creates the Virtual Machine Scale Set, which then provisions new VM instances.  Each time a VM instance is provisioned, [a PowerShell script](ConfigVM.ps1) get's downloaded to the new instance and executes once. A reference to the URI for [ConfigVM.ps1](ConfigVM.ps1) is a parameter of the arm template, so it knows where to download the script from. You could fork this repo and update the url paramter to point to your forked instance to control changes to that script.





### **VM-Startup-Bootstrapper folder**
This folder contains a simple C# command line app that runs each time the VM is restarted. The purpose is to keep the Swarm Agent configured to utilize all available cores, even if you re-size the instances within the scale set.  Otherwise you would have to RDP to the machines and update the Agent config to match the number of cores. [See More](vm-startup-bootstrapper/readme.md)
