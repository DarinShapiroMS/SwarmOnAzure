# **Swarm On Azure**


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDarinShapiroMS%2FSwarmOnAzure%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>



This repo contains a set of scripts, templates, and an exe that will deploy a cluster of Unreal Swarm Agents using Azure Virtual Machine Scale Sets. Along with network connectivity via EspressRoute or Virtual Network Gateway, the instances that are spun up connect to an Unreal Swarm Coordinator to manage the tasks they will execute. A brief desription of the components of this solution, organized into folders in this repo, are below.

### **Deployment folder**
This folder contains an **A**zure **R**esource **M**anager (ARM) template and a PowerShell script to deploy that template into your Azure subscription.  You will need to populate a set of parameters specific to your subscription before exectuting the PowerShell Script. [See More](deployment/readme.md)

### **Post-Deploy-VM-Config folder**
As the Virtual Machine Scale Set (vmss) creates new instances of the Windows Server virtual machines, a script is executed on the vm to config the environment for running the Swarm Agent.  No special VM image is necessary, all infrastructure configuration is done through code. [See More](post-deploy-vm-config/readme.md)

### **VM-Startup-Bootstrapper folder**
This folder contains a simple C# command line app that runs each time the VM is restarted. The purpose is to keep the Swarm Agent configured to utilize all available cores, even if you re-size the instances within the scale set.  Otherwise you would have to RDP to the machines and update the Agent config to match the number of cores. [See More](vm-startup-bootstrapper/readme.md)
