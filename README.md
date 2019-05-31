# **Swarm On Azure**






This repo contains a PowerShell script, an ARM template, and an exe that will deploy a cluster of Unreal Swarm Agents into your Azure subscription using Azure Virtual Machine Scale Sets. 

Before deploying this solution, you should fork this Github repo since you may want to make changes specific to your environment.  

There is also the prequisite step of setting up a Virtual Network and VPN gateway. This is because all communicatin between the Swarm Agents and your on-premise Swarm Coordinator happens over a private network. The Swarn Agents are deployed to VM instances that have no public IP address. 

**You'll need the following information to initiate the deployment**

**Parameter** | **Description**
---|---
Resource Group | The resource group this cluster of Unreal Swarm agents will be deployed into
Location | The Azure region for this resource group
Vmss Name | The name of the Virtual Machines Scale Sets that will manage the cluster of VM instances
VM Sku | this is the size of the virtual machines that get created. Reference the size column for each VM family at https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes.
Admin Username | Windows admin username used to create VM instance.
Admin Password | Windows admin password.  Store this info for later use.
Instance Count |  The number of VM instances that the Scale Set will create and maintain for you.
Subnet Id | TBF
Config Script URL | The URL for [ConfigVm.ps1](ConfigVM.ps1) that will configure each VM instance.
Coordinator Ip | The IP address of the Swarm Coordinator located on-prem. This IP much be reachable by the Swarm Agents through the VPN. It must also not block the ports needed by Swarm. ****more info needed here.**

### **Ready to deploy into your own Azure Subscription?**

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDarinShapiroMS%2FSwarmOnAzure%2Fmaster%2Fazuredeploy.json" target="_new">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


### **How it works**

The "Deploy To Azure" button above will submit the azuredeploy.json arm template to the Azure Portal for provisioning the required Azure services.  The arm template first creates the Virtual Machine Scale Set, which then provisions new VM instances.  Each time a VM instance is provisioned, [a PowerShell script](ConfigVM.ps1) get's downloaded to the new instance and executes once. A reference to the URI for [ConfigVM.ps1](ConfigVM.ps1) is a parameter of the arm template, so it knows where to download the script from. This script in turn downloads files to the new VM instance including a bootstrapper.exe, and the Swarm Binaries.





### **VM-Startup-Bootstrapper folder**
This folder contains a simple C# command line app that runs each time the VM is restarted. The purpose is to keep the Swarm Agent configured to utilize all available cores, even if you re-size the instances within the scale set.  Otherwise you would have to RDP to the machines and update the Agent config to match the number of cores. [See More](vm-startup-bootstrapper/readme.md)
